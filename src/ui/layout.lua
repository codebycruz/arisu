---@alias ScaleUnit { abs: number } | { rel: number } | "auto"
---@alias Direction "row" | "column"
---@alias Alignment "start" | "center" | "end"
---@alias Justify "start" | "center" | "end" | "space-between" | "space-around"
---@alias Padding { top: number?, bottom: number?, left: number?, right: number? } | number
---@alias Margin { top: number?, bottom: number?, left: number?, right: number? } | number
---@alias Visibility "visible" | "none"
---@alias BorderStyle "solid" | "dashed" | "dotted" | "none"
---@alias Border { width: number?, style: BorderStyle?, color: { r: number, g: number, b: number, a: number }? }
---@alias Borders { top: Border?, bottom: Border?, left: Border?, right: Border? }

---@alias IntoScaleUnit number | ScaleUnit
---@alias IntoPadding number | Padding
---@alias IntoMargin number | Margin
---@alias IntoBorder number | Border
---@alias IntoBorders Border | Borders

---@return ScaleUnit
local function intoScaleUnit(value --[[@param value IntoScaleUnit]] )
    if type(value) == "number" then
        if value > 1.0 then
            return { abs = value }
        end

        return { rel = value }
    elseif type(value) == "table" and (value.abs or value.rel) then
        return value
    elseif value == "auto" then
        return value
    else
        error("Invalid ScaleUnit value")
    end
end

local function intoDirection(value --[[@param value Direction]] )
    if value == "row" or value == "column" then
        return value
    else
        error("Invalid Direction value")
    end
end

---@return Padding
local function intoPadding(value --[[@param value IntoPadding]] )
    if type(value) == "number" then
        return { top = value, bottom = value, left = value, right = value }
    elseif type(value) == "table" then
        return {
            top = value.top or 0,
            bottom = value.bottom or 0,
            left = value.left or 0,
            right = value.right or 0
        }
    else
        error("Invalid Padding value")
    end
end

---@return Margin
local function intoMargin(value --[[@param value IntoMargin]] )
    if type(value) == "number" then
        return { top = value, bottom = value, left = value, right = value }
    elseif type(value) == "table" then
        return {
            top = value.top or 0,
            bottom = value.bottom or 0,
            left = value.left or 0,
            right = value.right or 0
        }
    else
        error("Invalid Margin value")
    end
end

---@return Border
local function intoBorder(value --[[@param value IntoBorder]] )
    if type(value) == "number" then
        return {
            width = value,
            style = "solid",
            color = { r = 0, g = 0, b = 0, a = 1 }
        }
    elseif type(value) == "table" then
        return {
            width = value.width or 1,
            style = value.style or "solid",
            color = value.color or { r = 0, g = 0, b = 0, a = 1 }
        }
    else
        error("Invalid Border value")
    end
end

---@return Borders
local function intoBorders(value --[[@param value IntoBorders]] )
    if type(value) == "number" or (type(value) == "table" and (value.width or value.style or value.color)) then
        local border = intoBorder(value)
        return { top = border, bottom = border, left = border, right = border }
    elseif type(value) == "table" then
        local defaultBorder = { width = 0, style = "none", color = { r = 0, g = 0, b = 0, a = 1 } }
        return {
            top = value.top and intoBorder(value.top) or defaultBorder,
            bottom = value.bottom and intoBorder(value.bottom) or defaultBorder,
            left = value.left and intoBorder(value.left) or defaultBorder,
            right = value.right and intoBorder(value.right) or defaultBorder
        }
    else
        error("Invalid Borders value")
    end
end

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

---@class Layout: LayoutStyle
---@field visualStyle VisualStyle
local Layout = {}
Layout.__index = Layout

function Layout.new()
    return setmetatable({
        width = { rel = 1.0 },
        height = { rel = 1.0 },
        direction = "row",
        zIndex = 0,
        children = {}
    }, Layout)
end

---@param width IntoScaleUnit
---@param height IntoScaleUnit
function Layout:withSize(width, height)
    self.width = intoScaleUnit(width)
    self.height = intoScaleUnit(height)
    return self
end

function Layout:withWidth(width --[[@param width IntoScaleUnit]])
    self.width = intoScaleUnit(width)
    return self
end

function Layout:withHeight(height --[[@param height IntoScaleUnit]])
    self.height = intoScaleUnit(height)
    return self
end

function Layout:withGap(gap --[[@param gap number]])
    self.gap = gap
    return self
end

function Layout:withDirection(direction --[[@param direction Direction]])
    self.direction = intoDirection(direction)
    return self
end

function Layout:withAlign(align --[[@param align Alignment]])
    self.align = align
    return self
end

function Layout:withJustify(justify --[[@param justify Justify]])
    self.justify = justify
    return self
end

function Layout:withPadding(padding --[[@param padding IntoPadding]])
    self.padding = intoPadding(padding)
    return self
end

function Layout:withMargin(margin --[[@param margin IntoMargin]])
    self.margin = intoMargin(margin)
    return self
end

function Layout:withBorder(border --[[@param border IntoBorders]])
    self.border = intoBorders(border)
    return self
end

function Layout:withZIndex(zIndex --[[@param zIndex number]])
    self.zIndex = zIndex
    return self
end

function Layout:withVisibility(visibility --[[@param visibility Visibility]])
    self.visibility = visibility
    return self
end

function Layout:withChildren(...)
    self.children = { ... }
    return self
end

function Layout:withStyle(style --[[@param style VisualStyle]])
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
---@field children ComputedLayout[]
---@field visible boolean
---@field zIndex number

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
            visible = false
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
    local border = self.border or { width = 0, style = "none", color = { r = 0, g = 0, b = 0, a = 1 } }
    border.top = border.top or border
    border.bottom = border.bottom or border
    border.left = border.left or border
    border.right = border.right or border

    local borderWidth = (border.left.width or 0) + (border.right.width or 0)
    local borderHeight = (border.top.width or 0) + (border.bottom.width or 0)

    local availableWidth = parentWidth - margin.left - margin.right - borderWidth
    local availableHeight = parentHeight - margin.top - margin.bottom - borderHeight

    local width
    if self.width == "auto" then
        width = availableWidth + borderWidth
    else
        width = (self.width.abs or (self.width.rel * (availableWidth + borderWidth)))
    end

    local height
    if self.height == "auto" then
        height = availableHeight + borderHeight
    else
        height = (self.height.abs or (self.height.rel * (availableHeight + borderHeight)))
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
    local function mainSize(result)
        return isRow and result.width or result.height
    end
    local function crossSize(result)
        return isRow and result.height or result.width
    end
    local function setMainPos(result, value)
        if isRow then result.x = value else result.y = value end
    end
    local function setCrossPos(result, value)
        if isRow then result.y = value else result.x = value end
    end
    local containerMainSize = isRow and contentWidth or contentHeight
    local containerCrossSize = isRow and contentHeight or contentWidth

    local childResults = {}
    local totalMainSize = 0
    local visibleChildCount = 0
    local autoCount = 0

    -- First pass: scan for non-auto sizes and count auto elements
    for i = 1, #self.children do
        local child = self.children[i]
        local childMainDimension = isRow and child.width or child.height

        if childMainDimension == "auto" then
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
    local totalGaps = math.max(0, (#self.children) - 1) * (self.gap or 0)
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
            table.insert(childResults, childResult)
        else
            local childResult = child:solve(contentWidth, contentHeight)
            table.insert(childResults, childResult)
        end
    end

    -- Recalculate for positioning
    totalMainSize = 0
    visibleChildCount = 0
    for i = 1, #childResults do
        if childResults[i].width > 0 or childResults[i].height > 0 then
            totalMainSize = totalMainSize + mainSize(childResults[i])
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
    for i, childResult in ipairs(childResults) do
        local isVisible = childResult.width > 0 or childResult.height > 0

        if isVisible then
            processedVisible = processedVisible + 1
            local isLastVisible = processedVisible == visibleChildCount

            setMainPos(childResult, offset + (isRow and padding.left or padding.top))
            offset = offset + mainSize(childResult) + (isLastVisible and 0 or spacing)

            local crossOffset = isRow and padding.top or padding.left
            if align == "center" then
                setCrossPos(childResult, crossOffset + (containerCrossSize - crossSize(childResult)) / 2)
            elseif align == "end" then
                setCrossPos(childResult, crossOffset + containerCrossSize - crossSize(childResult))
            else
                setCrossPos(childResult, crossOffset)
            end
        end
    end

    return {
        width = width,
        height = height,
        x = margin.left,
        y = margin.top,
        style = self.style,
        border = border,
        children = childResults,
        zIndex = self.zIndex,
        visible = true
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

        layout:withChildren(table.unpack(childLayouts))
    end

    return layout
end

return Layout
