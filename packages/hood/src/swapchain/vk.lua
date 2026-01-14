local vk = require("arisu-vulkan")

---@class hood.vk.Swapchain
local VKSwapchain = {}
VKSwapchain.__index = VKSwapchain

---@param device vk.Device
---@param info vk.SwapchainCreateInfoKHRStruct
function VKSwapchain.new(device, info)
	return vk.createSwapchainKHR(device, info)
end
