local gl = require "src.bindings.gl"
local x11 = require "src.bindings.x11"

local window = require "src.window"
local render = require "src.render"

local Pipeline = require "src.gl.pipeline"
local Program = require "src.gl.program"
local BufferDescriptor = require "src.gl.buffer_descriptor"
local Buffer = require "src.gl.buffer"
local VAO = require "src.gl.vao"
local Uniform = require "src.gl.uniform"
local UniformBlock = require "src.gl.uniform_block"
local TextureManager = require "src.gl.texture_manager"

local Layout = require "src.ui.layout"
local Element = require "src.ui.element"

local Image = require "src.image"

local vertexShader = io.open("src/shaders/main.vert.glsl", "r"):read("*a")
local fragmentShader = io.open("src/shaders/main.frag.glsl", "r"):read("*a")

local function toNDC(pos, screenSize)
    return (pos / (screenSize * 0.5)) - 1.0
end

---@param layout ComputedLayout
local function generateLayoutQuads(layout, parentX, parentY, vertices, indices, windowWidth, windowHeight)
    local x = (parentX or 0) + (layout.x or 0)
    local y = (parentY or 0) + (layout.y or 0)
    local width = layout.width
    local height = layout.height
    local z = layout.zIndex

    if layout.style then
        local color = layout.style.bg or { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }
        local baseIdx = #vertices / 10

        local left = toNDC(x, windowWidth)
        local right = toNDC(x + width, windowWidth)
        local top = -toNDC(y, windowHeight)
        local bottom = -toNDC(y + height, windowHeight)

        local textureId = 0 -- default white texture
        if layout.style.bgImage then
            textureId = layout.style.bgImage
        end

        for _, v in ipairs {
            left, top, z, color.r, color.g, color.b, color.a, 0, 0, textureId,
            right, top, z, color.r, color.g, color.b, color.a, 1, 0, textureId,
            right, bottom, z, color.r, color.g, color.b, color.a, 1, 1, textureId,
            left, bottom, z, color.r, color.g, color.b, color.a, 0, 1, textureId
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

local function findElementAtPosition(element, layout, x, y, parentX, parentY, acceptFn)
    local absX = (parentX or 0) + (layout.x or 0)
    local absY = (parentY or 0) + (layout.y or 0)

    if x >= absX and x <= absX + layout.width and
       y >= absY and y <= absY + layout.height then

        if layout.children and element.children then
            for i, childLayout in ipairs(layout.children) do
                local found = findElementAtPosition(element.children[i], childLayout, x, y, absX, absY, acceptFn)
                if found and (not acceptFn or acceptFn(found)) then
                    return found
                end
            end
        end

        if not acceptFn or acceptFn(element) then
            return element
        end
    end

    return nil
end

---@param results table<Element, { layout: ComputedLayout, absX: number, absY: number }>
---@return boolean
local function findElementsAtPosition(element, layout, x, y, parentX, parentY, results)
    local absX = (parentX or 0) + (layout.x or 0)
    local absY = (parentY or 0) + (layout.y or 0)

    if x >= absX and x <= absX + layout.width and
        y >= absY and y <= absY + layout.height then

        results[element] = { layout = layout, absX = absX, absY = absY }
        if layout.children and element.children then
            for i, childLayout in ipairs(layout.children) do
                local found = findElementsAtPosition(element.children[i], childLayout, x, y, absX, absY, results)
                if not found then
                    break
                end
            end
        end
    end

    return true
end

local function getTopElementWithCursor(elements)
    local topElement = nil
    local topZ = -math.huge

    for element, data in pairs(elements) do
        if element.visualStyle and element.visualStyle.cursor then
            local z = data.layout.zIndex or 0
            if z > topZ then
                topZ = z
                topElement = element
            end
        end
    end

    return topElement
end

local Arisu = {}

---@generic T
---@generic Message
---@param cons fun(textureManager: TextureManager): { view: fun(self: T), update: fun(self: T, message: Message), event: fun(self: T, event: Event): Message }
function Arisu.runApp(cons)
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
        :withAttribute({ type = "f32", size = 3, offset = 0 })  -- position (vec3)
        :withAttribute({ type = "f32", size = 4, offset = 12 })  -- color (rgba)
        :withAttribute({ type = "f32", size = 2, offset = 28 }) -- uv
        :withAttribute({ type = "f32", size = 1, offset = 36 }) -- texture id

    local vertex = Buffer.new()
    local index = Buffer.new()

    local vao = VAO.new()
    vao:setVertexBuffer(vertex, vertexDescriptor)
    vao:setIndexBuffer(index)

    local samplers = Uniform.new("sampler2DArray", 0)
    local textureDims = UniformBlock.new(0)
    local textureManager = TextureManager.new(samplers, textureDims, 0)

    -- Run the app constructor in the rendering context so they can initialize any
    -- GL resources they need.
    local app = cons(textureManager)
    app.event = app.event or function(_) end

    local ui = app:view()
    local layoutTree = Layout.fromElement(ui)
    local currentCursor = nil

    local function runUpdate(message)
        local didUpdate = app:update(message)
        if didUpdate then
            ui = app:view()
            layoutTree = Layout.fromElement(ui)
        end
    end

    local function runEvent(event)
        local message = app:event(event)
        if message then
            runUpdate(message)
        end
    end

    eventLoop:run(function(event, handler)
        handler:setMode("poll")

        if event.name == "deleteWindow" then
            handler:exit()
        elseif event.name == "aboutToWait" then
            handler:requestRedraw(window)
        elseif event.name == "resize" then
            gl.viewport(0, 0, window.width, window.height)
        elseif event.name == "mouseMove" then
            local computedLayout = layoutTree:solve(window.width, window.height)

            ---@type table<Element<any>, {absX: number, absY: number}>
            local hoveredElements = {}
            findElementsAtPosition(ui, computedLayout, event.x, event.y, 0, 0, hoveredElements)

            local anyWithMouseDown = false
            for el, _ in pairs(hoveredElements) do
                if el.onmousedown then
                    anyWithMouseDown = true
                    break
                end
            end

            if anyWithMouseDown then
                window:setCursor("hand2")
            else
                window:resetCursor()
            end

            for el, layout in pairs(hoveredElements) do
                if el.onmousemove then
                    runUpdate(el.onmousemove(event.x - layout.absX, event.y - layout.absY, layout.layout.width, layout.layout.height))
                end
            end
        elseif event.name == "mousePress" then
            local computedLayout = layoutTree:solve(window.width, window.height)

            local mouseDownElement = findElementAtPosition(ui, computedLayout, event.x, event.y, 0, 0, function(el)
                return el.onmousedown ~= nil
            end)

            if mouseDownElement then
                runUpdate(mouseDownElement.onmousedown)
            end
        elseif event.name == "mouseRelease" then
            local computedLayout = layoutTree:solve(window.width, window.height)
            local mouseUpElement = findElementAtPosition(ui, computedLayout, event.x, event.y, 0, 0, function(el)
                return el.onmouseup ~= nil
            end)

            if mouseUpElement then
                runUpdate(mouseUpElement.onmouseup)
            end
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

                textureManager:bind()
                vao:bind()
                gl.drawElements(gl.TRIANGLES, #indices, gl.UNSIGNED_INT, nil)

                ctx:swapBuffers()
                lastFrameTime = currentTime
            end
        end
    end)

    ctx:destroy()
end

return Arisu
