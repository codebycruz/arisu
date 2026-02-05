local vk = require("hood-vulkan")

local VKTexture = require("hood.texture.vk")

---@class hood.vk.Swapchain
---@field swapchain vk.SwapchainKHR
---@field device vk.Device
local VKSwapchain = {}
VKSwapchain.__index = VKSwapchain

---@param device vk.Device
---@param info vk.ffi.SwapchainCreateInfoKHR
function VKSwapchain.new(device, info)
	return setmetatable({ device = device, swapchain = vk.createSwapchainKHR(device, info) }, VKSwapchain)
end

function VKSwapchain:getCurrentTexture()
	local imageIndex = vk.acquireNextImageKHR(self.device, self.swapchain, math.huge)
	return VKTexture.new(self.device, imageIndex)
end

---@param queue hood.vk.Queue
function VKSwapchain:present(queue) end
