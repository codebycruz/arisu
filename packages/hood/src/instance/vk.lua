local vk = require("arisu-vulkan")

local VKAdapter = require("hood.adapter.vk")
local VKSurface = require("hood.surface.vk")

---@class hood.vk.Instance
local VKInstance = {}
VKInstance.__index = VKInstance

function VKInstance.new()
	return setmetatable({}, VKInstance)
end

---@param config hood.AdapterConfig
---@return hood.Adapter?
function VKInstance:requestAdapter(config)
	local deviceOrdering = {
		[vk.PhysicalDeviceType.DISCRETE_GPU] = 4,
		[vk.PhysicalDeviceType.INTEGRATED_GPU] = 3,
		[vk.PhysicalDeviceType.VIRTUAL_GPU] = 2,
		[vk.PhysicalDeviceType.CPU] = 1
	}

	local deviceOrderingFlip = config.powerPreference == "high-performance"
		and 1 or -1

	local devices = {}
	for _, physicalDevice in ipairs(vk.enumeratePhysicalDevices()) do
		local props = vk.getPhysicalDeviceProperties(physicalDevice)
		local ordering = deviceOrdering[props.deviceType] * deviceOrderingFlip

		devices[#devices + 1] = {
			device = physicalDevice,
			score = ordering
		}
	end

	table.sort(devices, function(a, b)
		return a.score > b.score
	end)

	if #devices > 0 then
		return VKAdapter.new(devices[1].device)
	end
end

---@param window winit.Window
function VKInstance:createSurface(window)
	-- todo: this
end

return VKInstance
