local gl = require "src.bindings.gl"
local glx = require "src.bindings.glx"
local x11 = require "src.bindings.x11"

local window = require "src.window"
local render = require "src.render"

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
    local eventLoop = window.EventLoop.new()
    local window = window.WindowBuilder.new()
        :withTitle("GLX Window")
        :withSize(800, 600)
        :build(eventLoop)

    local display = window.display

    local ctx = render.Context.new(display, window)
    if not ctx then
        window:destroy()
        x11.closeDisplay(display)
        return 1
    end

    eventLoop:run(function(event, handler)
        handler:setMode("poll")

        if event.name == "deleteWindow" then
            handler:exit()
        elseif event.name == "aboutToWait" then
            handler:requestRedraw(window)
        elseif event.name == "resize" then
            gl.viewport(0, 0, window.width, window.height)
        elseif event.name == "redraw" then
            ctx:makeCurrent()

            local time = os.clock()
            local hue = (time * 1000) % 360
            local r, g, b = hsvToRgb(hue, 0.8, 1.0)

            gl.clearColor(r, g, b, 1.0)
            gl.clear(gl.COLOR_BUFFER_BIT)

            ctx:swapBuffers()
        end
    end)

    ctx:destroy()
end

return main()
