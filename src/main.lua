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

local Layout = require "src.layout"

local vertexShader = io.open("src/shaders/main.vert.glsl", "r"):read("*a")
local fragmentShader = io.open("src/shaders/main.frag.glsl", "r"):read("*a")

local function hsvToRgb(h, s, v)
    local c = v * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - c

    local r, g, b
    if h < 60 then
        r, g, b = c, x, 0
    elseif h < 120 then
        r, g, b = x, c, 0
    elseif h < 180 then
        r, g, b = 0, c, x
    elseif h < 240 then
        r, g, b = 0, x, c
    elseif h < 300 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end

    return r + m, g + m, b + m
end

local function main()
    local x = Layout.new()
        :withSize(512, 512)
        :withDirection("column")
        :withChildren(
            Layout.new()
                :withSize(256, 256),
            Layout.new()
                :withSize(256, 256)
        )
        :solve(1280, 720)

    local eventLoop = window.EventLoop.new()
    local window = window.WindowBuilder.new()
        :withTitle("GLX Window")
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
        :withAttribute({ type = "f32", size = 3, offset = 0 }) -- pos

    local vertex = Buffer.new()
    vertex:setData("f32", {
         0.5,  0.5, 0.0,
         0.5, -0.5, 0.0,
        -0.5, -0.5, 0.0,
        -0.5,  0.5, 0.0,
    })

    local index = Buffer.new()
    index:setData("u32", {
        0, 1, 3,
        1, 2, 3,
    })

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
                local time = currentTime
                local hue = (time * 1000) % 360
                local r, g, b = hsvToRgb(hue, 0.8, 1.0)

                gl.clearColor(r, g, b, 1.0)
                gl.clear(gl.COLOR_BUFFER_BIT)

                vao:bind()
                gl.drawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, nil)

                ctx:swapBuffers()
                lastFrameTime = currentTime
            end
        end
    end)

    ctx:destroy()
end

return main()
