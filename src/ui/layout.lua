---@alias ScaleUnit { abs: number } | { rel: number }
---@alias Direction "row" | "column"
---@alias Alignment "start" | "center" | "end"
---@alias Justify "start" | "center" | "end" | "space-between" | "space-around"
---@alias Padding { top: number?, bottom: number?, left: number?, right: number? } | number
---@alias Margin { top: number?, bottom: number?, left: number?, right: number? } | number
---@alias Visibility "visible" | "none"

---@alias IntoScaleUnit number | ScaleUnit
---@alias IntoPadding number | Padding
---@alias IntoMargin number | Margin

---@return ScaleUnit
local function intoScaleUnit(value --[[@param value IntoScaleUnit]] )
    if type(value) == "number" then
        if value > 1.0 then
            return { abs = value }
        end

        return { rel = value }
    elseif type(value) == "table" and value.abs or value.rel then
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

---@class LayoutStyle
---@field width ScaleUnit
---@field height ScaleUnit
---@field gap number
---@field direction Direction
---@field align Alignment
---@field justify Justify
---@field padding Padding
---@field margin Margin
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

    local availableWidth = parentWidth - margin.left - margin.right
    local availableHeight = parentHeight - margin.top - margin.bottom

    local width = self.width.abs or (self.width.rel * availableWidth)
    local height = self.height.abs or (self.height.rel * availableHeight)

    local padding = { top = 0, bottom = 0, left = 0, right = 0 }
    if self.padding then
        padding.top = self.padding.top or 0
        padding.bottom = self.padding.bottom or 0
        padding.left = self.padding.left or 0
        padding.right = self.padding.right or 0
    end
    local contentWidth = width - padding.left - padding.right
    local contentHeight = height - padding.top - padding.bottom

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

    for i = 1, #self.children do
        local childResult = self.children[i]:solve(contentWidth, contentHeight)
        table.insert(childResults, childResult)

        if childResult.width > 0 or childResult.height > 0 then
            totalMainSize = totalMainSize + mainSize(childResult)
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
