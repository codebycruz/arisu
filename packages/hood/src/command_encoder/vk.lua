local vk = require("arisu-vulkan")

local VKCommandBuffer = require("hood.command_buffer.vk")

---@class hood.vk.CommandEncoder
---@field buffer hood.vk.CommandBuffer
local VKCommandEncoder = {}
VKCommandEncoder.__index = VKCommandEncoder

---@param device hood.vk.Device
---@return hood.vk.CommandEncoder
function VKCommandEncoder.new(device)
	local buffer = VKCommandBuffer.new(device)
	return setmetatable({ buffer = buffer }, VKCommandEncoder)
end

---@type table<hood.RenderPassDescriptor, { beginInfo: vk.ffi.RenderPassBeginInfo, renderPass }>
local cachedDescriptors = setmetatable({}, { __mode = "k" })

--- SAFETY: This assumes the descriptor is a frozen table and will never be mutated.
--- It will ignore any changes made to the descriptor after this call via caching for performance reasons.
---@param descriptor hood.RenderPassDescriptor
function VKCommandEncoder:beginRendering(descriptor)
	local vkDescriptor = cachedDescriptors[descriptor]
	if not vkDescriptor then
		vkDescriptor = vk.newRenderPassBeginInfo()

		-- TODO: Need to get a renderpass here.
		-- cachedDescriptors[descriptor] = vkDescriptor
	end

	vk.cmdBeginRenderPass(self.buffer.buffer, descriptor.renderPassBeginInfo, vk.SubpassContents.INLINE)
end

function VKCommandEncoder:finish()
	return self.buffer
end

return VKCommandEncoder
