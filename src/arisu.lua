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

---@param element Element
---@param acceptFn? fun(element: Element): boolean
---@return { element: Element, layout: ComputedLayout, absX: number, absY: number }?
local function findElementAtPosition(element, layout, x, y, parentX, parentY, acceptFn)
    local absX = (parentX or 0) + (layout.x or 0)
    local absY = (parentY or 0) + (layout.y or 0)

    if x >= absX and x <= absX + layout.width and
       y >= absY and y <= absY + layout.height then

        if layout.children and element.children then
            for i, childLayout in ipairs(layout.children) do
                local found = findElementAtPosition(element.children[i], childLayout, x, y, absX, absY, acceptFn)
                if found and (not acceptFn or acceptFn(found.element)) then
                    return found
                end
            end
        end

        if not acceptFn or acceptFn(element) then
            return { element = element, layout = layout, absX = absX, absY = absY }
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

        -- INFO: This shouldn't cause any problems but who knows. maybe we'll use the old ui.
        element.type = "div"
        element.layoutStyle.direction = "row"
        element.children = children
        return element
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

local TARGET_FPS = 60
local FRAME_TIME = 1 / TARGET_FPS

---@class WindowContext
---@field vao VAO
---@field vertex Buffer
---@field index Buffer
---@field lastFrameTime number
---@field window Window
---@field renderCtx Context
---@field quadPipeline Pipeline
---@field ui Element
---@field layoutTree Layout
---@field computedLayout ComputedLayout
---@field nIndices number

---@generic T
---@generic Message
---@param cons fun(window: Window, textureManager: TextureManager, fontManager: FontManager): { view: fun(self: T, window: Window): Element, update: fun(self: T, message: Message, window: Window): Task?, event: fun(self: T, event: Event): Message }
function Arisu.runApp(cons)
    ---@type table<Window, WindowContext>
    local windowContexts = {}

    ---@type WindowContext
    local mainCtx

    local vertexProgram ---@type Program
    local fragmentProgram ---@type Program
    local samplers ---@type Uniform
    local textureDims ---@type UniformBlock
    local textureManager ---@type TextureManager
    local fontManager ---@type FontManager

    ---@param window Window
    ---@return WindowContext
    local function initWindow(window)
        local renderCtx = render.Context.new(window.display, window, mainCtx and mainCtx.renderCtx)
        if not renderCtx then
            window:destroy()
            x11.closeDisplay(window.display)
            error("Failed to create rendering context for window " .. tostring(window.id))
        end

        renderCtx:makeCurrent()
        renderCtx:setPresentMode("vsync")

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

        if not mainCtx then
            vertexProgram = Program.new(gl.ShaderType.VERTEX, vertexShader)
            fragmentProgram = Program.new(gl.ShaderType.FRAGMENT, fragmentShader)

            samplers = Uniform.new(fragmentProgram, "sampler2DArray", 0)
            textureDims = UniformBlock.new(0)
            textureManager = TextureManager.new(samplers, textureDims, 0)
            fontManager = FontManager.new(textureManager)
        end

        local quadPipeline = Pipeline.new()
        quadPipeline:setProgram(gl.ShaderType.VERTEX, vertexProgram)
        quadPipeline:setProgram(gl.ShaderType.FRAGMENT, fragmentProgram)

        local ctx = {
            vao = vao,
            vertex = vertex,
            index = index,
            window = window,
            lastFrameTime = -math.huge,
            quadPipeline = quadPipeline,
            renderCtx = renderCtx
        }

        windowContexts[window] = ctx
        return ctx
    end

    local eventLoop = window.EventLoop.new("wait")
    local mainWindow = window.WindowBuilder.new()
        :withTitle("Arisu Application")
        :withSize(1280, 720)
        :build(eventLoop)

    mainCtx = initWindow(mainWindow)
    mainCtx.renderCtx:makeCurrent()

    -- Run the app constructor in the rendering context so they can initialize any
    -- GL resources they need.
    local app = cons(mainWindow, textureManager, fontManager)
    app.event = app.event or function(_) end

    mainCtx.ui = app:view(mainWindow)
    mainCtx.ui = convertTextElements(mainCtx.ui, fontManager)
    mainCtx.layoutTree = Layout.fromElement(mainCtx.ui)
    mainCtx.computedLayout = mainCtx.layoutTree:solve(mainWindow.width, mainWindow.height)

    local vertices, indices = {}, {}
    generateLayoutQuads(mainCtx.computedLayout, 0, 0, vertices, indices, mainCtx.window.width, mainCtx.window.height)
    mainCtx.vertex:setData("f32", vertices)
    mainCtx.index:setData("u32", indices)
    mainCtx.nIndices = #indices

    local runUpdate

    ---@param event Event
    ---@param handler EventHandler
    local function runEvent(event, handler)
        local message = app:event(event)
        if message then
            runUpdate(message, handler)
        end
    end

    ---@param ctx WindowContext
    ---@param handler EventHandler
    local function refreshView(ctx, handler)
        ctx.ui = app:view(ctx.window)
        ctx.ui = convertTextElements(ctx.ui, fontManager)
        ctx.layoutTree = Layout.fromElement(ctx.ui)
        ctx.computedLayout = ctx.layoutTree:solve(ctx.window.width, ctx.window.height)

        local vertices, indices = {}, {}
        generateLayoutQuads(ctx.computedLayout, 0, 0, vertices, indices, ctx.window.width, ctx.window.height)
        ctx.vertex:setData("f32", vertices)
        ctx.index:setData("u32", indices)
        ctx.nIndices = #indices

        -- This is only necessary if we don't force a redraw on aboutToWait
        handler:requestRedraw(ctx.window)
    end

    ---@param task Task?
    ---@param handler EventHandler
    local function runTask(task, handler)
        if not task then
            return
        end

        if task.variant == "refreshView" then
            refreshView(windowContexts[task.window], handler)
        elseif task.variant == "redraw" then
            handler:requestRedraw(task.window)
        elseif task.variant == "windowOpen" then
            task.builder:build(eventLoop)
        elseif task.variant == "setTitle" then
            mainWindow:setTitle(task.to)
        elseif task.variant == "waitOnGPU" then
            local ctx = windowContexts[task.window]
            ctx.renderCtx:makeCurrent()
            gl.finish()
        elseif task.variant == "closeWindow" then
            windowContexts[task.window] = nil
            eventLoop:close(task.window)
        elseif task.variant == "chain" then
            for _, subtask in ipairs(task.tasks) do
                runTask(subtask, handler)
            end
        end
    end

    ---@param handler EventHandler
    ---@param window Window
    function runUpdate(message, window, handler)
        runTask(app:update(message, window), handler)
    end

    ---@param ctx WindowContext
    local function draw(ctx)
        ctx.renderCtx:makeCurrent()

        gl.enable(gl.BLEND)
        gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)

        gl.viewport(0, 0, ctx.window.width, ctx.window.height)

        ctx.quadPipeline:bind()

        textureManager:bind()
        ctx.vao:bind()
        gl.drawElements(gl.TRIANGLES, ctx.nIndices, gl.UNSIGNED_INT, nil)

        ctx.renderCtx:present()
    end

    eventLoop:run(function(event, handler)
        runEvent(event, handler)

        local eventName = event.name
        if eventName == "redraw" then
            local ctx = windowContexts[event.window]
            draw(ctx)
        elseif eventName == "windowClose" then
            -- Ensure we only exit if the main window is closed
            -- TODO: Maybe allow users to specify this behavior?
            if event.window.id == mainWindow.id then
                handler:exit()
            else
                -- TODO: Figure out proper resource cleanup
                -- windowContexts[event.window].renderCtx:destroy()
                windowContexts[event.window] = nil
                eventLoop:close(event.window)
            end
        elseif eventName == "resize" then
            local ctx = windowContexts[event.window]
            ctx.renderCtx:makeCurrent()
            gl.viewport(0, 0, ctx.window.width, ctx.window.height)
        elseif eventName == "mouseMove" then
            local ctx = windowContexts[event.window]

            ---@type table<Element, {layout: ComputedLayout, absX: number, absY: number}>
            local hoveredElements = {}
            findElementsAtPosition(ctx.ui, ctx.computedLayout, event.x, event.y, 0, 0, hoveredElements)

            local anyWithMouseDown = false
            for el, _ in pairs(hoveredElements) do
                if el.onmousedown then
                    anyWithMouseDown = true
                    break
                end
            end

            if anyWithMouseDown then
                ctx.window:setCursor("hand2")
            else
                ctx.window:resetCursor()
            end

            for el, layout in pairs(hoveredElements) do
                if el.onmousemove then
                    local relX = event.x - layout.absX
                    local relY = event.y - layout.absY
                    runUpdate(el.onmousemove(relX, relY, layout.layout.width, layout.layout.height), ctx.window, handler)
                end
            end
        elseif eventName == "mousePress" then
            local ctx = windowContexts[event.window]
            local info = findElementAtPosition(ctx.ui, ctx.computedLayout, event.x, event.y, 0, 0, function(el)
                return el.onmousedown ~= nil
            end)

            if info then
                local relX = event.x - info.absX
                local relY = event.y - info.absY
                runUpdate(info.element.onmousedown(relX, relY, info.layout.width, info.layout.height), ctx.window, handler)
            end
        elseif eventName == "mouseRelease" then
            local ctx = windowContexts[event.window]
            local info = findElementAtPosition(ctx.ui, ctx.computedLayout, event.x, event.y, 0, 0, function(el)
                return el.onmouseup ~= nil
            end)

            if info then
                runUpdate(info.element.onmouseup, ctx.window, handler)
            end
        elseif eventName == "map" then
            if not windowContexts[event.window] then
                initWindow(event.window)
            end

            refreshView(windowContexts[event.window], handler)
        end
    end)

    mainCtx.renderCtx:destroy()
end

return Arisu
