local util = require("util")
local windowBackend = util.isWindows() and require("window.win32") or require("window.x11")

---@class Window
---@field id any?
---@field width number
---@field height number
---@field shouldRedraw boolean
---@field new fun(eventLoop: EventLoop, width: number, height: number): Window
---@field destroy fun(self: Window)
---@field setTitle fun(self: Window, title: string)
---@field setIcon fun(self: Window, image: Image|nil)
---@field setCursor fun(self: Window, shape: string)
---@field resetCursor fun(self: Window)
local Window = windowBackend.Window

---@param eventLoop EventLoop
function Window.fromEventLoop(eventLoop) ---@return Window
	local window = Window.new(eventLoop, 800, 600)
	eventLoop:register(window)
	return window
end

---@alias Event
--- | { name: "aboutToWait" }
--- | { window: Window, name: "windowClose" }
--- | { window: Window, name: "redraw" }
--- | { window: Window, name: "resize" }
--- | { window: Window, name: "map" }
--- | { window: Window, name: "create" }
--- | { window: Window, name: "unmap" }
--- | { window: Window, name: "mouseMove", x: number, y: number }
--- | { window: Window, name: "mousePress", x: number, y: number, button: number }
--- | { window: Window, name: "mouseRelease", x: number, y: number, button: number }

---@alias EventLoopMode "poll" | "wait"

---@class EventHandler
---@field exit fun(self)
---@field close fun(self, window: Window)
---@field requestRedraw fun(self, window: Window)
---@field setMode fun(self, mode: EventLoopMode)

---@class EventLoop
---@field windows table<string, Window>
---@field new fun(): EventLoop
---@field register fun(self: EventLoop, window: Window)
---@field close fun(self: EventLoop, window: Window)
---@field run fun(self: EventLoop, callback: fun(event: Event, handler: EventHandler))
local EventLoop = windowBackend.EventLoop

return {
	EventLoop = EventLoop,
	Window = Window,
}
