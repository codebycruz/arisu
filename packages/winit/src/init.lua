local util = require("arisu-util")

local windowBackend = util.isWindows() and require("winit.raw.win32") or require("winit.raw.x11")

---@class winit.Window
---@field id any?
---@field width number
---@field height number
---@field shouldRedraw boolean
---@field new fun(eventLoop: winit.EventLoop, width: number, height: number): winit.Window
---@field destroy fun(self: winit.Window)
---@field setTitle fun(self: winit.Window, title: string)
---@field setIcon fun(self: winit.Window, image: Image|nil)
---@field setCursor fun(self: winit.Window, shape: string)
---@field resetCursor fun(self: winit.Window)
local Window = windowBackend.Window

---@param eventLoop winit.EventLoop
function Window.fromEventLoop(eventLoop) ---@return winit.Window
	local window = Window.new(eventLoop, 1200, 720)
	eventLoop:register(window)
	return window
end

---@alias winit.Event
--- | { name: "aboutToWait" }
--- | { window: winit.Window, name: "windowClose" }
--- | { window: winit.Window, name: "redraw" }
--- | { window: winit.Window, name: "resize" }
--- | { window: winit.Window, name: "map" }
--- | { window: winit.Window, name: "create" }
--- | { window: winit.Window, name: "unmap" }
--- | { window: winit.Window, name: "mouseMove", x: number, y: number }
--- | { window: winit.Window, name: "mousePress", x: number, y: number, button: number }
--- | { window: winit.Window, name: "mouseRelease", x: number, y: number, button: number }

---@alias winit.EventLoopMode "poll" | "wait"

---@class winit.EventManager
---@field exit fun(self)
---@field close fun(self, window: winit.Window)
---@field requestRedraw fun(self, window: winit.Window)
---@field setMode fun(self, mode: winit.EventLoopMode)

---@alias winit.EventHandler fun(event: winit.Event, handler: winit.EventManager)

---@class winit.EventLoop
---@field windows table<string, winit.Window>
---@field new fun(): winit.EventLoop
---@field register fun(self: winit.EventLoop, window: winit.Window)
---@field close fun(self: winit.EventLoop, window: winit.Window)
---@field run fun(self: winit.EventLoop, callback: winit.EventHandler)
local EventLoop = windowBackend.EventLoop

return {
	EventLoop = EventLoop,
	Window = Window,
}
