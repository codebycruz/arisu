local vk = require("arisu-vulkan")

---@class hood.vk.CommandBuffer
---@field device hood.vk.Device
---@field pool vk.CommandPool
---@field buffer vk.CommandBuffer
local VKCommandBuffer = {}
VKCommandBuffer.__index = VKCommandBuffer

---@param device hood.vk.Device
function VKCommandBuffer.new(device)
	local pool = vk.createCommandPool(device.device, {
		flags = vk.COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT,
		queueFamilyIndex = device.queue.familyIdx,
	})

	local buffer = vk.allocateCommandBuffers(device.device, {
		commandPool = pool,
		level = vk.COMMAND_BUFFER_LEVEL_PRIMARY,
		commandBufferCount = 1,
	})[1]

	return setmetatable({
		device = device,
		pool = pool,
		buffer = buffer,
	}, VKCommandBuffer)
end
