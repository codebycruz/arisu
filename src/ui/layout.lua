---@alias ScaleUnit { abs: number } | { rel: number }
---@alias Direction "row" | "column"
---@alias Alignment "start" | "center" | "end"
---@alias Justify "start" | "center" | "end" | "space-between" | "space-around"

---@alias IntoScaleUnit number | ScaleUnit

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

---@class LayoutStyle
---@field width ScaleUnit
---@field height ScaleUnit
---@field gap number
---@field direction Direction
---@field align Alignment
---@field justify Justify

---@class Layout: LayoutStyle
---@field visualStyle VisualStyle
local Layout = {}
Layout.__index = Layout

function Layout.new()
    return setmetatable({
        width = { rel = 1.0 },
        height = { rel = 1.0 },
        direction = "row",
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

---@param parentWidth number
---@param parentHeight number
---@return ComputedLayout
function Layout:solve(parentWidth, parentHeight)
    local width = self.width.abs or (self.width.rel * parentWidth)
    local height = self.height.abs or (self.height.rel * parentHeight)

    -- Axis-agnostic helpers
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
    local containerMainSize = isRow and width or height
    local containerCrossSize = isRow and height or width

    -- First pass: compute all child sizes
    local childResults = {}
    local totalMainSize = 0

    for i = 1, #self.children do
        local childResult = self.children[i]:solve(width, height)
        table.insert(childResults, childResult)
        totalMainSize = totalMainSize + mainSize(childResult)
    end

    -- Calculate justify-content
    local totalGaps = math.max(0, #self.children - 1) * (self.gap or 0)
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

    -- Second pass: position children
    local align = self.align or "start"

    for i, childResult in ipairs(childResults) do
        local isLastChild = i == #childResults

        -- Main axis positioning
        setMainPos(childResult, offset)
        offset = offset + mainSize(childResult) + (isLastChild and 0 or spacing)

        -- Cross axis positioning
        if align == "center" then
            setCrossPos(childResult, (containerCrossSize - crossSize(childResult)) / 2)
        elseif align == "end" then
            setCrossPos(childResult, containerCrossSize - crossSize(childResult))
        else
            setCrossPos(childResult, 0)
        end
    end

    return { width = width, height = height, x = 0, y = 0, style = self.style, children = childResults }
end

---@param element Element
function Layout.fromElement(element)
    -- If element is a Button, treat it as its inner element for layout
    if element.type == "button" and element.inner then
        return Layout.fromElement(element.inner)
    end
    
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
