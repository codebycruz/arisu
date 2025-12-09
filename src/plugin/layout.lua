local UILayout = require("ui.layout")

---@param element Element
---@param acceptFn? fun(element: Element): boolean
---@return { element: Element, layout: ComputedLayout, absX: number, absY: number }?
local function findElementAtPosition(element, layout, x, y, parentX, parentY, acceptFn)
	local absX = (parentX or 0) + (layout.x or 0)
	local absY = (parentY or 0) + (layout.y or 0)

	if (x >= absX and x <= absX + layout.width) and (y >= absY and y <= absY + layout.height) then
		if layout.children and element.children then
			for i, childLayout in ipairs(layout.children) do
				local found = findElementAtPosition(element.children[i], childLayout, x, y, absX, absY, acceptFn)
				if found and (not acceptFn or acceptFn(found.element)) then
					return found
				end
			end
		end

		if not acceptFn or acceptFn(element) then
			return { element = element, layout = layout, absX = absX, absY = absY }
		end
	end

	return nil
end

---@param element Element
---@param layout ComputedLayout
---@param results table<Element, { layout: ComputedLayout, absX: number, absY: number }>
local function findElementsAtPosition(element, layout, x, y, parentX, parentY, results)
	local absX = (parentX or 0) + (layout.x or 0)
	local absY = (parentY or 0) + (layout.y or 0)

	if (x >= absX and x <= absX + layout.width) and (y >= absY and y <= absY + layout.height) then
		results[element] = { layout = layout, absX = absX, absY = absY }

		if layout.children and element.children then
			for i, childLayout in ipairs(layout.children) do
				findElementsAtPosition(element.children[i], childLayout, x, y, absX, absY, results)
			end
		end
	end
end

---@class plugin.Layout.Context
---@field window Window
---@field ui Element?
---@field computedLayout ComputedLayout?

---@class plugin.Layout
---@field textPlugin plugin.Text
---@field view fun(window: Window): Element
---@field contexts table<Window, plugin.Layout.Context>
local Layout = {}
Layout.__index = Layout

---@param view fun(window: Window): Element
---@param textPlugin plugin.Text
function Layout.new(view, textPlugin) ---@return plugin.Layout
	return setmetatable({ view = view, contexts = {}, textPlugin = textPlugin }, Layout)
end

---@param window Window
function Layout:register(window)
	self.contexts[window] = { window = window }
	self:refreshView(window)
end

---@param window Window
function Layout:refreshView(window)
	local ctx = self.contexts[window]
	ctx.ui = self.textPlugin:convertTextElements(self.view(window))
	local layout = UILayout.fromElement(ctx.ui)
	ctx.computedLayout = layout:solve(ctx.window.width, ctx.window.height)
	return ctx.computedLayout
end

local function hasMouseUp(e) ---@param e Element
	return e.onmouseup ~= nil
end

local function hasMouseDownOrClick(e) ---@param e Element
	return e.onmousedown ~= nil or e.onclick ~= nil
end

---@param event Event
---@param handler EventHandler
---@return Message?
function Layout:event(event, handler)
	if event.name == "mouseMove" then
		local ctx = self.contexts[event.window]
		if not ctx then return end

		---@type table<Element, {layout: ComputedLayout, absX: number, absY: number}>
		local hoveredElements = {}
		findElementsAtPosition(ctx.ui, ctx.computedLayout, event.x, event.y, 0, 0, hoveredElements)

		local anyWithMouseDown = false
		for el, _ in pairs(hoveredElements) do
			if el.onmousedown or el.onclick then
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

		if info then
			if info.element.onclick then
				return info.element.onclick
			end

			local relX = event.x - info.absX
			local relY = event.y - info.absY

			return info.element.onmousedown(relX, relY, info.layout.width, info.layout.height)
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
