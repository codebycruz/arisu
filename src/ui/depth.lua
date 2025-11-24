---@alias LayerTable table<number, ComputedLayout[]>

---@class DepthCompositor
local DepthCompositor = {}
DepthCompositor.__index = DepthCompositor

---@return DepthCompositor
function DepthCompositor.new()
    return setmetatable({}, DepthCompositor)
end

---@param layout Layout
---@return LayerTable
function DepthCompositor:extractLayers(layout)
    ---@type LayerTable
    local layers = {}

    ---@param layout Layout
    local function traverse(layout)
        local zIndex = layout.zIndex or 0
        layers[zIndex] = layers[zIndex] or {}

        table.insert(layers[zIndex], layout)
        if layout.children then
            for _, child in ipairs(layout.children) do
                traverse(child)
            end
        end
    end

    traverse(layout)
    return layers
end

---@param layers LayerTable
---@return number[]
function DepthCompositor:getSortedZIndices(layers)
    local zIndices = {}
    for zIndex, _ in pairs(layers) do
        table.insert(zIndices, zIndex)
    end

    table.sort(zIndices)
    return zIndices
end

---@param zIndex number
---@param maxZIndex number?
---@return number
function DepthCompositor:normalizeZ(zIndex, maxZIndex)
    maxZIndex = maxZIndex or 1000
    return zIndex / maxZIndex
end

---@param layout Layout
---@return LayerTable, number[]
function DepthCompositor:compose(layout)
    local layers = self:extractLayers(layout)
    local sortedZIndices = self:getSortedZIndices(layers)

    return layers, sortedZIndices
end

return DepthCompositor
