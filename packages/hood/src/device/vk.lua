local vk = require("arisu-vulkan")

local VKBuffer = require("hood.buffer.vk")
local VKQueue = require("hood.queue.vk")

---@class hood.vk.Device
---@field public queue hood.vk.Queue
---@field device vk.Device
local VKDevice = {}
VKDevice.__index = VKDevice

---@param adapter hood.vk.Adapter
function VKDevice.new(adapter)
	local device = vk.createDevice(adapter.pd, {
		queueCreateInfos = {
			{
				queueFamilyIndex = adapter.gfxQueueFamilyIdx,
				queuePriorities = { 1.0 },
			},
		},
	})
	local queue = VKQueue.new(device, adapter.gfxQueueFamilyIdx, 0)

	return setmetatable({ device = device, queue = queue }, VKDevice)
end

---@param descriptor hood.BufferDescriptor
function VKDevice:createBuffer(descriptor)
	return VKBuffer.new(self.device, descriptor)
end

return VKDevice
