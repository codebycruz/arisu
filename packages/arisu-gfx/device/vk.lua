local VKBuffer = require("arisu-gfx.buffer.vk")

---@class gfx.vk.Device
---@field device vk.Device
local VKDevice = {}
VKDevice.__index = VKDevice

---@param device vk.Device
function VKDevice.new(device)
	return setmetatable({ device = device }, VKDevice)
end

---@param descriptor gfx.BufferDescriptor
function VKDevice:createBuffer(descriptor)
	return VKBuffer.new(self.device, descriptor)
end

return VKDevice
