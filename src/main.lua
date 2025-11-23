local gl = require "src.gl"
local glx = require "src.glx"
local x11 = require "src.x11"
local ffi = require "ffi"

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

local isActive = true
local function onDelete(display, window)
    x11.destroyWindow(display, window)
    isActive = false
end

local function main()
    local display = x11.openDisplay(nil)
    if display == nil then
        io.stderr:write("Failed to initialize display\n")
        return 1
    end

    local root = x11.defaultRootWindow(display)
    if root == x11.None then
        io.stderr:write("No root window found\n")
        x11.closeDisplay(display)
        return 1
    end

    local screen = x11.defaultScreen(display)

    local attribs = ffi.new("int[7]", {
        glx.GLX_RGBA,
        glx.GLX_DEPTH_SIZE, 16,
        glx.GLX_DOUBLEBUFFER,
        0
    })

    local visual = glx.chooseVisual(display, screen, attribs)
    if visual == nil then
        io.stderr:write("Failed to choose visual\n")
        x11.closeDisplay(display)
        return 1
    end

    local window = x11.createSimpleWindow(display, root, 0, 0, 800, 600, 0, 0, 0x000000)
    if window == x11.None then
        io.stderr:write("Failed to create window\n")
        x11.closeDisplay(display)
        return 1
    end

    local ctx = glx.createContext(display, visual, nil, 1)
    if ctx == nil then
        io.stderr:write("Failed to create GLX context\n")
        x11.destroyWindow(display, window)
        x11.closeDisplay(display)
        return 1
    end

    x11.mapWindow(display, window)

    if glx.makeCurrent(display, window, ctx) == 0 then
        io.stderr:write("Failed to make GLX context current\n")
        x11.destroyWindow(display, window)
        x11.closeDisplay(display)
        return 1
    end



    local wm_delete_window = x11.internAtom(display, "WM_DELETE_WINDOW", x11.False)
    local protocols = x11.newAtomArray(1)
    protocols[0] = wm_delete_window
    x11.setWMProtocols(display, window, protocols, 1)

    local event = x11.newEvent()
    while isActive do
        while x11.pending(display) > 0 do
            x11.nextEvent(display, event)

            if event.type == x11.ClientMessage then
                if event.xclient.data.l[0] == wm_delete_window then
                    onDelete(event.xclient.display, event.xclient.window)
                end
            end
        end

        local time = os.clock()
        local hue = (time * 1000) % 360
        local r, g, b = hsvToRgb(hue, 0.8, 1.0)

        gl.clearColor(r, g, b, 1.0)
        gl.clear(0x4000)
        glx.swapBuffers(display, window)
    end

    x11.closeDisplay(display)
    return 0
end

return main()
