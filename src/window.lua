local x11 = require "src.bindings.x11"

--- @class Window
--- @field id number
--- @field display XDisplay
--- @field width number
--- @field height number
--- @field shouldRedraw boolean
local Window = {}
Window.__index = Window

function Window.new(display --[[@param display XDisplay]], id --[[@param id number]], width --[[@param width number]] , height --[[@param height number]])
    return setmetatable({ width = width, height = height, display = display, id = id }, Window)
end

--- @class WindowBuilder
--- @field width number
--- @field height number
--- @field title string
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

function WindowBuilder:build(eventLoop --[[@param eventLoop EventLoop]]) ---@return Window
    local display = eventLoop.display

    local root = x11.defaultRootWindow(display)
    if root == x11.None then
        x11.closeDisplay(display)
        error("No root window found")
    end

    local id = x11.createSimpleWindow(display, root, 0, 0, 800, 600, 0, 0, 0x000000)
    if id == x11.None then
        io.stderr:write("Failed to create window\n")
        x11.closeDisplay(display)
        return 1
    end

    x11.mapWindow(display, id)

    local window = Window.new(display, id, self.width, self.height)
    x11.setWMProtocols(display, window, {"WM_DELETE_WINDOW"})
    x11.selectInput(display, id, bit.bor(x11.ExposureMask, x11.StructureNotifyMask))
    eventLoop:register(window)

    return window
end

---@alias EventName "deleteWindow" | "aboutToWait" | "redraw" | "resize" | "map" | "unmap"
---@alias Event { window?: Window, name: EventName }

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

---@alias EventHandler { exit: fun(), requestRedraw: fun(self, window: Window), setMode: fun(self, mode: "poll" | "wait") }

function EventLoop:run(callback --[[@param callback fun(event: Event, handler: EventHandler)]])
    local display = self.display
    local event = x11.newEvent()

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
        assert(window ~= nil, "Received event for unregistered window")

        if event.type == x11.ClientMessage then
            callback({ window = window, name = "deleteWindow" }, handler)
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
