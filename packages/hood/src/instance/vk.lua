local vk = require("arisu-vulkan")

local VKAdapter = require("hood.adapter.vk")
local VKSurface = require("hood.surface.vk")

---@class hood.vk.Instance
local VKInstance = {}
VKInstance.__index = VKInstance

function VKInstance.new()
	return setmetatable({}, VKInstance)
end

---@param config hood.AdapterConfig
function VKInstance:requestAdapter(config)
	-- todo: actually make use of the config
	for i, physicalDevice in ipairs(vk.enumeratePhysicalDevices()) do
		return VKAdapter.new(physicalDevice)
	end
end

---@param window winit.Window
function VKInstance:createSurface(window)
	-- todo: this
end

return VKInstance
