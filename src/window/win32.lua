local user32 = require("bindings.user32")
local kernel32 = require("bindings.kernel32")
local ffi = require("ffi")

---@class Win32Window: Window
---@field display user32.HDC
---@field id user32.HWND
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

	return setmetatable({ id = window, width = width, height = height }, Win32Window)
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
local Win32EventLoop = {}
Win32EventLoop.__index = Win32EventLoop

function Win32EventLoop.new()
	local hInstance = kernel32.getModuleHandle(nil)
	if hInstance == nil then
		error("Failed to get module handle: " .. kernel32.getLastErrorMessage())
	end

	local class = user32.newWndClassEx()
	class.lpszClassName = "ArisuWindow"
	class.lpfnWndProc = user32.newWndProc(function(wnd, msg, w, l)
		print("class wnd proc...", wnd, msg, w, l)
		return user32.defWindowProc(wnd, msg, w, l)
	end)
	class.hCursor = user32.loadCursor(nil, user32.IDC_ARROW)
	class.hIcon = user32.loadIcon(nil, user32.IDI_APPLICATION)
	class.hbrBackground = user32.getSysColorBrush(user32.COLOR_WINDOW)
	class.style = bit.bor(user32.CS_HREDRAW, user32.CS_VREDRAW)

	class.hInstance = hInstance

	if user32.registerClass(class) == 0 then
		error("Failed to register window class: " .. kernel32.getLastErrorMessage())
	end

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

	local msg = user32.newMsg()
	while isActive do
		if currentMode == "poll" then
			while user32.peekMessage(msg, nil, 0, 0, user32.PM_REMOVE) do
				user32.translateMessage(msg)
				user32.dispatchMessage(msg)
			end
		else
			user32.getMessage(msg, nil, 0, 0)
			user32.translateMessage(msg)
			user32.dispatchMessage(msg)
		end

		callback({ name = "aboutToWait" }, handler)
	end
end

return { Window = Win32Window, EventLoop = Win32EventLoop }
