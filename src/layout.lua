---@alias ScaleUnit { abs: number } | { rel: number }
---@alias Direction "row" | "column"

---@alias IntoScaleUnit number | ScaleUnit

---@return ScaleUnit
local function intoScaleUnit(value --[[@param value IntoScaleUnit]] )
    if type(value) == "number" then
        if value >= 1.0 then
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

---@class Layout
---@field width ScaleUnit
---@field height ScaleUnit
---@field gap number
---@field children Layout[]
---@field direction Direction
---@field style Style
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

function Layout:withDirection(direction --[[@param direction Direction]])
    self.direction = intoDirection(direction)
    return self
end

function Layout:withChildren(...)
    self.children = { ... }
    return self
end

function Layout:withStyle(style --[[@param style Style]])
    self.style = style
    return self
end

---@class ComputedLayout
---@field width number
---@field height number
---@field x number
---@field y number
---@field style Style
---@field children ComputedLayout[]

---@param parentWidth number
---@param parentHeight number
---@return ComputedLayout
function Layout:solve(parentWidth, parentHeight)
    -- Resolve my size
    local width = self.width.abs or (self.width.rel * parentWidth)
    local height = self.height.abs or (self.height.rel * parentHeight)

    -- Layout children along the axis
    local offset = 0
    local results = {}
    local gap = self.gap or 0

    local childrenCount = #self.children
    for i = 1, childrenCount do
        local child = self.children[i]
        local childResult = child:solve(width, height)
        local isLastChild = i == childrenCount

        if self.direction == "row" then
            childResult.x = offset
            childResult.y = 0
            offset = offset + childResult.width + (isLastChild and 0 or gap)
        else
            childResult.x = 0
            childResult.y = offset
            offset = offset + childResult.height + (isLastChild and 0 or gap)
        end

        table.insert(results, childResult)
    end

    return { width = width, height = height, x = 0, y = 0, children = results }
end

return Layout
