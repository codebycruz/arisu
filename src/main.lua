local gl = require "src.bindings.gl"
local glx = require "src.bindings.glx"
local x11 = require "src.bindings.x11"

local window = require "src.window"
local render = require "src.render"

local Pipeline = require "src.gl.pipeline"
local Program = require "src.gl.program"
local BufferDescriptor = require "src.gl.buffer_descriptor"
local Buffer = require "src.gl.buffer"
local VAO = require "src.gl.vao"

local Layout = require "src.ui.layout"
local Element = require "src.ui.element"

local vertexShader = io.open("src/shaders/main.vert.glsl", "r"):read("*a")
local fragmentShader = io.open("src/shaders/main.frag.glsl", "r"):read("*a")

local function toNDC(pos, screenSize)
    return (pos / (screenSize * 0.5)) - 1.0
end

local function generateLayoutQuads(layout, parentX, parentY, vertices, indices, windowWidth, windowHeight)
    local x = (parentX or 0) + (layout.x or 0)
    local y = (parentY or 0) + (layout.y or 0)
    local width = layout.width
    local height = layout.height

    if layout.style and layout.style.bg then
        local color = layout.style.bg
        local baseIdx = #vertices / 6

        local left = toNDC(x, windowWidth)
        local right = toNDC(x + width, windowWidth)
        local top = -toNDC(y, windowHeight)
        local bottom = -toNDC(y + height, windowHeight)

        for _, v in ipairs {
            left, top, color.r, color.g, color.b, color.a,
            right, top, color.r, color.g, color.b, color.a,
            right, bottom, color.r, color.g, color.b, color.a,
            left, bottom, color.r, color.g, color.b, color.a
        } do
            table.insert(vertices, v)
        end

        for _, idx in ipairs {
            baseIdx, baseIdx + 1, baseIdx + 2,
            baseIdx, baseIdx + 2, baseIdx + 3
        } do
            table.insert(indices, idx)
        end
    end

    if layout.children then
        for _, child in ipairs(layout.children) do
            generateLayoutQuads(child, x, y, vertices, indices, windowWidth, windowHeight)
        end
    end
end

local function main()
    local ui = Element.Div.new()
        :withChildren(
            Element.Button.new()
                :withInner(Element.Text.from("Click Me"))
                :onClick(function()
                    print("Button clicked!")
                end),
            Element.Text.from("Hello, World!")
        )

    local layoutTree = Layout.new()
        :withSize(1.0, 1.0)
        :withDirection("row")
        :withGap(40 * 4)
        :withJustify("center")
        :withAlign("center")
        :withStyle({ bg = { r = 1.0, g = 0.0, b = 0.0, a = 1.0 } })
        :withChildren(
            Layout.new()
                :withStyle({ bg = { r = 0.0, g = 1.0, b = 0.0, a = 1.0 } })
                :withSize(256, 256),
            Layout.new()
                :withStyle({ bg = { r = 0.0, g = 0.0, b = 1.0, a = 1.0 } })
                :withSize(256, 256)
        )

    local eventLoop = window.EventLoop.new()
    local window = window.WindowBuilder.new()
        :withTitle("Layout Renderer")
        :withSize(800, 600)
        :build(eventLoop)

    local display = window.display

    local lastFrameTime = os.clock()
    local targetFPS = 60
    local frameTime = 1.0 / targetFPS

    local ctx = render.Context.new(display, window)
    if not ctx then
        window:destroy()
        x11.closeDisplay(display)
        return 1
    end

    ctx:makeCurrent()

    local pipeline = Pipeline.new()
    pipeline:setProgram(gl.ShaderType.VERTEX, Program.new(gl.ShaderType.VERTEX, vertexShader))
    pipeline:setProgram(gl.ShaderType.FRAGMENT, Program.new(gl.ShaderType.FRAGMENT, fragmentShader))
    pipeline:bind()

    local vertexDescriptor = BufferDescriptor.new()
        :withAttribute({ type = "f32", size = 2, offset = 0 })  -- position (vec2)
        :withAttribute({ type = "f32", size = 4, offset = 8 })  -- color (rgba)

    local vertex = Buffer.new()
    local index = Buffer.new()

    local vao = VAO.new()
    vao:setVertexBuffer(vertex, vertexDescriptor)
    vao:setIndexBuffer(index)

    eventLoop:run(function(event, handler)
        handler:setMode("poll")

        if event.name == "deleteWindow" then
            handler:exit()
        elseif event.name == "aboutToWait" then
            handler:requestRedraw(window)
        elseif event.name == "resize" then
            gl.viewport(0, 0, window.width, window.height)
        elseif event.name == "redraw" then
            local currentTime = os.clock()
            local deltaTime = currentTime - lastFrameTime

            if deltaTime >= frameTime then
                local computedLayout = layoutTree:solve(window.width, window.height)

                local vertices, indices = {}, {}
                generateLayoutQuads(computedLayout, 0, 0, vertices, indices, window.width, window.height)

                vertex:setData("f32", vertices)
                index:setData("u32", indices)

                gl.clearColor(0.1, 0.1, 0.1, 1.0)
                gl.clear(gl.COLOR_BUFFER_BIT)

                vao:bind()
                gl.drawElements(gl.TRIANGLES, #indices, gl.UNSIGNED_INT, nil)

                ctx:swapBuffers()
                lastFrameTime = currentTime
            end
        end
    end)

    ctx:destroy()
end

return main()
