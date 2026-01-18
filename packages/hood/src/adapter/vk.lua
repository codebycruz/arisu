local vk = require("arisu-vulkan")

local VKDevice = require("hood.device.vk")

---@class hood.vk.Adapter
---@field pd vk.PhysicalDevice
local VKAdapter = {}
VKAdapter.__index = VKAdapter

---@param physicalDevice vk.PhysicalDevice
function VKAdapter.new(physicalDevice)
	return setmetatable({ pd = physicalDevice }, VKAdapter)
end

function VKAdapter:requestDevice()
	local rawDevice = vk.createDevice(self.pd, {})
	return VKDevice.new(rawDevice)
end

return VKAdapter
