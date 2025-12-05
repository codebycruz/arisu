local util = require("util")
local gl = require("bindings.gl")

local Element = require("ui.element")

---@class WindowContext
---@field window Window
---@field renderCtx Context
---@field quadVAO VAO
---@field quadPipeline Pipeline
---@field quadVertex Buffer
---@field quadIndex Buffer
---@field overlayVAO VAO
---@field overlayPipeline Pipeline
---@field overlayVertex Buffer
---@field overlayIndex Buffer
---@field ui Element
---@field layoutTree Layout
---@field computedLayout ComputedLayout
---@field nIndices number

---@class QuadPlugin
---@field windowContexts table<Window, WindowContext>
---@field mainWindow Window
---@field textureManager TextureManager
---@field view fun(window: Window): Element
---@field update fun(message: Message): Task
local QuadPlugin = {}
QuadPlugin.__index = QuadPlugin

function QuadPlugin.new()
	return setmetatable({}, QuadPlugin)
end

---@param ctx WindowContext
function QuadPlugin:draw(ctx)
	-- So in the far future with a bunch of refactoring
	-- When the plugin system exists, this should be moved to a plugin that is provided by default
	-- So draw() just becomes a call to calling the app's draw event
	-- Then users can have whatever pipelines they want as well.
	ctx.renderCtx:makeCurrent()

	gl.enable(gl.BLEND)
	gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)

	gl.enable(gl.DEPTH_TEST)
	gl.depthFunc(gl.LESS_EQUAL)
	gl.clear(bit.bor(gl.COLOR_BUFFER_BIT, gl.DEPTH_BUFFER_BIT))

	gl.viewport(0, 0, ctx.window.width, ctx.window.height)

	ctx.quadPipeline:bind()
	self.textureManager:bind()
	ctx.quadVAO:bind()
	gl.drawElements(gl.TRIANGLES, ctx.nIndices, gl.UNSIGNED_INT, nil)

	ctx.renderCtx:swapBuffers()
end

local function toNDC(pos, screenSize)
	return (pos / (screenSize * 0.5)) - 1.0
end

--- Converts a z-index to an NDC z-value
---@param z number?
local function convertZ(z)
	return 1 - math.min(z or 0, 100000) / 1000000
end

---@param layout ComputedLayout
local function generateLayoutQuads(layout, parentX, parentY, vertices, indices, windowWidth, windowHeight)
	local x = (parentX or 0) + (layout.x or 0)
	local y = (parentY or 0) + (layout.y or 0)
	local width = layout.width
	local height = layout.height
	local z = layout.zIndex or 0

	local color = layout.style.bg or { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }
	local baseIdx = #vertices / 10

	local left = toNDC(x, windowWidth)
	local right = toNDC(x + width, windowWidth)
	local top = -toNDC(y, windowHeight)
	local bottom = -toNDC(y + height, windowHeight)

	local textureId = 0 -- default white texture
	if layout.style.bgImage then
		textureId = layout.style.bgImage
	end

	local u0, v0, u1, v1 = 0, 0, 1, 1
	if layout.style.bgImageUV then
		u0 = layout.style.bgImageUV.u0 or 0
		v0 = layout.style.bgImageUV.v0 or 0
		u1 = layout.style.bgImageUV.u1 or 1
		v1 = layout.style.bgImageUV.v1 or 1
	end

	-- stylua: ignore
	for _, v in ipairs({
		left, top, convertZ(z), color.r, color.g, color.b, color.a, u0, v0, textureId,
		right, top, convertZ(z), color.r, color.g, color.b, color.a, u1, v0, textureId,
		right, bottom, convertZ(z), color.r, color.g, color.b, color.a, u1, v1, textureId,
		left, bottom, convertZ(z), color.r, color.g, color.b, color.a, u0, v1, textureId,
	}) do
		table.insert(vertices, v)
	end

	-- stylua: ignore
	for _, idx in ipairs({
		baseIdx, baseIdx + 1, baseIdx + 2,
		baseIdx, baseIdx + 2, baseIdx + 3,
	}) do
		table.insert(indices, idx)
	end

	-- Generate border quads after background (so they render on top)
	if layout.border then
		local borderTop = layout.border.top
		local borderBottom = layout.border.bottom
		local borderLeft = layout.border.left
		local borderRight = layout.border.right

		local function addBorderQuad(bx, by, bw, bh, color)
			if bw <= 0 or bh <= 0 then
				return
			end

			local baseIdx = #vertices / 10
			local left = toNDC(bx, windowWidth)
			local right = toNDC(bx + bw, windowWidth)
			local top = -toNDC(by, windowHeight)
			local bottom = -toNDC(by + bh, windowHeight)

			-- stylua: ignore
			for _, v in ipairs({
				left, top, convertZ(z + 1), color.r, color.g, color.b, color.a, 0, 0, 0,
				right, top, convertZ(z + 1), color.r, color.g, color.b, color.a, 0, 0, 0,
				right, bottom, convertZ(z + 1), color.r, color.g, color.b, color.a, 0, 0, 0,
				left, bottom, convertZ(z + 1), color.r, color.g, color.b, color.a, 0, 0, 0,
			}) do
				table.insert(vertices, v)
			end

			-- stylua: ignore
			for _, idx in ipairs({
				baseIdx, baseIdx + 1, baseIdx + 2,
				baseIdx, baseIdx + 2, baseIdx + 3,
			}) do
				table.insert(indices, idx)
			end
		end

		-- Top border
		if borderTop and borderTop.width and borderTop.width > 0 and borderTop.style ~= "none" then
			addBorderQuad(x, y, width, borderTop.width, borderTop.color)
		end

		-- Bottom border
		if borderBottom and borderBottom.width and borderBottom.width > 0 and borderBottom.style ~= "none" then
			addBorderQuad(x, y + height - borderBottom.width, width, borderBottom.width, borderBottom.color)
		end

		-- Left border
		if borderLeft and borderLeft.width and borderLeft.width > 0 and borderLeft.style ~= "none" then
			addBorderQuad(x, y, borderLeft.width, height, borderLeft.color)
		end

		-- Right border
		if borderRight and borderRight.width and borderRight.width > 0 and borderRight.style ~= "none" then
			addBorderQuad(x + width - borderRight.width, y, borderRight.width, height, borderRight.color)
		end
	end

	if layout.children then
		for _, child in ipairs(layout.children) do
			generateLayoutQuads(child, x, y, vertices, indices, windowWidth, windowHeight)
		end
	end
end

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

---@param element Element
---@param fontManager FontManager
local function convertTextElements(element, fontManager)
	if element.type == "text" then
		---@type string
		local value = element.userdata

		local fg = element.visualStyle.fg or { r = 0.0, g = 0.0, b = 0.0, a = 1.0 }

		local font = element.visualStyle.font or fontManager:getDefault()
		local fontBitmap = fontManager:getBitmap(font)
		local uvs = fontBitmap:getStringUVs(value)

		local children = {}
		for i = 1, #uvs do
			local quad = uvs[i]

			children[i] = Element.new("div"):withStyle({
				bg = fg,
				bgImage = font,
				bgImageUV = quad,
				width = { abs = quad.width },
				height = { abs = quad.height },
			})
		end

		-- INFO: This shouldn't cause any problems but who knows. maybe we'll use the old ui.
		element.type = "div"
		element.layoutStyle.direction = "row"
		element.children = children
		return element
	end

	if element.children then
		local newChildren = {}
		for _, child in ipairs(element.children) do
			table.insert(newChildren, convertTextElements(child, fontManager))
		end

		element.children = newChildren
	end

	return element
end

---@param ctx WindowContext
---@param handler EventHandler
function QuadPlugin:refreshView(ctx, handler)
	ctx.ui = self.view(ctx.window)
	ctx.ui = convertTextElements(ctx.ui, fontManager)
	ctx.layoutTree = Layout.fromElement(ctx.ui)
	ctx.computedLayout = ctx.layoutTree:solve(ctx.window.width, ctx.window.height)

	local vertices, indices = {}, {}
	generateLayoutQuads(ctx.computedLayout, 0, 0, vertices, indices, ctx.window.width, ctx.window.height)

	ctx.quadVertex:setData("f32", vertices)
	ctx.quadIndex:setData("u32", indices)
	ctx.nIndices = #indices

	handler:requestRedraw(ctx.window)
end

---@param event Event
---@param handler EventHandler
function QuadPlugin:event(event, handler)
	local eventName = event.name
	if eventName == "redraw" then
		local ctx = self.windowContexts[event.window]
		draw(ctx)
	elseif eventName == "windowClose" then
		-- Ensure we only exit if the main window is closed
		-- TODO: Maybe allow users to specify this behavior?
		if event.window.id == self.mainWindow.id then
			handler:exit()
		else
			-- TODO: Figure out proper resource cleanup
			-- windowContexts[event.window].renderCtx:destroy()
			self.windowContexts[event.window] = nil
			handler:close(event.window)
		end
	elseif eventName == "resize" then
		local ctx = self.windowContexts[event.window]
		ctx.renderCtx:makeCurrent()
		gl.viewport(0, 0, ctx.window.width, ctx.window.height)

		if util.isWindows() then
			self:refreshView(ctx, handler)
		end
	elseif eventName == "mouseMove" then
		local ctx = self.windowContexts[event.window]

		---@type table<Element, {layout: ComputedLayout, absX: number, absY: number}>
		local hoveredElements = {}
		findElementsAtPosition(ctx.ui, ctx.computedLayout, event.x, event.y, 0, 0, hoveredElements)

		local anyWithMouseDown = false
		for el, _ in pairs(hoveredElements) do
			if el.onmousedown then
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
				runUpdate(el.onmousemove(relX, relY, layout.layout.width, layout.layout.height), ctx.window, handler)
			end
		end
	elseif eventName == "mousePress" then
		local ctx = self.windowContexts[event.window]
		local info = findElementAtPosition(ctx.ui, ctx.computedLayout, event.x, event.y, 0, 0, function(el)
			return el.onmousedown ~= nil
		end)

		if info then
			local relX = event.x - info.absX
			local relY = event.y - info.absY
			return info.element.onmousedown(relX, relY, info.layout.width, info.layout.height), ctx.window,
				handler
		end
	elseif eventName == "mouseRelease" then
		local ctx = self.windowContexts[event.window]
		local info = findElementAtPosition(ctx.ui, ctx.computedLayout, event.x, event.y, 0, 0, function(el)
			return el.onmouseup ~= nil
		end)

		if info then
			local relX = event.x - info.absX
			local relY = event.y - info.absY
			runUpdate(info.element.onmouseup(relX, relY, info.layout.width, info.layout.height), ctx.window, handler)
		end
	elseif eventName == "map" then
		if not self.windowContexts[event.window] then
			initWindow(event.window)
		end

		refreshView(self.windowContexts[event.window], handler)
	end
end

return QuadPlugin
