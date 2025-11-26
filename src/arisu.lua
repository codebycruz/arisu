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
local FontManager = require "src.gl.font_manager"

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

        local u0, v0, u1, v1 = 0, 0, 1, 1
        if layout.style.bgImageUV then
            u0 = layout.style.bgImageUV.u0 or 0
            v0 = layout.style.bgImageUV.v0 or 0
            u1 = layout.style.bgImageUV.u1 or 1
            v1 = layout.style.bgImageUV.v1 or 1
        end

        for _, v in ipairs {
            left, top, z, color.r, color.g, color.b, color.a, u0, v0, textureId,
            right, top, z, color.r, color.g, color.b, color.a, u1, v0, textureId,
            right, bottom, z, color.r, color.g, color.b, color.a, u1, v1, textureId,
            left, bottom, z, color.r, color.g, color.b, color.a, u0, v1, textureId
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

    -- Generate border quads after background (so they render on top)
    if layout.border then
        local borderTop = layout.border.top
        local borderBottom = layout.border.bottom
        local borderLeft = layout.border.left
        local borderRight = layout.border.right

        local function addBorderQuad(bx, by, bw, bh, color)
            if bw <= 0 or bh <= 0 then return end

            local baseIdx = #vertices / 10
            local left = toNDC(bx, windowWidth)
            local right = toNDC(bx + bw, windowWidth)
            local top = -toNDC(by, windowHeight)
            local bottom = -toNDC(by + bh, windowHeight)

            for _, v in ipairs {
                left, top, z + 0.002, color.r, color.g, color.b, color.a, 0, 0, 0,
                right, top, z + 0.002, color.r, color.g, color.b, color.a, 0, 0, 0,
                right, bottom, z + 0.002, color.r, color.g, color.b, color.a, 0, 0, 0,
                left, bottom, z + 0.002, color.r, color.g, color.b, color.a, 0, 0, 0
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

        -- Top border
        if borderTop and borderTop.width and borderTop.width > 0 and borderTop.style ~= "none" then
            addBorderQuad(x, y, width, borderTop.width, borderTop.color)
        end

        -- Bottom border
        if borderBottom and borderBottom.width and borderBottom.width > 0 and borderBottom.style ~= "none" then
            addBorderQuad(x, y + height - borderBottom.width, width, borderBottom.width, borderBottom.color)
        end

        -- Left border
        if borderLeft and borderLeft.width and borderLeft.width > 0 and borderLeft.style ~= "none" then
            addBorderQuad(x, y, borderLeft.width, height, borderLeft.color)
        end

        -- Right border
        if borderRight and borderRight.width and borderRight.width > 0 and borderRight.style ~= "none" then
            addBorderQuad(x + width - borderRight.width, y, borderRight.width, height, borderRight.color)
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

---@param element Element
---@param fontManager FontManager
local function convertTextElements(element, fontManager)
    if element.type == "text" then
        ---@type string
        local value = element.userdata

        local font = element.visualStyle.font or fontManager:getDefault()
        local fontBitmap = fontManager:getBitmap(font)
        local uvs = fontBitmap:getStringUVs(value)

        local children = {}
        for i = 1, #uvs do
            local quad = uvs[i]

            children[i] = Element.new("div")
                :withStyle({
                    bg = { r = 0.0, g = 0.0, b = 0.0, a = 1.0 },
                    bgImage = font,
                    bgImageUV = quad,
                    width = { abs = quad.width },
                    height = { abs = quad.height },
                })
        end

        return Element.new("div")
            :withStyle({ direction = "row", bg = { r = 0, g = 0, b = 0, a = 0 } })
            :withChildren(children)
    end

    if element.children then
        local newChildren = {}
        for _, child in ipairs(element.children) do
            table.insert(newChildren, convertTextElements(child, fontManager))
        end

        element.children = newChildren
    end

    return element
end

local Arisu = {}

---@generic T
---@generic Message
---@param cons fun(window: Window, textureManager: TextureManager, fontManager: FontManager): { view: fun(self: T, windowId: number): Element, update: fun(self: T, message: Message, windowId: number): Task?, event: fun(self: T, event: Event): Message }
function Arisu.runApp(cons)
    local eventLoop = window.EventLoop.new()
    local window = window.WindowBuilder.new()
        :withTitle("Arisu Application")
        :withSize(1280, 720)
        :build(eventLoop)

    local display = window.display

    local lastFrameTime = os.clock()
    local targetFPS = 144
    local frameTime = 1.0 / targetFPS

    local ctx = render.Context.new(display, window)
    if not ctx then
        window:destroy()
        x11.closeDisplay(display)
        error("Failed to create rendering context")
    end

    ctx:makeCurrent()

    local quadPipeline = Pipeline.new()
    quadPipeline:setProgram(gl.ShaderType.VERTEX, Program.new(gl.ShaderType.VERTEX, vertexShader))
    quadPipeline:setProgram(gl.ShaderType.FRAGMENT, Program.new(gl.ShaderType.FRAGMENT, fragmentShader))
    quadPipeline:bind()

    -- Crucial!!
    gl.enable(gl.BLEND)
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)

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
    local fontManager = FontManager.new(textureManager)

    -- Run the app constructor in the rendering context so they can initialize any
    -- GL resources they need.
    local app = cons(window, textureManager, fontManager)
    app.event = app.event or function(_) end

    local ui = app:view(window.id)
    ui = convertTextElements(ui, fontManager)
    local layoutTree = Layout.fromElement(ui)

    local runUpdate

    ---@param event Event
    local function runEvent(event)
        local message = app:event(event)
        if message then
            runUpdate(message)
        end
    end

    ---@param task Task?
    local function runTask(task)
        if not task then
            return
        end

        if task.variant == "refreshView" then
            ui = app:view(window.id)
            layoutTree = Layout.fromElement(ui)
        elseif task.variant == "windowOpen" then
            task.builder:build(eventLoop)
        elseif task.variant == "setTitle" then
            window:setTitle(task.to)
        end
    end

    function runUpdate(message, windowId)
        runTask(app:update(message, windowId))
    end

    local function draw()
        local computedLayout = layoutTree:solve(window.width, window.height)

        local vertices, indices = {}, {}
        generateLayoutQuads(computedLayout, 0, 0, vertices, indices, window.width, window.height)

        vertex:setData("f32", vertices)
        index:setData("u32", indices)

        textureManager:bind()
        vao:bind()
        gl.drawElements(gl.TRIANGLES, #indices, gl.UNSIGNED_INT, nil)

        ctx:swapBuffers()
    end

    eventLoop:run(function(event, handler)
        handler:setMode("poll")

        runEvent(event)

        if event.name == "deleteWindow" then
            -- Ensure we only exit if the main window is closed
            -- TODO: Maybe allow users to specify this behavior?
            if event.window.id == window.id then
                handler:exit()
            else
                eventLoop:close(event.window)
            end
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
                    runUpdate(el.onmousemove(event.x - layout.absX, event.y - layout.absY, layout.layout.width, layout.layout.height), window.id)
                end
            end
        elseif event.name == "mousePress" then
            local computedLayout = layoutTree:solve(window.width, window.height)

            local mouseDownElement = findElementAtPosition(ui, computedLayout, event.x, event.y, 0, 0, function(el)
                return el.onmousedown ~= nil
            end)

            if mouseDownElement then
                runUpdate(mouseDownElement.onmousedown, window.id)
            end
        elseif event.name == "mouseRelease" then
            local computedLayout = layoutTree:solve(window.width, window.height)
            local mouseUpElement = findElementAtPosition(ui, computedLayout, event.x, event.y, 0, 0, function(el)
                return el.onmouseup ~= nil
            end)

            if mouseUpElement then
                runUpdate(mouseUpElement.onmouseup, window.id)
            end
        elseif event.name == "redraw" then
            local currentTime = os.clock()
            local deltaTime = currentTime - lastFrameTime

            if deltaTime >= frameTime then
                draw()
                lastFrameTime = currentTime
            end
        end
    end)

    ctx:destroy()
end

return Arisu
