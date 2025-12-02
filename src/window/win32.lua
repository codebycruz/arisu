local win32 = require("bindings.win32")
local ffi = require("ffi")

---@class Win32Window: Window
---@field private display XDisplay
---@field private currentCursor number?
local Win32Window = {}
Win32Window.__index = Win32Window

---@param eventLoop Win32EventLoop
---@param width number
---@param height number
function Win32Window.new(eventLoop, width, height)
	local window = win32.createWindow(
		eventLoop.class.lpszClassName,
		"Title",
		bit.bor(win32.WS_BORDER, win32.WS_CAPTION, win32.WS_SYSMENU, win32.WS_THICKFRAME),
		win32.CW_USEDEFAULT,
		win32.CW_USEDEFAULT,
		width,
		height,
		nil,
		nil,
		eventLoop.class.hInstance,
		nil
	)

	win32.showWindow(window, win32.ShowWindow.SHOW)
	win32.updateWindow(window)

	return setmetatable({ id = window, width = width, height = height }, Win32Window)
end

---@param image Image|nil
function Win32Window:setIcon(image)
	error("Unimplemented")
end

---@param shape "pointer" | "hand2"
function Win32Window:setCursor(shape)
	error("Unimplemented")
end

function Win32Window:resetCursor()
	error("Unimplemented")
end

---@param title string
function Win32Window:setTitle(title)
	error("Unimplemented")
end

function Win32Window:destroy()
	error("Unimplemented")
end

---@class Win32EventLoop: EventLoop
---@field class WNDCLASSEXA
local Win32EventLoop = {}
Win32EventLoop.__index = Win32EventLoop

function Win32EventLoop.new()
	local hInstance = win32.GetModuleHandleA(nil)

	local class = win32.newWndClassEx()
	class.lpszClassName = "ArisuWindow"
	class.lpfnWndProc = win32.newWndProc(function(wnd, msg, w, l)
		print("class wnd proc...", wnd, msg, w, l)
		return 0
	end)
	class.hInstance = hInstance

	win32.registerClass(class)

	return setmetatable({ class = class, windows = {} }, Win32EventLoop)
end

---@param window Win32Window
function Win32EventLoop:register(window)
	self.windows[tostring(window.id)] = window
end

---@param window Win32Window
function Win32EventLoop:close(window)
	window:destroy()
	self.windows[tostring(window.id)] = nil
end

---@param callback fun(event: Event, handler: EventHandler)
function Win32EventLoop:run(callback)
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

	local msg = win32.newMsg()
	while isActive do
		if currentMode == "poll" then
			while win32.peekMessage(msg, nil, 0, 0, win32.PM_REMOVE) do
				win32.translateMessage(msg)
				win32.dispatchMessageA(msg)
			end
		else
			win32.getMessage(msg, nil, 0, 0)
			win32.translateMessage(msg)
			win32.dispatchMessageA(msg)
		end
	end
end

return { Window = Win32Window, EventLoop = Win32EventLoop }
