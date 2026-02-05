local vk = require("hood-vulkan")

---@class hood.vk.Queue
---@field device vk.Device
---@field queue vk.Queue
---@field familyIdx number
---@field idx number
local VKQueue = {}
VKQueue.__index = VKQueue

---@param device vk.Device
---@param familyIdx number
---@param idx number
function VKQueue.new(device, familyIdx, idx)
	local queue = vk.getDeviceQueue(device, familyIdx, idx)
	return setmetatable({ device = device, queue = queue, familyIdx = familyIdx, idx = idx }, VKQueue)
end

---@param buffer hood.vk.CommandBuffer
function VKQueue:submit(buffer) end

return VKQueue
