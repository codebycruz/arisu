local VKBuffer = require("hood.buffer.vk")

---@class hood.vk.Device
---@field device vk.Device
local VKDevice = {}
VKDevice.__index = VKDevice

---@param device vk.Device
function VKDevice.new(device)
	return setmetatable({ device = device }, VKDevice)
end

---@param descriptor hood.BufferDescriptor
function VKDevice:createBuffer(descriptor)
	return VKBuffer.new(self.device, descriptor)
end

return VKDevice
