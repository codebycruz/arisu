local UILayout = require("arisu-layout.layout")

---@param element arisu.Element
---@param acceptFn? fun(element: arisu.Element): boolean
---@return { element: arisu.Element, layout: arisu.ComputedLayout, absX: number, absY: number }?
local function findElementAtPosition(element, layout, x, y, parentX, parentY, acceptFn)
	local absX = (parentX or 0) + (layout.x or 0)
	local absY = (parentY or 0) + (layout.y or 0)

	-- Always recurse into children: relative-positioned children may extend outside parent bounds
	if layout.children and element.children then
		for i, childLayout in ipairs(layout.children) do
			local found = findElementAtPosition(element.children[i], childLayout, x, y, absX, absY, acceptFn)
			if found and (not acceptFn or acceptFn(found.element)) then
				return found
			end
		end
	end

	if (x >= absX and x <= absX + layout.width) and (y >= absY and y <= absY + layout.height) then
		if not acceptFn or acceptFn(element) then
			return { element = element, layout = layout, absX = absX, absY = absY }
		end
	end

	return nil
end

---@param element arisu.Element
---@param layout arisu.ComputedLayout
---@param results table<arisu.Element, { layout: arisu.ComputedLayout, absX: number, absY: number }>
local function findElementsAtPosition(element, layout, x, y, parentX, parentY, results)
	local absX = (parentX or 0) + (layout.x or 0)
	local absY = (parentY or 0) + (layout.y or 0)

	if (x >= absX and x <= absX + layout.width) and (y >= absY and y <= absY + layout.height) then
		results[element] = { layout = layout, absX = absX, absY = absY }
	end

	-- Always recurse: relative-positioned children may extend outside parent bounds
	if layout.children and element.children then
		for i, childLayout in ipairs(layout.children) do
			findElementsAtPosition(element.children[i], childLayout, x, y, absX, absY, results)
		end
	end
end

---@class arisu.plugin.Layout.Context
---@field window winit.Window
---@field ui arisu.Element?
---@field computedLayout arisu.ComputedLayout?
---@field focusedId string?
---@field cursorPos number

---@class arisu.plugin.Layout
---@field textPlugin arisu.plugin.Text
---@field view fun(window: winit.Window): arisu.Element
---@field contexts table<winit.Window, arisu.plugin.Layout.Context>
local Layout = {}
Layout.__index = Layout

---@param view fun(window: winit.Window): arisu.Element
---@param textPlugin arisu.plugin.Text
function Layout.new(view, textPlugin) ---@return arisu.plugin.Layout
	return setmetatable({ view = view, contexts = {}, textPlugin = textPlugin }, Layout)
end

---@param window winit.Window
function Layout:register(window)
	self.contexts[window] = { window = window, focusedId = nil, cursorPos = 0 }
	self:refreshView(window)
end

---@param window winit.Window
---@return string?
function Layout:getFocusedId(window)
	local ctx = self.contexts[window]
	return ctx and ctx.focusedId
end

---@param window winit.Window
---@return number
function Layout:getCursorPos(window)
	local ctx = self.contexts[window]
	return ctx and ctx.cursorPos or 0
end

---@param window winit.Window
---@param id string?
function Layout:setFocus(window, id)
	local ctx = self.contexts[window]
	if not ctx then return end
	ctx.focusedId = id
	ctx.cursorPos = 0
end

---@param window winit.Window
function Layout:refreshView(window)
	local ctx = self.contexts[window]
	ctx.ui = self.textPlugin:convertTextElements(self.view(window))
	local layout = UILayout.fromElement(ctx.ui)
	ctx.computedLayout = layout:solve(ctx.window.width, ctx.window.height)
	return ctx.computedLayout
end

local function hasMouseUp(e) ---@param e arisu.Element
	return e.onmouseup ~= nil
end

local function hasMouseDownOrClick(e) ---@param e arisu.Element
	return e.isTextInput or e.onmousedown ~= nil or e.onclick ~= nil or e.ondblclick ~= nil
end

---@param element arisu.Element
---@param id string
---@return arisu.Element?
local function findElementById(element, id)
	if element.id == id then return element end
	if element.children then
		for _, child in ipairs(element.children) do
			local found = findElementById(child, id)
			if found then return found end
		end
	end
	return nil
end

local DOUBLE_CLICK_THRESHOLD = 0.3 -- seconds

---@param event winit.Event
---@return Message?
function Layout:event(event)
	if event.name == "mouseMove" then
		local ctx = self.contexts[event.window]
		if not ctx then return end

		---@type table<arisu.Element, {layout: arisu.ComputedLayout, absX: number, absY: number}>
		local hoveredElements = {}
		findElementsAtPosition(ctx.ui, ctx.computedLayout, event.x, event.y, 0, 0, hoveredElements)

		local anyWithMouseDown = false
		for el, _ in pairs(hoveredElements) do
			if el.isTextInput or el.onmousedown or el.onclick then
				anyWithMouseDown = true
				break
			end
		end

		if anyWithMouseDown then
			ctx.window:setCursor("hand2")
		else
			ctx.window:resetCursor()
		end

		for el, layout in pairs(hoveredElements) do
			if el.onmousemove then
				local relX = event.x - layout.absX
				local relY = event.y - layout.absY
				return el.onmousemove(relX, relY, layout.layout.width, layout.layout.height)
			end
		end
	elseif event.name == "mousePress" then
		local ctx = self.contexts[event.window]
		local info = findElementAtPosition(ctx.ui, ctx.computedLayout, event.x, event.y, 0, 0, hasMouseDownOrClick)

		-- Update focus: set on text input click, clear otherwise
		if info and info.element.isTextInput then
			ctx.focusedId = info.element.id
			ctx.cursorPos = #(info.element.inputValue or "")
		else
			ctx.focusedId = nil
			ctx.cursorPos = 0
		end

		if info then
			local now = os.clock()
			local isDblClick = info.element.ondblclick
				and ctx.lastPressElement == info.element
				and ctx.lastPressTime
				and (now - ctx.lastPressTime) <= DOUBLE_CLICK_THRESHOLD
				and ctx.lastPressX == event.x
				and ctx.lastPressY == event.y

			ctx.lastPressElement = info.element
			ctx.lastPressTime = now
			ctx.lastPressX = event.x
			ctx.lastPressY = event.y

			if isDblClick then
				ctx.lastPressElement = nil
				ctx.lastPressTime = nil
				return info.element.ondblclick
			end

			if info.element.onclick then
				return info.element.onclick
			end

			if info.element.onmousedown then
				local relX = event.x - info.absX
				local relY = event.y - info.absY
				return info.element.onmousedown(relX, relY, info.layout.width, info.layout.height)
			end
		end
	elseif event.name == "keyPress" then
		local ctx = self.contexts[event.window]
		if ctx and ctx.focusedId then
			local element = findElementById(ctx.ui, ctx.focusedId)
			if element and element.isTextInput then
				local value = element.inputValue or ""
				local cursor = ctx.cursorPos
				local key = event.key

				if key == "escape" then
					ctx.focusedId = nil
					ctx.cursorPos = 0
					return { type = "_inputRefresh" }
				elseif key == "return" then
					if element.onsubmit then
						return element.onsubmit(value)
					end
				elseif key == "backspace" then
					if cursor > 0 then
						value = value:sub(1, cursor - 1) .. value:sub(cursor + 1)
						ctx.cursorPos = cursor - 1
						if element.oninput then return element.oninput(value) end
					end
				elseif key == "delete" then
					if cursor < #value then
						value = value:sub(1, cursor) .. value:sub(cursor + 2)
						if element.oninput then return element.oninput(value) end
					end
				elseif key == "left" then
					ctx.cursorPos = math.max(0, cursor - 1)
					return { type = "_inputRefresh" }
				elseif key == "right" then
					ctx.cursorPos = math.min(#value, cursor + 1)
					return { type = "_inputRefresh" }
				elseif key == "home" then
					ctx.cursorPos = 0
					return { type = "_inputRefresh" }
				elseif key == "end" then
					ctx.cursorPos = #value
					return { type = "_inputRefresh" }
				elseif event.modifiers and event.modifiers.ctrl then
					if key == "a" or key:byte(1) == 1 then
						ctx.cursorPos = #value
						return { type = "_inputRefresh" }
					end
				elseif #key == 1 and key:byte(1) >= 32 then
					value = value:sub(1, cursor) .. key .. value:sub(cursor + 1)
					ctx.cursorPos = cursor + 1
					if element.oninput then return element.oninput(value) end
				end
			end
		end
	elseif event.name == "mouseRelease" then
		local ctx = self.contexts[event.window]
		local info = findElementAtPosition(ctx.ui, ctx.computedLayout, event.x, event.y, 0, 0, hasMouseUp)

		if info then
			local relX = event.x - info.absX
			local relY = event.y - info.absY
			return info.element.onmouseup(relX, relY, info.layout.width, info.layout.height)
		end
	end
end

return Layout
