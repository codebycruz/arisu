local vk = require("arisu-vulkan")

---@class glx.vk.Buffer
---@field buffer vk.Buffer*
---@field descriptor hood.BufferDescriptor
local VKBuffer = {}
VKBuffer.__index = VKBuffer

---@param device vk.Device
---@param descriptor hood.BufferDescriptor
function VKBuffer.new(device, descriptor)
	local vkUsage = 0

	for _, usage in ipairs(descriptor.usages) do
		if usage == "VERTEX" then
			vkUsage = bit.bor(vkUsage, vk.BufferUsage.VERTEX_BUFFER)
		elseif usage == "INDEX" then
			vkUsage = bit.bor(vkUsage, vk.BufferUsage.INDEX_BUFFER)
		elseif usage == "UNIFORM" then
			vkUsage = bit.bor(vkUsage, vk.BufferUsage.UNIFORM_BUFFER)
		end
	end

	if vkUsage == 0 then
		error("No valid buffer usage specified")
	end

	---@diagnostic disable-next-line: assign-type-mismatch: vkUsage is checked above
	local buffer = vk.createBuffer(device, { size = descriptor.size, usage = vkUsage })

	return setmetatable({ buffer = buffer, descriptor = descriptor }, VKBuffer)
end

return VKBuffer
