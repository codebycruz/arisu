local user32 = require("bindings.user32")
local kernel32 = require("bindings.kernel32")
local util = require("util")

---@class Win32Window: Window
---@field display user32.HDC
---@field id ffi.cdata*
---@field hwnd user32.HWND
---@field currentCursor number?
local Win32Window = {}
Win32Window.__index = Win32Window

---@param eventLoop Win32EventLoop
---@param width number
---@param height number
function Win32Window.new(eventLoop, width, height)
	local window = user32.createWindow(
		0,
		eventLoop.class.lpszClassName,
		"Title",
		bit.bor(user32.WS_VISIBLE, user32.WS_OVERLAPPEDWINDOW),
		user32.CW_USEDEFAULT,
		user32.CW_USEDEFAULT,
		width,
		height,
		nil,
		nil,
		eventLoop.class.hInstance,
		nil
	)

	if window == nil then
		error("Failed to create window: " .. kernel32.getLastErrorMessage())
	end

	user32.showWindow(window, user32.ShowWindow.SHOW)

	if not user32.updateWindow(window) then
		error("Failed to update window: " .. kernel32.getLastErrorMessage())
	end

	return setmetatable({ hwnd = window, id = util.toPointer(window), width = width, height = height }, Win32Window)
end

---@param image Image|nil
function Win32Window:setIcon(image)
	print("Warning: Win32Window:setIcon is unimplemented")
end

---@param shape "pointer" | "hand2"
function Win32Window:setCursor(shape)
	print("Warning: Win32Window:setCursor is unimplemented")
end

function Win32Window:resetCursor()
	print("Warning: Win32Window:resetCursor is unimplemented")
end

---@param title string
function Win32Window:setTitle(title)
	print("Warning: Win32Window:setTitle is unimplemented")
end

function Win32Window:destroy()
	print("Warning: Win32Window:destroy is unimplemented")
end

---@class Win32EventLoop: EventLoop
---@field class user32.WNDCLASSEXA
---@field isActive boolean
---@field currentMode "poll" | "wait"
---@field handler EventHandler
---@field callback fun(event: Event, handler: EventHandler)
local Win32EventLoop = {}
Win32EventLoop.__index = Win32EventLoop

function Win32EventLoop.new()
	local hInstance = kernel32.getModuleHandle(nil)
	if hInstance == nil then
		error("Failed to get module handle: " .. kernel32.getLastErrorMessage())
	end

	local class = user32.newWndClassEx()
	local self = setmetatable({ class = class, windows = {} }, Win32EventLoop)

	class.lpszClassName = "ArisuWindow"
	class.lpfnWndProc = user32.newWndProc(function(hwnd, msg, wParam, lParam)
		if not self.callback then
			return user32.defWindowProc(hwnd, msg, wParam, lParam)
		end

		local wnd = self.windows[util.toPointer(hwnd)]

		if msg == user32.WM_PAINT then
			self.callback({ name = "redraw", window = wnd }, self.handler)
			return 0
		elseif msg == user32.WM_SIZE then
			if wnd then
				wnd.width = bit.band(lParam, 0xFFFF)
				wnd.height = bit.rshift(lParam, 16)
			end
			self.callback({ name = "resize", window = wnd }, self.handler)
			return 0
		end

		return user32.defWindowProc(hwnd, msg, wParam, lParam)
	end)
	class.hCursor = user32.loadCursor(nil, user32.IDC_ARROW)
	class.hIcon = user32.loadIcon(nil, user32.IDI_APPLICATION)
	class.hbrBackground = user32.getSysColorBrush(user32.COLOR_WINDOW)
	class.style = bit.bor(user32.CS_HREDRAW, user32.CS_VREDRAW)

	class.hInstance = hInstance

	if user32.registerClass(class) == 0 then
		error("Failed to register window class: " .. kernel32.getLastErrorMessage())
	end

	local handler = {}
	do
		function handler.exit(_)
			self.isActive = false
		end

		function handler.setMode(_, mode)
			self.currentMode = mode
		end

		function handler.requestRedraw(_, window)
			window.shouldRedraw = true
		end
	end

	self.handler = handler

	return self
end

---@param window Win32Window
function Win32EventLoop:register(window)
	self.windows[window.id] = window
end

---@param window Win32Window
function Win32EventLoop:close(window)
	window:destroy()
	self.windows[window.id] = nil
end

---@param callback fun(event: Event, handler: EventHandler)
function Win32EventLoop:run(callback)
	self.isActive = true
	self.currentMode = "poll"
	self.callback = function(event, handler)
		local ok, err = pcall(callback, event, handler)
		if not ok then
			print("Error in event loop callback: " .. tostring(err))
		end

		return ok
	end

	local msg = user32.newMsg()
	while self.isActive do
		if self.currentMode == "poll" then
			while user32.peekMessage(msg, nil, 0, 0, user32.PM_REMOVE) do
				user32.translateMessage(msg)
				user32.dispatchMessage(msg)
			end
		else
			user32.getMessage(msg, nil, 0, 0)
			user32.translateMessage(msg)
			user32.dispatchMessage(msg)
		end

		for _, window in pairs(self.windows) do
			if window.shouldRedraw then
				window.shouldRedraw = false
				print("??")
				callback({ name = "redraw", window = window }, self.handler)
			end
		end

		callback({ name = "aboutToWait" }, self.handler)
	end
end

return { Window = Win32Window, EventLoop = Win32EventLoop }
