---@alias ScaleUnit { abs: number } | { rel: number } | "auto"
---@alias Direction "row" | "column"
---@alias Alignment "start" | "center" | "end"
---@alias Justify "start" | "center" | "end" | "space-between" | "space-around"
---@alias Padding { top: number?, bottom: number?, left: number?, right: number? }
---@alias Margin { top: number?, bottom: number?, left: number?, right: number? }
---@alias Visibility "visible" | "none"
---@alias BorderStyle "solid" | "dashed" | "dotted" | "none"
---@alias Border { width: number?, style: BorderStyle?, color: { r: number, g: number, b: number, a: number }? }
---@alias Borders { top: Border?, bottom: Border?, left: Border?, right: Border? }

---@class LayoutStyle
---@field width ScaleUnit
---@field height ScaleUnit
---@field gap number
---@field direction Direction
---@field align Alignment
---@field justify Justify
---@field padding Padding
---@field margin Margin
---@field border Borders
---@field zIndex number
---@field visibility Visibility
---@field top number
---@field left number
---@field right number
---@field bottom number
---@field position "relative" | "static"

---@class Layout: LayoutStyle
---@field children Layout[]
---@field visualStyle VisualStyle
local Layout = {}
Layout.__index = Layout

function Layout.new()
	return setmetatable({
		width = { rel = 1.0 },
		height = { rel = 1.0 },
		direction = "row",
		position = "static",
		zIndex = 0,
		children = {},
	}, Layout)
end

function Layout:withChildren(...)
	self.children = { ... }
	return self
end

function Layout:withStyle(
	style --[[@param style VisualStyle]]
)
	self.style = style
	return self
end

---@class ComputedLayout
---@field width number
---@field height number
---@field x number
---@field y number
---@field style VisualStyle
---@field border Borders
---@field margin Margin
---@field children ComputedLayout[]
---@field visible boolean
---@field zIndex number

---@type Border
local DEFAULT_BORDER = { width = 0, style = "none", color = { r = 0, g = 0, b = 0, a = 1 } }


local function mainSize(result, isRow)
	return isRow and result.width or result.height
end

local function crossSize(result, isRow)
	return isRow and result.height or result.width
end

local function setMainPos(result, value, isRow)
	if isRow then
		result.x = value
	else
		result.y = value
	end
end

local function setCrossPos(result, value, isRow)
	if isRow then
		result.y = value
	else
		result.x = value
	end
end

---@param parentWidth number
---@param parentHeight number
---@return ComputedLayout
function Layout:solve(parentWidth, parentHeight)
	local visibility = self.visibility or "visible"

	if visibility == "none" then
		return {
			width = 0,
			height = 0,
			x = 0,
			y = 0,
			style = self.style,
			border = self.border,
			children = {},
			visible = false,
		}
	end

	local margin = { top = 0, bottom = 0, left = 0, right = 0 }
	if self.margin then
		margin.top = self.margin.top or 0
		margin.bottom = self.margin.bottom or 0
		margin.left = self.margin.left or 0
		margin.right = self.margin.right or 0
	end

	-- Allow shorthand border definitions for all sides
	local border = self.border or {}
	border.top = border.top or DEFAULT_BORDER
	border.bottom = border.bottom or DEFAULT_BORDER
	border.left = border.left or DEFAULT_BORDER
	border.right = border.right or DEFAULT_BORDER

	local borderWidth = (border.left.width or 0) + (border.right.width or 0)
	local borderHeight = (border.top.width or 0) + (border.bottom.width or 0)

	local availableWidth = parentWidth - margin.left - margin.right
	local availableHeight = parentHeight - margin.top - margin.bottom

	local width
	if self.width == "auto" then
		width = availableWidth
	else
		width = (self.width.abs or (self.width.rel * availableWidth))
	end

	local height
	if self.height == "auto" then
		height = availableHeight
	else
		height = (self.height.abs or (self.height.rel * availableHeight))
	end

	local padding = { top = 0, bottom = 0, left = 0, right = 0 }
	if self.padding then
		padding.top = self.padding.top or 0
		padding.bottom = self.padding.bottom or 0
		padding.left = self.padding.left or 0
		padding.right = self.padding.right or 0
	end

	local contentWidth = width - padding.left - padding.right - borderWidth
	local contentHeight = height - padding.top - padding.bottom - borderHeight

	local isRow = self.direction == "row"
	local containerMainSize = isRow and contentWidth or contentHeight
	local containerCrossSize = isRow and contentHeight or contentWidth

	---@type ComputedLayout[]
	local childResults = {}
	local totalMainSize = 0
	local visibleChildCount = 0
	local autoCount = 0

	-- First pass: scan for non-auto sizes and count auto elements
	for i = 1, #self.children do
		local child = self.children[i]
		local childPosition = child.position or "static"
		local childMainDimension = isRow and child.width or child.height

		if childPosition == "relative" then
			-- Relative positioned elements don't participate in layout
		elseif childMainDimension == "auto" then
			autoCount = autoCount + 1
		else
			-- Calculate size assuming rel takes full parent space
			local tempWidth = contentWidth
			local tempHeight = contentHeight
			if child.width and child.width.rel then
				tempWidth = child.width.rel * contentWidth
			elseif child.width and child.width.abs then
				tempWidth = child.width.abs
			end
			if child.height and child.height.rel then
				tempHeight = child.height.rel * contentHeight
			elseif child.height and child.height.abs then
				tempHeight = child.height.abs
			end

			local childSize = isRow and tempWidth or tempHeight
			totalMainSize = totalMainSize + childSize
			visibleChildCount = visibleChildCount + 1
		end
	end

	-- Calculate remaining space for auto children
	local totalGaps = math.max(0, #self.children - 1) * (self.gap or 0)
	local remainingSpace = containerMainSize - totalMainSize - totalGaps
	local autoSpace = autoCount > 0 and (remainingSpace / autoCount) or 0

	-- Second pass: solve all children with known auto size
	for i = 1, #self.children do
		local child = self.children[i]
		local childMainDimension = isRow and child.width or child.height

		if childMainDimension == "auto" then
			local tempChild = setmetatable({}, { __index = child })
			for k, v in pairs(child) do
				tempChild[k] = v
			end

			if isRow then
				tempChild.width = { abs = autoSpace }
			else
				tempChild.height = { abs = autoSpace }
			end

			local childResult = tempChild:solve(contentWidth, contentHeight)
			childResults[#childResults + 1] = childResult
		else
			local childResult = child:solve(contentWidth, contentHeight)
			childResults[#childResults + 1] = childResult
		end
	end

	-- Recalculate for positioning
	totalMainSize = 0
	visibleChildCount = 0
	for i = 1, #childResults do
		local childPosition = childResults[i].position or "static"
		if (childResults[i].width > 0 or childResults[i].height > 0) and childPosition ~= "relative" then
			local childMargin = childResults[i].margin
			local childMainMargin = isRow and (childMargin.left + childMargin.right) or
				(childMargin.top + childMargin.bottom)
			totalMainSize = totalMainSize + mainSize(childResults[i], isRow) + childMainMargin
			visibleChildCount = visibleChildCount + 1
		end
	end

	local totalGaps = math.max(0, visibleChildCount - 1) * (self.gap or 0)
	totalMainSize = totalMainSize + totalGaps
	local freeSpace = containerMainSize - totalMainSize

	local offset = 0
	local spacing = self.gap or 0
	local justify = self.justify or "start"

	if justify == "center" then
		offset = freeSpace / 2
	elseif justify == "end" then
		offset = freeSpace
	elseif justify == "space-between" and #self.children > 1 then
		spacing = spacing + freeSpace / (#self.children - 1)
	elseif justify == "space-around" then
		local spaceUnit = freeSpace / #self.children
		offset = spaceUnit / 2
		spacing = spacing + spaceUnit
	end

	local align = self.align or "start"

	local processedVisible = 0
	for _, childResult in ipairs(childResults) do
		local childPosition = childResult.position or "static"
		local isVisible = childResult.width > 0 or childResult.height > 0

		if isVisible and childPosition == "relative" then
			-- Relative positioned elements are positioned at (0, 0) of parent's content area
			setMainPos(childResult, (isRow and padding.left or padding.top) + (isRow and childResult.x or childResult.y),
				isRow)
			setCrossPos(childResult, (isRow and padding.top or padding.left) + (isRow and childResult.y or childResult.x),
				isRow)
		elseif isVisible then
			processedVisible = processedVisible + 1
			local isLastVisible = processedVisible == visibleChildCount

			local mainPos = offset + (isRow and padding.left or padding.top)
			setMainPos(childResult, mainPos + (isRow and childResult.x or childResult.y), isRow)
			offset = offset + mainSize(childResult, isRow) + (isLastVisible and 0 or spacing)

			local crossOffset = (isRow and padding.top or padding.left) + (isRow and childResult.y or childResult.x)
			local childMargin = childResult.margin
			local childCrossMargin = isRow and (childMargin.top + childMargin.bottom) or
				(childMargin.left + childMargin.right)
			if align == "center" then
				setCrossPos(childResult,
					crossOffset + (containerCrossSize - crossSize(childResult, isRow) - childCrossMargin) / 2, isRow)
			elseif align == "end" then
				setCrossPos(childResult,
					crossOffset + containerCrossSize - crossSize(childResult, isRow) - childCrossMargin, isRow)
			else
				setCrossPos(childResult, crossOffset, isRow)
			end
		end
	end

	local isRelative = self.position == "relative"

	local x = margin.left
	local y = margin.top

	if isRelative then
		if self.left then -- If both provided, use left
			x = x + self.left
		elseif self.right then
			x = x - self.right
		end

		if self.top then -- If both provided, use top
			y = y + self.top
		elseif self.bottom then
			y = y - self.bottom
		end
	end

	return {
		width = width,
		height = height,
		x = x,
		y = y,
		style = self.style,
		border = border,
		margin = margin,
		children = childResults,
		zIndex = self.zIndex,
		position = self.position,
		visible = true,
	}
end

---@param element Element<any>
function Layout.fromElement(element)
	local layout = Layout.new()

	if element.visualStyle then
		layout = layout:withStyle(element.visualStyle)
	end

	if element.layoutStyle then
		for k, v in pairs(element.layoutStyle) do
			layout[k] = v
		end
	end

	if element.children then
		local childLayouts = {}
		for _, child in ipairs(element.children) do
			table.insert(childLayouts, Layout.fromElement(child))
		end

		layout:withChildren(unpack(childLayouts))
	end

	return layout
end

return Layout
