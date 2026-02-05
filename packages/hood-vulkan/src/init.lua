local ffi = require("ffi")

ffi.cdef([[ffidefs.h]])

local vkGlobal = {}

---@enum vk.StructureType
vkGlobal.StructureType = {
	APPLICATION_INFO = 0,
	INSTANCE_CREATE_INFO = 1,
	DEVICE_QUEUE_CREATE_INFO = 2,
	DEVICE_CREATE_INFO = 3,
	SUBMIT_INFO = 4,
	MEMORY_ALLOCATE_INFO = 5,
	MAPPED_MEMORY_RANGE = 6,
	BIND_SPARSE_INFO = 7,
	FENCE_CREATE_INFO = 8,
	SEMAPHORE_CREATE_INFO = 9,
	EVENT_CREATE_INFO = 10,
	QUERY_POOL_CREATE_INFO = 11,
	BUFFER_CREATE_INFO = 12,
	BUFFER_VIEW_CREATE_INFO = 13,
	IMAGE_CREATE_INFO = 14,
	IMAGE_VIEW_CREATE_INFO = 15,
	SHADER_MODULE_CREATE_INFO = 16,
	PIPELINE_CACHE_CREATE_INFO = 17,
	PIPELINE_SHADER_STAGE_CREATE_INFO = 18,
	PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO = 19,
	PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO = 20,
	PIPELINE_TESSELLATION_STATE_CREATE_INFO = 21,
	PIPELINE_VIEWPORT_STATE_CREATE_INFO = 22,
	PIPELINE_RASTERIZATION_STATE_CREATE_INFO = 23,
	PIPELINE_MULTISAMPLE_STATE_CREATE_INFO = 24,
	PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO = 25,
	PIPELINE_COLOR_BLEND_STATE_CREATE_INFO = 26,
	PIPELINE_DYNAMIC_STATE_CREATE_INFO = 27,
	GRAPHICS_PIPELINE_CREATE_INFO = 28,
	COMPUTE_PIPELINE_CREATE_INFO = 29,
	PIPELINE_LAYOUT_CREATE_INFO = 30,
	SAMPLER_CREATE_INFO = 31,
	DESCRIPTOR_SET_LAYOUT_CREATE_INFO = 32,
	DESCRIPTOR_POOL_CREATE_INFO = 33,
	DESCRIPTOR_SET_ALLOCATE_INFO = 34,
	WRITE_DESCRIPTOR_SET = 35,
	COPY_DESCRIPTOR_SET = 36,
	FRAMEBUFFER_CREATE_INFO = 37,
	RENDER_PASS_CREATE_INFO = 38,
	COMMAND_POOL_CREATE_INFO = 39,
	COMMAND_BUFFER_ALLOCATE_INFO = 40,
	COMMAND_BUFFER_INHERITANCE_INFO = 41,
	COMMAND_BUFFER_BEGIN_INFO = 42,
	RENDER_PASS_BEGIN_INFO = 43,
	BUFFER_MEMORY_BARRIER = 44,
	IMAGE_MEMORY_BARRIER = 45,
	MEMORY_BARRIER = 46,
	LOADER_INSTANCE_CREATE_INFO = 47,
	LOADER_DEVICE_CREATE_INFO = 48,

	-- VK_KHR_swapchain
	SWAPCHAIN_CREATE_INFO_KHR = 1000001000,
	PRESENT_INFO_KHR = 1000001001,
}

do
	local C = ffi.load("vulkan.so.1")

	---@param info vk.ffi.InstanceCreateInfo
	---@param allocator ffi.cdata*?
	---@return vk.Instance
	function vkGlobal.createInstance(info, allocator)
		local instance = ffi.new("VkInstance[1]")
		local info = ffi.new("VkInstanceCreateInfo", info)
		info.sType = vkGlobal.StructureType.INSTANCE_CREATE_INFO

		local result = C.vkCreateInstance(info, allocator, instance)
		if result ~= 0 then
			error("Failed to create Vulkan instance, error code: " .. tostring(result))
		end

		return instance[0]
	end

	---@param instance vk.Instance
	---@return vk.PhysicalDevice[]
	function vkGlobal.enumeratePhysicalDevices(instance)
		local deviceCount = ffi.new("uint32_t[1]", 0)
		local result = C.vkEnumeratePhysicalDevices(instance, deviceCount, nil)
		if result ~= 0 then
			error("Failed to enumerate physical devices, error code: " .. tostring(result))
		end

		local devices = ffi.new("VkPhysicalDevice[?]", deviceCount[0])
		result = C.vkEnumeratePhysicalDevices(instance, deviceCount, devices)
		if result ~= 0 then
			error("Failed to enumerate physical devices, error code: " .. tostring(result))
		end

		local deviceList = {}
		for i = 0, deviceCount[0] - 1 do
			deviceList[i + 1] = devices[i]
		end

		return deviceList
	end

	---@param physicalDevice vk.PhysicalDevice
	function vkGlobal.getPhysicalDeviceProperties(physicalDevice)
		local properties = ffi.new("VkPhysicalDeviceProperties")
		C.vkGetPhysicalDeviceProperties(physicalDevice, properties)
		return properties --[[@as vk.PhysicalDeviceProperties]]
	end

	---@param physicalDevice vk.PhysicalDevice
	---@return vk.PhysicalDeviceMemoryProperties
	function vkGlobal.getPhysicalDeviceMemoryProperties(physicalDevice)
		local memProperties = ffi.new("VkPhysicalDeviceMemoryProperties")
		C.vkGetPhysicalDeviceMemoryProperties(physicalDevice, memProperties)
		return memProperties --[[@as vk.PhysicalDeviceMemoryProperties]]
	end

	---@param physicalDevice vk.PhysicalDevice
	---@return vk.QueueFamilyProperties[]
	function vkGlobal.getPhysicalDeviceQueueFamilyProperties(physicalDevice)
		local count = ffi.new("uint32_t[1]")
		C.vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice, count, nil)

		local properties = ffi.new("VkQueueFamilyProperties[?]", count[0])
		C.vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice, count, properties)

		local propertyTable = {}
		for i = 0, count[0] - 1 do
			propertyTable[i + 1] = properties[i]
		end
		return propertyTable
	end

	---@param physicalDevice vk.PhysicalDevice
	---@param surface vk.SurfaceKHR
	---@return vk.SurfaceCapabilitiesKHR
	function vkGlobal.getPhysicalDeviceSurfaceCapabilitiesKHR(physicalDevice, surface)
		local capabilities = ffi.new("VkSurfaceCapabilitiesKHR")
		local result = C.vkGetPhysicalDeviceSurfaceCapabilitiesKHR(physicalDevice, surface, capabilities)
		if result ~= 0 then
			error("Failed to get physical device surface capabilities, error code: " .. tostring(result))
		end
		return capabilities --[[@as vk.SurfaceCapabilitiesKHR]]
	end

	---@param physicalDevice vk.PhysicalDevice
	---@param surface vk.SurfaceKHR
	---@return vk.SurfaceFormatKHR[]
	function vkGlobal.getPhysicalDeviceSurfaceFormatsKHR(physicalDevice, surface)
		local count = ffi.new("uint32_t[1]")
		local result = C.vkGetPhysicalDeviceSurfaceFormatsKHR(physicalDevice, surface, count, nil)
		if result ~= 0 then
			error("Failed to get surface format count, error code: " .. tostring(result))
		end

		local formats = ffi.new("VkSurfaceFormatKHR[?]", count[0])
		result = C.vkGetPhysicalDeviceSurfaceFormatsKHR(physicalDevice, surface, count, formats)
		if result ~= 0 then
			error("Failed to get surface formats, error code: " .. tostring(result))
		end

		local formatTable = {}
		for i = 0, count[0] - 1 do
			formatTable[i + 1] = formats[i]
		end
		return formatTable
	end

	---@param physicalDevice vk.PhysicalDevice
	---@param surface vk.SurfaceKHR
	---@return number[]
	function vkGlobal.getPhysicalDeviceSurfacePresentModesKHR(physicalDevice, surface)
		local count = ffi.new("uint32_t[1]")
		local result = C.vkGetPhysicalDeviceSurfacePresentModesKHR(physicalDevice, surface, count, nil)
		if result ~= 0 then
			error("Failed to get present mode count, error code: " .. tostring(result))
		end

		local modes = ffi.new("VkPresentModeKHR[?]", count[0])
		result = C.vkGetPhysicalDeviceSurfacePresentModesKHR(physicalDevice, surface, count, modes)
		if result ~= 0 then
			error("Failed to get present modes, error code: " .. tostring(result))
		end

		local modeTable = {}
		for i = 0, count[0] - 1 do
			modeTable[i + 1] = modes[i]
		end
		return modeTable
	end

	vkGlobal.getInstanceProcAddr = C.vkGetInstanceProcAddr
	vkGlobal.getDeviceProcAddr = C.vkGetDeviceProcAddr
end

local globalInstance = vkGlobal.createInstance({})
local globalPhysicalDevice = vkGlobal.enumeratePhysicalDevices(globalInstance)[1]

local vkInstance = {}
do
	local types = {
		vkCreateDevice = "VkDevice(*)(VkPhysicalDevice, const VkDeviceCreateInfo*, const void*, VkDevice*)",
	}

	local C = {}
	for name, funcType in pairs(types) do
		C[name] = ffi.cast(funcType, vkGlobal.getInstanceProcAddr(globalInstance, name))
	end

	---@param physicalDevice vk.PhysicalDevice
	---@param info vk.ffi.DeviceCreateInfo?
	---@param allocator ffi.cdata*?
	---@return vk.Device
	function vkInstance.createDevice(physicalDevice, info, allocator)
		local device = ffi.new("VkDevice[1]")
		local info = ffi.new("VkDeviceCreateInfo", info or {})
		info.sType = vkGlobal.StructureType.DEVICE_CREATE_INFO

		local result = C.vkCreateDevice(physicalDevice, info, allocator, device)
		if result ~= 0 then
			error("Failed to create Vulkan device, error code: " .. tostring(result))
		end

		return device[0]
	end
end

local globalDevice = vkInstance.createDevice(globalPhysicalDevice, {})

local vkDevice = {}
do
	local types = {
		vkCreateBuffer = "VkResult(*)(VkDevice, const VkBufferCreateInfo*, const VkAllocationCallbacks*, VkBuffer*)",
		vkDestroyBuffer = "void(*)(VkDevice, VkBuffer, const VkAllocationCallbacks*)",
		vkCreateShaderModule = "VkResult(*)(VkDevice, const VkShaderModuleCreateInfo*, const VkAllocationCallbacks*, VkShaderModule*)",
		vkCreatePipelineLayout = "VkResult(*)(VkDevice, const VkPipelineLayoutCreateInfo*, const VkAllocationCallbacks*, VkPipelineLayout*)",
		vkCreateGraphicsPipelines = "VkResult(*)(VkDevice, uint64_t, uint32_t, const VkGraphicsPipelineCreateInfo*, const VkAllocationCallbacks*, VkPipeline*)",
		vkCreateRenderPass = "VkResult(*)(VkDevice, const VkRenderPassCreateInfo*, const VkAllocationCallbacks*, VkRenderPass*)",
		vkCreateFramebuffer = "VkResult(*)(VkDevice, const VkFramebufferCreateInfo*, const VkAllocationCallbacks*, VkFramebuffer*)",
		vkGetBufferMemoryRequirements = "void(*)(VkDevice, VkBuffer, VkMemoryRequirements*)",
		vkGetImageMemoryRequirements = "void(*)(VkDevice, VkImage, VkMemoryRequirements*)",
		vkCreateImage = "VkResult(*)(VkDevice, const VkImageCreateInfo*, const VkAllocationCallbacks*, VkImage*)",
		vkBindImageMemory = "VkResult(*)(VkDevice, VkImage, VkDeviceMemory, VkDeviceSize)",
		vkAllocateMemory = "VkResult(*)(VkDevice, const VkMemoryAllocateInfo*, const VkAllocationCallbacks*, VkDeviceMemory*)",
		vkBindBufferMemory = "VkResult(*)(VkDevice, VkBuffer, VkDeviceMemory, VkDeviceSize)",
		vkMapMemory = "VkResult(*)(VkDevice, VkDeviceMemory, VkDeviceSize, VkDeviceSize, VkFlags, void**)",
		vkUnmapMemory = "void(*)(VkDevice, VkDeviceMemory)",
		vkCreateCommandPool = "VkResult(*)(VkDevice, const VkCommandPoolCreateInfo*, const VkAllocationCallbacks*, VkCommandPool*)",
		vkCreateDescriptorSetLayout = "VkResult(*)(VkDevice, const VkDescriptorSetLayoutCreateInfo*, const VkAllocationCallbacks*, VkDescriptorSetLayout*)",
		vkCreateDescriptorPool = "VkResult(*)(VkDevice, const VkDescriptorPoolCreateInfo*, const VkAllocationCallbacks*, VkDescriptorPool*)",
		vkAllocateDescriptorSets = "VkResult(*)(VkDevice, const VkDescriptorSetAllocateInfo*, VkDescriptorSet*)",
		vkUpdateDescriptorSets = "void(*)(VkDevice, uint32_t, const VkWriteDescriptorSet*, uint32_t, const void*)",
		vkAllocateCommandBuffers = "VkResult(*)(VkDevice, const VkCommandBufferAllocateInfo*, VkCommandBuffer*)",
		vkBeginCommandBuffer = "VkResult(*)(VkCommandBuffer, const VkCommandBufferBeginInfo*)",
		vkEndCommandBuffer = "VkResult(*)(VkCommandBuffer)",
		vkCmdBeginRenderPass = "void(*)(VkCommandBuffer, const VkRenderPassBeginInfo*, VkSubpassContents)",
		vkCmdEndRenderPass = "void(*)(VkCommandBuffer)",
		vkCmdBindPipeline = "void(*)(VkCommandBuffer, VkPipelineBindPoint, VkPipeline)",
		vkCmdDraw = "void(*)(VkCommandBuffer, uint32_t, uint32_t, uint32_t, uint32_t)",
		vkCmdBindDescriptorSets = "void(*)(VkCommandBuffer, VkPipelineBindPoint, VkPipelineLayout, uint32_t, uint32_t, const VkDescriptorSet*, uint32_t, const uint32_t*)",
		vkCmdCopyBufferToImage = "void(*)(VkCommandBuffer, VkBuffer, VkImage, VkImageLayout, uint32_t, const VkBufferImageCopy*)",
		vkQueueSubmit = "VkResult(*)(VkQueue, uint32_t, const VkSubmitInfo*, uint64_t)",
		vkQueueWaitIdle = "VkResult(*)(VkQueue)",
		vkGetDeviceQueue = "void(*)(VkDevice, uint32_t, uint32_t, VkQueue*)",
		vkCreateSemaphore = "VkResult(*)(VkDevice, const VkSemaphoreCreateInfo*, const VkAllocationCallbacks*, VkSemaphore*)",
		vkCreateFence = "VkResult(*)(VkDevice, const VkFenceCreateInfo*, const VkAllocationCallbacks*, VkFence*)",
		vkCreateSwapchainKHR = "VkResult(*)(VkDevice, const VkSwapchainCreateInfoKHR*, const VkAllocationCallbacks*, VkSwapchainKHR*)",
		vkGetSwapchainImagesKHR = "VkResult(*)(VkDevice, VkSwapchainKHR, uint32_t*, VkImage*)",
		vkAcquireNextImageKHR = "VkResult(*)(VkDevice, VkSwapchainKHR, uint64_t, VkSemaphore, VkFence, uint32_t*)",
		vkQueuePresentKHR = "VkResult(*)(VkQueue, const VkPresentInfoKHR*)",
	}

	for name, funcType in pairs(types) do
		vkDevice[name] = ffi.cast(funcType, vkGlobal.getDeviceProcAddr(globalDevice, name))
	end
end

local vk = {}

-- Globals
do
	vk.StructureType = vkGlobal.StructureType
	vk.getPhysicalDeviceMemoryProperties = vkGlobal.getPhysicalDeviceMemoryProperties
	vk.getPhysicalDeviceQueueFamilyProperties = vkGlobal.getPhysicalDeviceQueueFamilyProperties
	vk.getPhysicalDeviceSurfaceCapabilitiesKHR = vkGlobal.getPhysicalDeviceSurfaceCapabilitiesKHR
	vk.getPhysicalDeviceSurfaceFormatsKHR = vkGlobal.getPhysicalDeviceSurfaceFormatsKHR
	vk.getPhysicalDeviceSurfacePresentModesKHR = vkGlobal.getPhysicalDeviceSurfacePresentModesKHR

	---@enum vk.PhysicalDeviceType
	vk.PhysicalDeviceType = {
		OTHER = 0,
		INTEGRATED_GPU = 1,
		DISCRETE_GPU = 2,
		VIRTUAL_GPU = 3,
		CPU = 4,
	}

	---@enum vk.ImageLayout
	vk.ImageLayout = {
		UNDEFINED = 0,
		GENERAL = 1,
		COLOR_ATTACHMENT_OPTIMAL = 2,
		DEPTH_STENCIL_ATTACHMENT_OPTIMAL = 3,
		DEPTH_STENCIL_READ_ONLY_OPTIMAL = 4,
		SHADER_READ_ONLY_OPTIMAL = 5,
		TRANSFER_SRC_OPTIMAL = 6,
		TRANSFER_DST_OPTIMAL = 7,
		PREINITIALIZED = 8,
	}

	---@enum vk.ImageType
	vk.ImageType = {
		TYPE_1D = 0,
		TYPE_2D = 1,
		TYPE_3D = 2,
	}

	---@enum vk.BufferUsage
	vk.BufferUsage = {
		TRANSFER_SRC = 0x00000001,
		TRANSFER_DST = 0x00000002,
		UNIFORM_TEXEL_BUFFER = 0x00000004,
		STORAGE_TEXEL_BUFFER = 0x00000008,
		UNIFORM_BUFFER = 0x00000010,
		STORAGE_BUFFER = 0x00000020,
		INDEX_BUFFER = 0x00000040,
		VERTEX_BUFFER = 0x00000080,
		INDIRECT_BUFFER = 0x00000100,
	}

	---@enum vk.SharingMode
	vk.SharingMode = {
		EXCLUSIVE = 0,
		CONCURRENT = 1,
	}

	---@enum vk.PipelineBindPoint
	vk.PipelineBindPoint = {
		GRAPHICS = 0,
		COMPUTE = 1,
	}

	---@enum vk.SubpassContents
	vk.SubpassContents = {
		INLINE = 0,
		SECONDARY_COMMAND_BUFFERS = 1,
	}

	---@enum vk.CommandBufferLevel
	vk.CommandBufferLevel = {
		PRIMARY = 0,
		SECONDARY = 1,
	}

	---@enum vk.QueueFlagBits
	vk.QueueFlagBits = {
		GRAPHICS = 0x00000001,
		COMPUTE = 0x00000002,
		TRANSFER = 0x00000004,
	}

	vk.getPhysicalDeviceProperties = vkGlobal.getPhysicalDeviceProperties

	function vk.newRenderPassBeginInfo()
		local info = ffi.new("VkRenderPassBeginInfo")
		info.sType = vk.StructureType.RENDER_PASS_BEGIN_INFO
		return info --[[@as vk.ffi.RenderPassBeginInfo]]
	end
end

-- Instance
do
	function vk.enumeratePhysicalDevices()
		return vkGlobal.enumeratePhysicalDevices(globalInstance)
	end

	vk.createDevice = vkInstance.createDevice
end

-- Device
do
	---@param device vk.Device
	---@param info vk.ffi.BufferCreateInfo
	---@param allocator ffi.cdata*?
	---@return vk.Buffer
	function vk.createBuffer(device, info, allocator)
		local info = ffi.new("VkBufferCreateInfo", info)
		info.sType = vk.StructureType.BUFFER_CREATE_INFO

		local buffer = ffi.new("VkBuffer[1]")
		local result = vkDevice.vkCreateBuffer(device, info, allocator, buffer)
		if result ~= 0 then
			error("Failed to create Vulkan buffer, error code: " .. tostring(result))
		end

		return buffer[0]
	end

	---@param device vk.Device
	---@param buffer vk.Buffer
	---@param allocator ffi.cdata*?
	function vk.destroyBuffer(device, buffer, allocator)
		vkDevice.vkDestroyBuffer(device, buffer, allocator)
	end

	---@param device vk.Device
	---@param info vk.ffi.ShaderModuleCreateInfo
	---@param allocator ffi.cdata*?
	---@return vk.ShaderModule
	function vk.createShaderModule(device, info, allocator)
		local info = ffi.new("VkShaderModuleCreateInfo", info)
		info.sType = vk.StructureType.SHADER_MODULE_CREATE_INFO

		local shaderModule = ffi.new("VkShaderModule[1]")
		local result = vkDevice.vkCreateShaderModule(device, info, allocator, shaderModule)
		if result ~= 0 then
			error("Failed to create Vulkan shader module, error code: " .. tostring(result))
		end

		return shaderModule[0]
	end

	---@param device vk.Device
	---@param info vk.ffi.PipelineLayoutCreateInfo
	---@param allocator ffi.cdata*?
	---@return vk.PipelineLayout
	function vk.createPipelineLayout(device, info, allocator)
		local info = ffi.new("VkPipelineLayoutCreateInfo", info)
		info.sType = vk.StructureType.PIPELINE_LAYOUT_CREATE_INFO

		local pipelineLayout = ffi.new("VkPipelineLayout[1]")
		local result = vkDevice.vkCreatePipelineLayout(device, info, allocator, pipelineLayout)
		if result ~= 0 then
			error("Failed to create Vulkan pipeline layout, error code: " .. tostring(result))
		end

		return pipelineLayout[0]
	end

	---@param device vk.Device
	---@param pipelineCache number?
	---@param infos vk.ffi.GraphicsPipelineCreateInfo[]
	---@param allocator ffi.cdata*?
	---@return vk.Pipeline[]
	function vk.createGraphicsPipelines(device, pipelineCache, infos, allocator)
		local count = #infos
		local infoArray = ffi.new("VkGraphicsPipelineCreateInfo[?]", count)

		for i = 1, count do
			local info = ffi.new("VkGraphicsPipelineCreateInfo", infos[i])
			info.sType = vk.StructureType.GRAPHICS_PIPELINE_CREATE_INFO
			infoArray[i - 1] = info
		end

		local pipelines = ffi.new("VkPipeline[?]", count)
		local result = vkDevice.vkCreateGraphicsPipelines(device, pipelineCache or 0, count, infoArray, allocator,
			pipelines)
		if result ~= 0 then
			error("Failed to create Vulkan graphics pipelines, error code: " .. tostring(result))
		end

		local pipelineList = {}
		for i = 0, count - 1 do
			pipelineList[i + 1] = pipelines[i]
		end

		return pipelineList
	end

	---@param device vk.Device
	---@param info vk.ffi.RenderPassCreateInfo
	---@param allocator ffi.cdata*?
	---@return vk.RenderPass
	function vk.createRenderPass(device, info, allocator)
		local info = ffi.new("VkRenderPassCreateInfo", info)
		info.sType = vk.StructureType.RENDER_PASS_CREATE_INFO

		local renderPass = ffi.new("VkRenderPass[1]")
		local result = vkDevice.vkCreateRenderPass(device, info, allocator, renderPass)
		if result ~= 0 then
			error("Failed to create Vulkan render pass, error code: " .. tostring(result))
		end

		return renderPass[0]
	end

	---@param device vk.Device
	---@param info vk.ffi.FramebufferCreateInfo
	---@param allocator ffi.cdata*?
	---@return vk.Framebuffer
	function vk.createFramebuffer(device, info, allocator)
		local info = ffi.new("VkFramebufferCreateInfo", info)
		info.sType = vk.StructureType.FRAMEBUFFER_CREATE_INFO
		local framebuffer = ffi.new("VkFramebuffer[1]")
		local result = vkDevice.vkCreateFramebuffer(device, info, allocator, framebuffer)
		if result ~= 0 then
			error("Failed to create Vulkan framebuffer, error code: " .. tostring(result))
		end
		return framebuffer[0]
	end

	---@param device vk.Device
	---@param info vk.ffi.CommandPoolCreateInfo
	---@param allocator ffi.cdata*?
	---@return vk.CommandPool
	function vk.createCommandPool(device, info, allocator)
		local createInfo = ffi.new("VkCommandPoolCreateInfo", info)
		createInfo.sType = vk.StructureType.COMMAND_POOL_CREATE_INFO

		local commandPool = ffi.new("VkCommandPool[1]")
		local result = vkDevice.vkCreateCommandPool(device, createInfo, allocator, commandPool)
		if result ~= 0 then
			error("Failed to create Vulkan command pool, error code: " .. tostring(result))
		end

		return commandPool[0]
	end

	---@param device vk.Device
	---@param buffer vk.Buffer
	---@return vk.MemoryRequirements
	function vk.getBufferMemoryRequirements(device, buffer)
		local memRequirements = ffi.new("VkMemoryRequirements")
		vkDevice.vkGetBufferMemoryRequirements(device, buffer, memRequirements)
		return memRequirements
	end

	---@param device vk.Device
	---@param image vk.Image
	---@return vk.MemoryRequirements
	function vk.getImageMemoryRequirements(device, image)
		local memRequirements = ffi.new("VkMemoryRequirements")
		vkDevice.vkGetImageMemoryRequirements(device, image, memRequirements)
		return memRequirements
	end

	---@param device vk.Device
	---@param createInfo vk.ffi.CreateImageInfo
	---@param allocator ffi.cdata*?
	---@return vk.Image
	function vk.createImage(device, createInfo, allocator)
		local image = ffi.new("VkImage[1]")
		local result = vkDevice.vkCreateImage(device, createInfo, allocator, image)
		if result ~= 0 then
			error("Failed to create Vulkan image, error code: " .. tostring(result))
		end
		return image[0]
	end

	---@param device vk.Device
	---@param image vk.Image
	---@param memory vk.DeviceMemory
	---@param memoryOffset vk.DeviceSize
	function vk.bindImageMemory(device, image, memory, memoryOffset)
		local result = vkDevice.vkBindImageMemory(device, image, memory, memoryOffset)
		if result ~= 0 then
			error("Failed to bind image memory, error code: " .. tostring(result))
		end
	end

	---@param commandBuffer vk.CommandBuffer
	function vk.endCommandBuffer(commandBuffer)
		local result = vkDevice.vkEndCommandBuffer(commandBuffer)
		if result ~= 0 then
			error("Failed to end command buffer, error code: " .. tostring(result))
		end
	end

	---@param device vk.Device
	---@param info vk.ffi.MemoryAllocateInfo
	---@param allocator ffi.cdata*?
	---@return vk.DeviceMemory
	function vk.allocateMemory(device, info, allocator)
		local allocInfo = ffi.new("VkMemoryAllocateInfo", info)
		allocInfo.sType = vk.StructureType.MEMORY_ALLOCATE_INFO
		local memory = ffi.new("VkDeviceMemory[1]")
		local result = vkDevice.vkAllocateMemory(device, allocInfo, allocator, memory)
		if result ~= 0 then
			error("Failed to allocate Vulkan memory, error code: " .. tostring(result))
		end
		return memory[0]
	end

	---@param device vk.Device
	---@param buffer vk.Buffer
	---@param memory vk.DeviceMemory
	---@param memoryOffset vk.DeviceSize
	function vk.bindBufferMemory(device, buffer, memory, memoryOffset)
		local result = vkDevice.vkBindBufferMemory(device, buffer, memory, memoryOffset)
		if result ~= 0 then
			error("Failed to bind buffer memory, error code: " .. tostring(result))
		end
	end

	---@param device vk.Device
	---@param memory vk.DeviceMemory
	---@param offset number
	---@param size number
	---@param flags number?
	---@return ffi.cdata*
	function vk.mapMemory(device, memory, offset, size, flags)
		local data = ffi.new("void*[1]")
		local result = vkDevice.vkMapMemory(device, memory, offset, size, flags or 0, data)
		if result ~= 0 then
			error("Failed to map memory, error code: " .. tostring(result))
		end
		return data[0]
	end

	---@param device vk.Device
	---@param memory vk.DeviceMemory
	function vk.unmapMemory(device, memory)
		vkDevice.vkUnmapMemory(device, memory)
	end

	---@param device vk.Device
	---@param info vk.ffi.DescriptorSetLayoutCreateInfo
	---@param allocator ffi.cdata*?
	---@return vk.DescriptorSetLayout
	function vk.createDescriptorSetLayout(device, info, allocator)
		local createInfo = ffi.new("VkDescriptorSetLayoutCreateInfo", info)
		createInfo.sType = vk.StructureType.DESCRIPTOR_SET_LAYOUT_CREATE_INFO
		local layout = ffi.new("VkDescriptorSetLayout[1]")
		local result = vkDevice.vkCreateDescriptorSetLayout(device, createInfo, allocator, layout)
		if result ~= 0 then
			error("Failed to create Vulkan descriptor set layout, error code: " .. tostring(result))
		end
		return layout[0]
	end

	---@param device vk.Device
	---@param info vk.ffi.DescriptorPoolCreateInfo
	---@param allocator ffi.cdata*?
	---@return vk.DescriptorPool
	function vk.createDescriptorPool(device, info, allocator)
		local createInfo = ffi.new("VkDescriptorPoolCreateInfo", info)
		createInfo.sType = vk.StructureType.DESCRIPTOR_POOL_CREATE_INFO
		local pool = ffi.new("VkDescriptorPool[1]")
		local result = vkDevice.vkCreateDescriptorPool(device, createInfo, allocator, pool)
		if result ~= 0 then
			error("Failed to create Vulkan descriptor pool, error code: " .. tostring(result))
		end
		return pool[0]
	end

	---@param device vk.Device
	---@param info vk.ffi.DescriptorSetAllocateInfo
	---@return vk.DescriptorSet[]
	function vk.allocateDescriptorSets(device, info)
		local allocInfo = ffi.new("VkDescriptorSetAllocateInfo", info)
		allocInfo.sType = vk.StructureType.DESCRIPTOR_SET_ALLOCATE_INFO
		local descriptorSets = ffi.new("VkDescriptorSet[?]", info.descriptorSetCount)
		local result = vkDevice.vkAllocateDescriptorSets(device, allocInfo, descriptorSets)
		if result ~= 0 then
			error("Failed to allocate Vulkan descriptor sets, error code: " .. tostring(result))
		end
		local sets = {}
		for i = 0, info.descriptorSetCount - 1 do
			sets[i + 1] = descriptorSets[i]
		end
		return sets
	end

	---@param device vk.Device
	---@param writes vk.ffi.WriteDescriptorSet[]
	function vk.updateDescriptorSets(device, writes)
		local count = #writes
		local writeArray = ffi.new("VkWriteDescriptorSet[?]", count)
		for i, write in ipairs(writes) do
			local w = ffi.new("VkWriteDescriptorSet", write)
			w.sType = vk.StructureType.WRITE_DESCRIPTOR_SET
			writeArray[i - 1] = w
		end
		vkDevice.vkUpdateDescriptorSets(device, count, writeArray, 0, nil)
	end

	---@param device vk.Device
	---@param info vk.ffi.CommandBufferAllocateInfo
	---@return vk.CommandBuffer[]
	function vk.allocateCommandBuffers(device, info)
		local info = ffi.new("VkCommandBufferAllocateInfo", info)
		info.sType = vk.StructureType.COMMAND_BUFFER_ALLOCATE_INFO

		local commandBuffers = ffi.new("VkCommandBuffer[?]", info.commandBufferCount)
		local result = vkDevice.vkAllocateCommandBuffers(device, info, commandBuffers)
		if result ~= 0 then
			error("Failed to allocate Vulkan command buffers, error code: " .. tostring(result))
		end

		local commandBufferList = {}
		for i = 0, info.commandBufferCount - 1 do
			commandBufferList[i + 1] = commandBuffers[i]
		end

		return commandBufferList
	end

	---@param commandBuffer vk.CommandBuffer
	---@param info vk.ffi.CommandBufferBeginInfo?
	function vk.beginCommandBuffer(commandBuffer, info)
		local info = ffi.new("VkCommandBufferBeginInfo", info or {})
		info.sType = vk.StructureType.COMMAND_BUFFER_BEGIN_INFO

		local result = vkDevice.vkBeginCommandBuffer(commandBuffer, info)
		if result ~= 0 then
			error("Failed to begin Vulkan command buffer, error code: " .. tostring(result))
		end
	end

	---@param commandBuffer vk.CommandBuffer
	function vk.endCommandBuffer(commandBuffer)
		local result = vkDevice.vkEndCommandBuffer(commandBuffer)
		if result ~= 0 then
			error("Failed to end Vulkan command buffer, error code: " .. tostring(result))
		end
	end

	---@type fun(commandBuffer: vk.CommandBuffer, info: vk.ffi.RenderPassBeginInfo, contents: vk.SubpassContents)
	vk.cmdBeginRenderPass = vkDevice.vkCmdBeginRenderPass

	---@type fun(commandBuffer: vk.CommandBuffer)
	vk.cmdEndRenderPass = vkDevice.vkCmdEndRenderPass

	---@type fun(commandBuffer: vk.CommandBuffer, pipelineBindPoint: vk.PipelineBindPoint, pipeline: vk.Pipeline)
	vk.cmdBindPipeline = vkDevice.vkCmdBindPipeline

	---@type fun(commandBuffer: vk.CommandBuffer, vertexCount: number, instanceCount: number, firstVertex: number, firstInstance: number)
	vk.cmdDraw = vkDevice.vkCmdDraw

	---@type fun(commandBuffer: vk.CommandBuffer, srcBuffer: vk.Buffer, dstImage: vk.Image, dstImageLayout: vk.ImageLayout, regionCount: number, pRegions: ffi.cdata*)
	vk.cmdCopyBufferToImage = vkDevice.vkCmdCopyBufferToImage

	---@param queue vk.Queue
	---@param submits vk.ffi.SubmitInfo[]
	---@param fence number?
	function vk.queueSubmit(queue, submits, fence)
		local count = #submits
		local submitArray = ffi.new("VkSubmitInfo[?]", count)

		for i = 1, count do
			local submit = ffi.new("VkSubmitInfo", submits[i])
			submit.sType = vk.StructureType.SUBMIT_INFO
			submitArray[i - 1] = submit
		end

		local result = vkDevice.vkQueueSubmit(queue, count, submitArray, fence or 0)
		if result ~= 0 then
			error("Failed to submit to Vulkan queue, error code: " .. tostring(result))
		end
	end

	---@param queue vk.Queue
	function vk.queueWaitIdle(queue)
		local result = vkDevice.vkQueueWaitIdle(queue)
		if result ~= 0 then
			error("Failed to wait for Vulkan queue idle, error code: " .. tostring(result))
		end
	end

	---@param device vk.Device
	---@param queueFamilyIndex number
	---@param queueIndex number
	---@return vk.Queue
	function vk.getDeviceQueue(device, queueFamilyIndex, queueIndex)
		local queue = ffi.new("VkQueue[1]")
		vkDevice.vkGetDeviceQueue(device, queueFamilyIndex, queueIndex, queue)
		return queue[0]
	end

	---@param device vk.Device
	---@param info vk.ffi.SemaphoreCreateInfo
	---@param allocator ffi.cdata*?
	---@return vk.Semaphore
	function vk.createSemaphore(device, info, allocator)
		local createInfo = ffi.new("VkSemaphoreCreateInfo", info)
		createInfo.sType = vk.StructureType.SEMAPHORE_CREATE_INFO
		local semaphore = ffi.new("VkSemaphore[1]")
		local result = vkDevice.vkCreateSemaphore(device, createInfo, allocator, semaphore)
		if result ~= 0 then
			error("Failed to create Vulkan semaphore, error code: " .. tostring(result))
		end
		return semaphore[0]
	end

	---@param device vk.Device
	---@param info vk.ffi.FenceCreateInfo
	---@param allocator ffi.cdata*?
	---@return vk.Fence
	function vk.createFence(device, info, allocator)
		local createInfo = ffi.new("VkFenceCreateInfo", info)
		createInfo.sType = vk.StructureType.FENCE_CREATE_INFO
		local fence = ffi.new("VkFence[1]")
		local result = vkDevice.vkCreateFence(device, createInfo, allocator, fence)
		if result ~= 0 then
			error("Failed to create Vulkan fence, error code: " .. tostring(result))
		end
		return fence[0]
	end

	---@param device vk.Device
	---@param info vk.ffi.SwapchainCreateInfoKHR
	---@param allocator ffi.cdata*?
	---@return vk.SwapchainKHR
	function vk.createSwapchainKHR(device, info, allocator)
		local info = ffi.new("VkSwapchainCreateInfoKHR", info)
		info.sType = vk.StructureType.SWAPCHAIN_CREATE_INFO_KHR
		local swapchain = ffi.new("VkSwapchainKHR[1]")
		local result = vkDevice.vkCreateSwapchainKHR(device, info, allocator, swapchain)
		if result ~= 0 then
			error("Failed to create Vulkan swapchain, error code: " .. tostring(result))
		end
		return swapchain[0]
	end

	---@param device vk.Device
	---@param swapchain vk.SwapchainKHR
	---@return vk.Image[]
	function vk.getSwapchainImagesKHR(device, swapchain)
		local count = ffi.new("uint32_t[1]")
		local result = vkDevice.vkGetSwapchainImagesKHR(device, swapchain, count, nil)
		if result ~= 0 then
			error("Failed to get swapchain image count, error code: " .. tostring(result))
		end

		local images = ffi.new("VkImage[?]", count[0])
		result = vkDevice.vkGetSwapchainImagesKHR(device, swapchain, count, images)
		if result ~= 0 then
			error("Failed to get swapchain images, error code: " .. tostring(result))
		end

		local imageTable = {}
		for i = 0, count[0] - 1 do
			imageTable[i + 1] = images[i]
		end
		return imageTable
	end

	---@param device vk.Device
	---@param swapchain vk.SwapchainKHR
	---@param timeout number
	---@param semaphore vk.Semaphore?
	---@param fence vk.Fence?
	---@return number imageIndex
	function vk.acquireNextImageKHR(device, swapchain, timeout, semaphore, fence)
		local imageIndex = ffi.new("uint32_t[1]")
		local result = vkDevice.vkAcquireNextImageKHR(device, swapchain, timeout, semaphore or 0, fence or 0, imageIndex)
		if result ~= 0 then
			error("Failed to acquire next swapchain image, error code: " .. tostring(result))
		end
		return imageIndex[0]
	end

	---@param queue vk.Queue
	---@param info vk.ffi.PresentInfoKHR
	function vk.queuePresentKHR(queue, info)
		local presentInfo = ffi.new("VkPresentInfoKHR", info)
		presentInfo.sType = vk.StructureType.PRESENT_INFO_KHR
		local result = vkDevice.vkQueuePresentKHR(queue, presentInfo)
		if result ~= 0 then
			error("Failed to present queue, error code: " .. tostring(result))
		end
	end
end

return vk
