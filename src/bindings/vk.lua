local util = require("util")
local ffi = require("ffi")

ffi.cdef([[
	typedef uint64_t VkInstance;
	typedef uint64_t VkDevice;
	typedef int32_t VkResult;
	typedef int32_t VkStructureType;
	typedef uint32_t VkFlags;
	typedef void* VkPhysicalDevice;
	typedef uint32_t VkBool32;
	typedef VkFlags VkSampleCountFlags;
	typedef uint64_t VkDeviceSize;
	typedef uint32_t VkPhysicalDeviceType;
	typedef uint64_t VkBuffer;
	typedef VkFlags VkBufferCreateFlags;
	typedef VkFlags VkBufferUsageFlags;
	typedef uint32_t VkSharingMode;
	typedef void VkAllocationCallbacks;
	typedef VkFlags VkShaderModuleCreateFlags;

	typedef struct {
		VkStructureType     sType;
		const void*         pNext;
		const char*         pApplicationName;
		uint32_t            applicationVersion;
		const char*         pEngineName;
		uint32_t            engineVersion;
		uint32_t            apiVersion;
	} VkApplicationInfo;

	typedef struct {
		VkStructureType             sType;
		const void*                 pNext;
		VkFlags                     flags;
		const VkApplicationInfo*    pApplicationInfo;
		uint32_t                    enabledLayerCount;
		const char* const*          ppEnabledLayerNames;
		uint32_t                    enabledExtensionCount;
		const char* const*          ppEnabledExtensionNames;
	} VkInstanceCreateInfo;

	void* vkGetInstanceProcAddr(VkInstance instance, const char* pName);
	void* vkGetDeviceProcAddr(VkDevice device, const char* pName);

	VkResult vkCreateInstance(
		const VkInstanceCreateInfo* pCreateInfo,
		const void* pAllocator,
		VkInstance* pInstance
	);

	VkResult vkEnumeratePhysicalDevices(
		VkInstance instance,
		uint32_t* pPhysicalDeviceCount,
		VkPhysicalDevice* pPhysicalDevices
	);

	typedef struct {
    	VkBool32    robustBufferAccess;
        VkBool32    fullDrawIndexUint32;
        VkBool32    imageCubeArray;
        VkBool32    independentBlend;
        VkBool32    geometryShader;
        VkBool32    tessellationShader;
        VkBool32    sampleRateShading;
        VkBool32    dualSrcBlend;
        VkBool32    logicOp;
        VkBool32    multiDrawIndirect;
        VkBool32    drawIndirectFirstInstance;
        VkBool32    depthClamp;
        VkBool32    depthBiasClamp;
        VkBool32    fillModeNonSolid;
        VkBool32    depthBounds;
        VkBool32    wideLines;
        VkBool32    largePoints;
        VkBool32    alphaToOne;
        VkBool32    multiViewport;
        VkBool32    samplerAnisotropy;
        VkBool32    textureCompressionETC2;
        VkBool32    textureCompressionASTC_LDR;
        VkBool32    textureCompressionBC;
        VkBool32    occlusionQueryPrecise;
        VkBool32    pipelineStatisticsQuery;
        VkBool32    vertexPipelineStoresAndAtomics;
        VkBool32    fragmentStoresAndAtomics;
        VkBool32    shaderTessellationAndGeometryPointSize;
        VkBool32    shaderImageGatherExtended;
        VkBool32    shaderStorageImageExtendedFormats;
        VkBool32    shaderStorageImageMultisample;
        VkBool32    shaderStorageImageReadWithoutFormat;
        VkBool32    shaderStorageImageWriteWithoutFormat;
        VkBool32    shaderUniformBufferArrayDynamicIndexing;
        VkBool32    shaderSampledImageArrayDynamicIndexing;
        VkBool32    shaderStorageBufferArrayDynamicIndexing;
        VkBool32    shaderStorageImageArrayDynamicIndexing;
        VkBool32    shaderClipDistance;
        VkBool32    shaderCullDistance;
        VkBool32    shaderFloat64;
        VkBool32    shaderInt64;
        VkBool32    shaderInt16;
        VkBool32    shaderResourceResidency;
        VkBool32    shaderResourceMinLod;
        VkBool32    sparseBinding;
        VkBool32    sparseResidencyBuffer;
        VkBool32    sparseResidencyImage2D;
        VkBool32    sparseResidencyImage3D;
        VkBool32    sparseResidency2Samples;
        VkBool32    sparseResidency4Samples;
        VkBool32    sparseResidency8Samples;
        VkBool32    sparseResidency16Samples;
        VkBool32    sparseResidencyAliased;
        VkBool32    variableMultisampleRate;
        VkBool32    inheritedQueries;
	} VkPhysicalDeviceFeatures;

	typedef struct {
    	uint32_t              maxImageDimension1D;
        uint32_t              maxImageDimension2D;
        uint32_t              maxImageDimension3D;
        uint32_t              maxImageDimensionCube;
        uint32_t              maxImageArrayLayers;
        uint32_t              maxTexelBufferElements;
        uint32_t              maxUniformBufferRange;
        uint32_t              maxStorageBufferRange;
        uint32_t              maxPushConstantsSize;
        uint32_t              maxMemoryAllocationCount;
        uint32_t              maxSamplerAllocationCount;
        VkDeviceSize          bufferImageGranularity;
        VkDeviceSize          sparseAddressSpaceSize;
        uint32_t              maxBoundDescriptorSets;
        uint32_t              maxPerStageDescriptorSamplers;
        uint32_t              maxPerStageDescriptorUniformBuffers;
        uint32_t              maxPerStageDescriptorStorageBuffers;
        uint32_t              maxPerStageDescriptorSampledImages;
        uint32_t              maxPerStageDescriptorStorageImages;
        uint32_t              maxPerStageDescriptorInputAttachments;
        uint32_t              maxPerStageResources;
        uint32_t              maxDescriptorSetSamplers;
        uint32_t              maxDescriptorSetUniformBuffers;
        uint32_t              maxDescriptorSetUniformBuffersDynamic;
        uint32_t              maxDescriptorSetStorageBuffers;
        uint32_t              maxDescriptorSetStorageBuffersDynamic;
        uint32_t              maxDescriptorSetSampledImages;
        uint32_t              maxDescriptorSetStorageImages;
        uint32_t              maxDescriptorSetInputAttachments;
        uint32_t              maxVertexInputAttributes;
        uint32_t              maxVertexInputBindings;
        uint32_t              maxVertexInputAttributeOffset;
        uint32_t              maxVertexInputBindingStride;
        uint32_t              maxVertexOutputComponents;
        uint32_t              maxTessellationGenerationLevel;
        uint32_t              maxTessellationPatchSize;
        uint32_t              maxTessellationControlPerVertexInputComponents;
        uint32_t              maxTessellationControlPerVertexOutputComponents;
        uint32_t              maxTessellationControlPerPatchOutputComponents;
        uint32_t              maxTessellationControlTotalOutputComponents;
        uint32_t              maxTessellationEvaluationInputComponents;
        uint32_t              maxTessellationEvaluationOutputComponents;
        uint32_t              maxGeometryShaderInvocations;
        uint32_t              maxGeometryInputComponents;
        uint32_t              maxGeometryOutputComponents;
        uint32_t              maxGeometryOutputVertices;
        uint32_t              maxGeometryTotalOutputComponents;
        uint32_t              maxFragmentInputComponents;
        uint32_t              maxFragmentOutputAttachments;
        uint32_t              maxFragmentDualSrcAttachments;
        uint32_t              maxFragmentCombinedOutputResources;
        uint32_t              maxComputeSharedMemorySize;
        uint32_t              maxComputeWorkGroupCount[3];
        uint32_t              maxComputeWorkGroupInvocations;
        uint32_t              maxComputeWorkGroupSize[3];
        uint32_t              subPixelPrecisionBits;
        uint32_t              subTexelPrecisionBits;
        uint32_t              mipmapPrecisionBits;
        uint32_t              maxDrawIndexedIndexValue;
        uint32_t              maxDrawIndirectCount;
        float                 maxSamplerLodBias;
        float                 maxSamplerAnisotropy;
        uint32_t              maxViewports;
        uint32_t              maxViewportDimensions[2];
        float                 viewportBoundsRange[2];
        uint32_t              viewportSubPixelBits;
        size_t                minMemoryMapAlignment;
        VkDeviceSize          minTexelBufferOffsetAlignment;
        VkDeviceSize          minUniformBufferOffsetAlignment;
        VkDeviceSize          minStorageBufferOffsetAlignment;
        int32_t               minTexelOffset;
        uint32_t              maxTexelOffset;
        int32_t               minTexelGatherOffset;
        uint32_t              maxTexelGatherOffset;
        float                 minInterpolationOffset;
        float                 maxInterpolationOffset;
        uint32_t              subPixelInterpolationOffsetBits;
        uint32_t              maxFramebufferWidth;
        uint32_t              maxFramebufferHeight;
        uint32_t              maxFramebufferLayers;
        VkSampleCountFlags    framebufferColorSampleCounts;
        VkSampleCountFlags    framebufferDepthSampleCounts;
        VkSampleCountFlags    framebufferStencilSampleCounts;
        VkSampleCountFlags    framebufferNoAttachmentsSampleCounts;
        uint32_t              maxColorAttachments;
        VkSampleCountFlags    sampledImageColorSampleCounts;
        VkSampleCountFlags    sampledImageIntegerSampleCounts;
        VkSampleCountFlags    sampledImageDepthSampleCounts;
        VkSampleCountFlags    sampledImageStencilSampleCounts;
        VkSampleCountFlags    storageImageSampleCounts;
        uint32_t              maxSampleMaskWords;
        VkBool32              timestampComputeAndGraphics;
        float                 timestampPeriod;
        uint32_t              maxClipDistances;
        uint32_t              maxCullDistances;
        uint32_t              maxCombinedClipAndCullDistances;
        uint32_t              discreteQueuePriorities;
        float                 pointSizeRange[2];
        float                 lineWidthRange[2];
        float                 pointSizeGranularity;
        float                 lineWidthGranularity;
        VkBool32              strictLines;
        VkBool32              standardSampleLocations;
        VkDeviceSize          optimalBufferCopyOffsetAlignment;
        VkDeviceSize          optimalBufferCopyRowPitchAlignment;
        VkDeviceSize          nonCoherentAtomSize;
	} VkPhysicalDeviceLimits;

	typedef struct {
    	VkBool32    residencyStandard2DBlockShape;
        VkBool32    residencyStandard2DMultisampleBlockShape;
        VkBool32    residencyStandard3DBlockShape;
        VkBool32    residencyAlignedMipSize;
        VkBool32    residencyNonResidentStrict;
    } VkPhysicalDeviceSparseProperties;

	typedef struct {
		uint32_t                            apiVersion;
		uint32_t                            driverVersion;
		uint32_t                            vendorID;
		uint32_t                            deviceID;
		VkPhysicalDeviceType                deviceType;
		char                                deviceName[256];
		uint8_t                             pipelineCacheUUID[16];
		VkPhysicalDeviceLimits              limits;
		VkPhysicalDeviceSparseProperties    sparseProperties;
	} VkPhysicalDeviceProperties;

	typedef struct {
        VkStructureType    sType;
        const void*        pNext;
        VkFlags            flags;
        uint32_t           queueCreateInfoCount;
        const void*        pQueueCreateInfos;
        uint32_t           _enabledLayerCount;
        const char* const* _ppEnabledLayerNames;
        uint32_t           enabledExtensionCount;
        const char* const* ppEnabledExtensionNames;
        const VkPhysicalDeviceFeatures* pEnabledFeatures;
    } VkDeviceCreateInfo;

    typedef struct {
        VkStructureType        sType;
        const void*            pNext;
        VkBufferCreateFlags    flags;
        VkDeviceSize           size;
        VkBufferUsageFlags     usage;
        VkSharingMode          sharingMode;
        uint32_t               queueFamilyIndexCount;
        const uint32_t*        pQueueFamilyIndices;
    } VkBufferCreateInfo;

    typedef struct {
        VkStructureType              sType;
        const void*                  pNext;
        VkShaderModuleCreateFlags    flags;
        size_t                       codeSize;
        const uint32_t*              pCode;
    } VkShaderModuleCreateInfo;

	VkResult vkGetPhysicalDeviceProperties(
		VkPhysicalDevice physicalDevice,
		VkPhysicalDeviceProperties* pProperties
	);
]])

---@class vk.BaseStruct
---@field sType vk.StructureType?
---@field pNext userdata?
---@field flags number?

---@class vk.Instance: number
---@class vk.Result: number
---@class vk.PhysicalDevice: ffi.cdata*
---@class vk.Device: number
---@class vk.Buffer*: ffi.cdata*

---@class vk.InstanceCreateInfoStruct: vk.BaseStruct
---@field pApplicationInfo userdata?
---@field enabledLayerCount number?
---@field ppEnabledLayerNames userdata?
---@field enabledExtensionCount number?
---@field ppEnabledExtensionNames userdata?

---@class vk.DeviceCreateInfoStruct: vk.BaseStruct
---@field queueCreateInfoCount number?
---@field pQueueCreateInfos userdata?
---@field enabledExtensionCount number?
---@field ppEnabledExtensionNames userdata?
---@field pEnabledFeatures userdata?

---@class vk.BufferCreateInfoStruct: vk.BaseStruct
---@field size number
---@field usage vk.BufferUsage
---@field sharingMode vk.SharingMode?
---@field queueFamilyIndexCount number?
---@field pQueueFamilyIndices userdata?

---@class vk.ShaderModuleCreateInfoStruct: vk.BaseStruct
---@field codeSize number
---@field pCode userdata

---@class vk.PhysicalDeviceProperties: ffi.cdata*
---@field apiVersion number
---@field driverVersion number
---@field vendorID number
---@field deviceID number
---@field deviceType vk.PhysicalDeviceType
---@field deviceName ffi.cdata*
---@field pipelineCacheUUID ffi.cdata*
---@field limits ffi.cdata*
---@field sparseProperties ffi.cdata*

local vkGlobal = {
	---@enum vk.StructureType
	StructureType = {
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
	},
}

do
	local C = ffi.load("vulkan")

	---@param info vk.InstanceCreateInfoStruct
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
	---@param info vk.DeviceCreateInfoStruct?
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
		vkCreateShaderModule = "VkResult(*)(VkDevice, const void*, const VkAllocationCallbacks*, VkBuffer*)",
	}

	for name, funcType in pairs(types) do
		vkDevice[name] = ffi.cast(funcType, vkGlobal.getDeviceProcAddr(globalDevice, name))
	end
end

local vk = {}

-- Globals
do
	vk.StructureType = vkGlobal.StructureType

	---@enum vk.PhysicalDeviceType
	vk.PhysicalDeviceType = {
		OTHER = 0,
		INTEGRATED_GPU = 1,
		DISCRETE_GPU = 2,
		VIRTUAL_GPU = 3,
		CPU = 4,
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

	vk.getPhysicalDeviceProperties = vkGlobal.getPhysicalDeviceProperties
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
	---@param info vk.BufferCreateInfoStruct
	---@param allocator ffi.cdata*?
	---@return vk.Buffer*
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
	---@param info vk.ShaderModuleCreateInfoStruct
	---@param allocator ffi.cdata*?
	---@return vk.Buffer*
	function vk.createShaderModule(device, info, allocator)
		local info = ffi.new("VkShaderModuleCreateInfo", info)
		info.sType = vk.StructureType.SHADER_MODULE_CREATE_INFO

		local shaderModule = ffi.new("VkBuffer[1]")
		local result = vkDevice.vkCreateShaderModule(device, info, allocator, shaderModule)
		if result ~= 0 then
			error("Failed to create Vulkan shader module, error code: " .. tostring(result))
		end

		return shaderModule[0]
	end
end

return vk
