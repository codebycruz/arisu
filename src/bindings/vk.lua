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

	VkResult vkCreateDevice(
		VkPhysicalDevice physicalDevice,
		const VkDeviceCreateInfo* pCreateInfo,
		const void* pAllocator,
		VkDevice* pDevice
	);

	VkResult vkGetPhysicalDeviceProperties(
		VkPhysicalDevice physicalDevice,
		VkPhysicalDeviceProperties* pProperties
	);
]])

---@class vk.Instance: number
---@class vk.Result: number
---@class vk.PhysicalDevice: ffi.cdata*
---@class vk.Device: number

---@class vk.CreateInstanceInput
---@field pNext userdata?
---@field flags number?
---@field pApplicationInfo userdata?
---@field enabledLayerCount number?
---@field ppEnabledLayerNames userdata?
---@field enabledExtensionCount number?
---@field ppEnabledExtensionNames userdata?

---@class vk.DeviceCreateInfoStruct
---@field sType vk.StructureType
---@field pNext userdata?
---@field flags number
---@field queueCreateInfoCount number
---@field pQueueCreateInfos userdata?
---@field enabledExtensionCount number
---@field ppEnabledExtensionNames userdata?
---@field pEnabledFeatures userdata?

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

local core = {
	---@enum vk.StructureType
	StructureType = {
		APPLICATION_INFO = 0,
		INSTANCE_CREATE_INFO = 1,
		DEVICE_QUEUE_CREATE_INFO = 2,
		DEVICE_CREATE_INFO = 3,
	},

	---@enum vk.PhysicalDeviceType
	PhysicalDeviceType = {
		OTHER = 0,
		INTEGRATED_GPU = 1,
		DISCRETE_GPU = 2,
		VIRTUAL_GPU = 3,
		CPU = 4,
	},
}

do
	local C = ffi.load("vulkan")

	---@param info vk.CreateInstanceInput
	---@param allocator ffi.cdata*?
	---@return vk.Instance
	function core.createInstance(info, allocator)
		local instance = ffi.new("VkInstance[1]")
		local info = ffi.new("VkInstanceCreateInfo", info)
		info.sType = core.StructureType.INSTANCE_CREATE_INFO

		local result = C.vkCreateInstance(info, allocator, instance)
		if result ~= 0 then
			error("Failed to create Vulkan instance, error code: " .. tostring(result))
		end

		return instance[0]
	end

	---@param instance vk.Instance
	---@return vk.PhysicalDevice[]
	function core.enumeratePhysicalDevices(instance)
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
	---@param info vk.DeviceCreateInfoStruct
	---@param allocator ffi.cdata*?
	---@return vk.Device
	function core.createDevice(physicalDevice, info, allocator)
		local device = ffi.new("VkDevice[1]")
		local info = ffi.new("VkDeviceCreateInfo", info)

		local result = C.vkCreateDevice(physicalDevice, info, allocator, device)
		if result ~= 0 then
			error("Failed to create Vulkan device, error code: " .. tostring(result))
		end

		return device[0]
	end

	---@param physicalDevice vk.PhysicalDevice
	function core.getPhysicalDeviceProperties(physicalDevice)
		local properties = ffi.new("VkPhysicalDeviceProperties")
		C.vkGetPhysicalDeviceProperties(physicalDevice, properties)
		return properties --[[@as vk.PhysicalDeviceProperties]]
	end

	core.getInstanceProcAddr = C.vkGetInstanceProcAddr
	core.getDeviceProcAddr = C.vkGetDeviceProcAddr
end

local globalInstance ---@type vk.Instance
do
	local pCreateInfo = ffi.new("VkInstanceCreateInfo", {
		sType = 1, -- VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO
		pNext = nil,
		flags = 0,
		pApplicationInfo = nil,
		enabledLayerCount = 0,
		ppEnabledLayerNames = nil,
		enabledExtensionCount = 0,
		ppEnabledExtensionNames = nil,
	})

	globalInstance = core.createInstance(pCreateInfo, nil)
end

local functionTypes = {}

local C = {}
for name, funcType in pairs(functionTypes) do
	C[name] = ffi.cast(funcType, core.getInstanceProcAddr(globalInstance, name))
end


return {
	StructureType = core.StructureType,
	PhysicalDeviceType = core.PhysicalDeviceType,

	createInstance = core.createInstance,
	enumeratePhysicalDevices = core.enumeratePhysicalDevices,
	createDevice = core.createDevice,
	getInstanceProcAddr = core.getInstanceProcAddr,
	getDeviceProcAddr = core.getDeviceProcAddr,
	getPhysicalDeviceProperties = core.getPhysicalDeviceProperties,
}
