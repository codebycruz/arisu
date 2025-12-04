local x11 = require("bindings.x11")
local ffi = require("ffi")

---@class X11Window: Window
---@field display XDisplay
---@field currentCursor number?
local X11Window = {}
X11Window.__index = X11Window

---@param eventLoop X11EventLoop
---@param width number
---@param height number
function X11Window.new(eventLoop, width, height)
	local display = eventLoop.display

	local root = x11.defaultRootWindow(display)
	if root == x11.None then
		x11.closeDisplay(display)
		error("No root window found")
	end

	local id = x11.createSimpleWindow(display, root, 0, 0, width, height, 0, 0, 0x000000)
	if id == x11.None then
		x11.closeDisplay(display)
		error("Failed to create window")
	end

	local window = setmetatable({ display = display, id = id, width = width, height = height }, X11Window)

	x11.setWMProtocols(display, window, { "WM_DELETE_WINDOW" })
	x11.selectInput(
		display,
		window.id,
		bit.bor(
			x11.ExposureMask,
			x11.StructureNotifyMask,
			x11.SubstructureNotifyMask,
			x11.ButtonPressMask,
			x11.ButtonReleaseMask,
			x11.PointerMotionMask
		)
	)
	x11.mapWindow(display, window.id)

	return window
end

---@param image Image|nil
function X11Window:setIcon(image)
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

			iconData[i + 2] = bit.bor(bit.lshift(a, 24), bit.lshift(r, 16), bit.lshift(g, 8), b)
		end
	else -- RGB8 -> ARGB32 (assuming fully opaque)
		for i = 0, image.width * image.height - 1 do
			local r = pixels[i * 3 + 0]
			local g = pixels[i * 3 + 1]
			local b = pixels[i * 3 + 2]

			iconData[i + 2] = bit.bor(0xFF000000, bit.lshift(r, 16), bit.lshift(g, 8), b)
		end
	end

	x11.changeProperty(self.display, self.id, "_NET_WM_ICON", "CARDINAL", 32, 0, ffi.cast("unsigned char*", iconData),
		iconSize)
end

local cursors = {
	pointer = x11.XC_left_ptr,
	hand2 = x11.XC_hand2,
}

---@param shape "pointer" | "hand2"
function X11Window:setCursor(shape)
	if self.currentCursor then
		x11.freeCursor(self.display, self.currentCursor)
	end

	local cursor = x11.createFontCursor(self.display, cursors[shape])
	x11.defineCursor(self.display, self.id, cursor)
	self.currentCursor = cursor
end

function X11Window:resetCursor()
	if self.currentCursor then
		x11.freeCursor(self.display, self.currentCursor)
		self.currentCursor = nil
	end

	x11.undefineCursor(self.display, self.id)
end

---@param title string
function X11Window:setTitle(title)
	x11.changeProperty(self.display, self.id, "_NET_WM_NAME", "UTF8_STRING", 8, 0, title, #title)
	x11.flush(self.display)
end

function X11Window:destroy()
	if self.currentCursor then
		x11.freeCursor(self.display, self.currentCursor)
	end

	x11.destroyWindow(self.display, self.id)
end

---@class X11EventLoop: EventLoop
---@field display XDisplay
local X11EventLoop = {}
X11EventLoop.__index = X11EventLoop

function X11EventLoop.new()
	local display = x11.openDisplay(nil)
	if display == nil then
		error("Failed to open X11 display")
	end

	return setmetatable({ display = display, windows = {} }, X11EventLoop)
end

---@param window Window
function X11EventLoop:register(window)
	self.windows[tostring(window.id)] = window
end

---@param window Window
function X11EventLoop:close(window)
	window:destroy()
	self.windows[tostring(window.id)] = nil
end

---@param callback fun(event: Event, handler: EventHandler)
function X11EventLoop:run(callback)
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

	---@type table<number, fun(window: Window)>
	local Handlers = {
		[x11.MotionNotify] = function(window)
			callback({ window = window, name = "mouseMove", x = event.xmotion.x, y = event.xmotion.y }, handler)
		end,

		[x11.ClientMessage] = function(window)
			if event.xclient.data.l[0] == wmDeleteWindow then
				callback({ window = window, name = "windowClose" }, handler)
			end
		end,

		[x11.Expose] = function(window)
			callback({ window = window, name = "redraw" }, handler)
		end,

		[x11.DestroyNotify] = function(window) end,

		[x11.ConfigureNotify] = function(window)
			local newWidth = event.xconfigure.width
			local newHeight = event.xconfigure.height

			if newWidth ~= window.width or newHeight ~= window.height then
				window.width = newWidth
				window.height = newHeight
				callback({ window = window, name = "resize" }, handler)
			else -- Move event?
				-- Ignored for now
			end
		end,

		[x11.MapNotify] = function(window)
			callback({ window = window, name = "map" }, handler)
		end,

		[x11.UnmapNotify] = function(window)
			callback({ window = window, name = "unmap" }, handler)
		end,

		[x11.CreateNotify] = function(window)
			callback({ window = window, name = "create" }, handler)
		end,

		[x11.ButtonPress] = function(window)
			callback({
				window = window,
				name = "mousePress",
				x = event.xbutton.x,
				y = event.xbutton.y,
				button = event.xbutton.button,
			}, handler)
		end,

		[x11.ButtonRelease] = function(window)
			callback({
				window = window,
				name = "mouseRelease",
				x = event.xbutton.x,
				y = event.xbutton.y,
				button = event.xbutton.button,
			}, handler)
		end,
	}

	local function processEvent()
		local windowIdHash = tostring(event.xany.window)
		local window = self.windows[windowIdHash]

		local evtTypeHandler = Handlers[event.type]
		assert(evtTypeHandler, "Unhandled X11 event type: " .. tostring(event.type))

		evtTypeHandler(window)
	end

	local function coalesceMouse()
		if x11.pending(display) == 0 then
			return
		end

		local tempEvent = x11.newEvent()
		local hasMoreMotion = true

		while hasMoreMotion and x11.pending(display) > 0 do
			x11.peekEvent(display, tempEvent)
			if tempEvent.type == x11.MotionNotify and tempEvent.xmotion.window == event.xmotion.window then
				x11.nextEvent(display, event)
			else
				hasMoreMotion = false
			end
		end
	end

	local redrawEvent = { name = "redraw" }
	local aboutToWaitEvent = { name = "aboutToWait" }

	while isActive do
		if currentMode == "poll" then
			if x11.pending(display) > 0 then
				x11.nextEvent(display, event)
				if event.type == x11.MotionNotify then
					coalesceMouse()
				end

				processEvent()
			end
		else
			x11.nextEvent(display, event)
			if event.type == x11.MotionNotify then
				coalesceMouse()
			end

			processEvent()
		end

		for _, window in pairs(self.windows) do
			if window.shouldRedraw then
				window.shouldRedraw = false
				redrawEvent.window = window
				callback(redrawEvent, handler)
			end
		end

		callback(aboutToWaitEvent, handler)
	end
end

return { Window = X11Window, EventLoop = X11EventLoop }
