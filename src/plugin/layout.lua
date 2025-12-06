---@class LayoutPlugin
---@field layoutTree Layout?
---@field computedLayout ComputedLayout?
local LayoutPlugin = {}
LayoutPlugin.__index = LayoutPlugin

---@generic Message
function LayoutPlugin.new() ---@return LayoutPlugin
	return setmetatable({}, LayoutPlugin)
end

---@param view Element
function LayoutPlugin:refreshLayout(view)

end

---@param event Event
---@param handler EventHandler
---@return Message?
function LayoutPlugin:event(event, handler)

end
