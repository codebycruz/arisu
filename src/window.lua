local x11 = require "src.bindings.x11"
local ffi = require "ffi"

--- @class Window
--- @field id number
--- @field display XDisplay
--- @field width number
--- @field height number
--- @field shouldRedraw boolean
--- @field currentCursor number?
local Window = {}
Window.__index = Window

function Window.new(display --[[@param display XDisplay]], id --[[@param id number]], width --[[@param width number]] , height --[[@param height number]])
    return setmetatable({ width = width, height = height, display = display, id = id, currentCursor = nil }, Window)
end

function Window:destroy()
    if self.currentCursor then
        x11.freeCursor(self.display, self.currentCursor)
    end

    x11.destroyWindow(self.display, self.id)
end

function Window:setTitle(title --[[@param title string]])
    x11.changeProperty(self.display, self.id, "_NET_WM_NAME", "UTF8_STRING", 8, 0, title, #title)
    x11.flush(self.display)
end

function Window:setIcon(image --[[@param image Image|nil]])
    if image == nil then
        return
    end

    local iconSize = 2 + (image.width * image.height)
    local iconData = ffi.new("uint32_t[?]", iconSize)

    iconData[0] = image.width
    iconData[1] = image.height

    local pixels = ffi.cast("uint8_t*", image.pixels)

    if image.channels == 4 then -- RGBA8 -> ARGB32
        for i = 0, image.width * image.height - 1 do
            local r = pixels[i * 4 + 0]
            local g = pixels[i * 4 + 1]
            local b = pixels[i * 4 + 2]
            local a = pixels[i * 4 + 3]

            iconData[i + 2] = bit.lshift(a, 24) + bit.lshift(r, 16) + bit.lshift(g, 8) + b
        end
    else -- RGB8 -> ARGB32 (assuming fully opaque)
        for i = 0, image.width * image.height - 1 do
            local r = pixels[i * 3 + 0]
            local g = pixels[i * 3 + 1]
            local b = pixels[i * 3 + 2]

            iconData[i + 2] = 0xFF000000 + bit.lshift(r, 16) + bit.lshift(g, 8) + b
        end
    end

    x11.changeProperty(self.display, self.id, "_NET_WM_ICON", "CARDINAL", 32, 0, ffi.cast("unsigned char*", iconData), iconSize)
end

local cursors = {
    pointer = x11.XC_left_ptr,
    hand2 = x11.XC_hand2,
}

---@param shape "pointer" | "hand2"
function Window:setCursor(shape)
    if self.currentCursor then
        x11.freeCursor(self.display, self.currentCursor)
    end

    local cursor = x11.createFontCursor(self.display, cursors[shape])
    x11.defineCursor(self.display, self.id, cursor)
    self.currentCursor = cursor
end

function Window:resetCursor()
    if self.currentCursor then
        x11.freeCursor(self.display, self.currentCursor)
        self.currentCursor = nil
    end

    x11.undefineCursor(self.display, self.id)
end

--- @class WindowBuilder
--- @field width number
--- @field height number
--- @field title string
--- @field icon Image|nil
local WindowBuilder = {}
WindowBuilder.__index = WindowBuilder

function WindowBuilder.new()
    return setmetatable({ width = 800, height = 600, title = "Untitled Window" }, WindowBuilder)
end

function WindowBuilder:withTitle(title)
    self.title = title
    return self
end

function WindowBuilder:withSize(width, height)
    self.width = width
    self.height = height
    return self
end

function WindowBuilder:withIcon(iconData)
    self.icon = iconData
    return self
end

function WindowBuilder:build(eventLoop --[[@param eventLoop EventLoop]]) ---@return Window
    local display = eventLoop.display

    local root = x11.defaultRootWindow(display)
    if root == x11.None then
        x11.closeDisplay(display)
        error("No root window found")
    end

    local id = x11.createSimpleWindow(display, root, 0, 0, self.width, self.height, 0, 0, 0x000000)
    if id == x11.None then
        io.stderr:write("Failed to create window\n")
        x11.closeDisplay(display)
        return 1
    end

    x11.mapWindow(display, id)

    local window = Window.new(display, id, self.width, self.height)
    window:setTitle(self.title)
    window:setIcon(self.icon)
    x11.setWMProtocols(display, window, {"WM_DELETE_WINDOW"})
    x11.selectInput(display, id, bit.bor(x11.ExposureMask, x11.StructureNotifyMask, x11.ButtonPressMask, x11.ButtonReleaseMask, x11.PointerMotionMask))
    eventLoop:register(window)

    return window
end

---@alias Event
--- | { name: "deleteWindow" }
--- | { name: "aboutToWait" }
--- | { window: Window, name: "redraw" }
--- | { window: Window, name: "resize" }
--- | { window: Window, name: "map" }
--- | { window: Window, name: "unmap" }
--- | { window: Window, name: "mouseMove", x: number, y: number }
--- | { window: Window, name: "mousePress", x: number, y: number, button: number }
--- | { window: Window, name: "mouseRelease", x: number, y: number, button: number }

---@class EventLoopHandler
local EventLoopHandler = {}

--- @class EventLoop
--- @field display XDisplay
--- @field windows table<number, Window>
local EventLoop = {}
EventLoop.__index = EventLoop

function EventLoop.new()
    local display = x11.openDisplay(nil)
    if display == nil then
        error("Failed to open X11 display")
    end

    return setmetatable({ display = display, windows = {} }, EventLoop)
end

function EventLoop:register(window --[[@param window Window]])
    self.windows[tostring(window.id)] = window
end

function EventLoop:close(window --[[@param window Window]])
    window:destroy()
    self.windows[tostring(window.id)] = nil
end

---@alias EventHandler { exit: fun(), requestRedraw: fun(self, window: Window), setMode: fun(self, mode: "poll" | "wait") }

function EventLoop:run(callback --[[@param callback fun(event: Event, handler: EventHandler)]])
    local display = self.display
    local event = x11.newEvent()

    local wmDeleteWindow = x11.internAtom(display, "WM_DELETE_WINDOW", 0)

    local isActive = true
    local currentMode = "poll"

    local handler = {}
    do
        function handler:exit()
            isActive = false
        end

        function handler:setMode(mode)
            currentMode = mode
        end

        function handler:requestRedraw(window)
            window.shouldRedraw = true
        end
    end

    local function processEvent()
        local windowIdHash = tostring(event.xany.window)
        local window = self.windows[windowIdHash]

        if event.type == x11.ClientMessage then
            if event.xclient.data.l[0] == wmDeleteWindow then
                callback({ window = window, name = "deleteWindow" }, handler)
            end
        elseif event.type == x11.Expose then
            callback({ window = window, name = "redraw" }, handler)
        elseif event.type == x11.DestroyNotify then
            self.windows[windowIdHash] = nil
        elseif event.type == x11.ConfigureNotify then
            local newWidth = event.xconfigure.width
            local newHeight = event.xconfigure.height

            if newWidth ~= window.width or newHeight ~= window.height then
                window.width = newWidth
                window.height = newHeight
                callback({ window = window, name = "resize" }, handler)
            else -- Move event?
                -- Ignored for now
            end

        elseif event.type == x11.MapNotify then
            callback({ window = window, name = "map" }, handler)
        elseif event.type == x11.UnmapNotify then
            callback({ window = window, name = "unmap" }, handler)
        elseif event.type == x11.MotionNotify then
            callback({ window = window, name = "mouseMove", x = event.xmotion.x, y = event.xmotion.y }, handler)
        elseif event.type == x11.ButtonPress then
            callback({ window = window, name = "mousePress", x = event.xbutton.x, y = event.xbutton.y, button = event.xbutton.button }, handler)
        elseif event.type == x11.ButtonRelease then
            callback({ window = window, name = "mouseRelease", x = event.xbutton.x, y = event.xbutton.y, button = event.xbutton.button }, handler)
        else
            print("unhandled event type:", event.type)
        end
    end

    while isActive do
        if currentMode == "poll" then
            if x11.pending(display) > 0 then
                x11.nextEvent(display, event)
                processEvent()
            end
        else
            x11.nextEvent(display, event)
            processEvent()
        end

        for _, window in pairs(self.windows) do
            if window.shouldRedraw then
                window.shouldRedraw = false
                callback({ window = window, name = "redraw" }, handler)
            end
        end

        callback({ name = "aboutToWait" }, handler)
    end
end

return {
    WindowBuilder = WindowBuilder,
    EventLoop = EventLoop,
    Window = Window,
}
