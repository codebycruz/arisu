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
	typedef uint64_t VkShaderModule;
	typedef uint64_t VkPipelineLayout;
	typedef uint64_t VkPipeline;
	typedef uint64_t VkRenderPass;
	typedef uint64_t VkFramebuffer;
	typedef uint64_t VkCommandPool;
	typedef uint64_t VkCommandBuffer;
	typedef uint64_t VkQueue;
	typedef uint64_t VkSemaphore;
	typedef uint64_t VkFence;
	typedef uint64_t VkImage;
	typedef uint64_t VkDeviceMemory;
	typedef uint64_t VkSampler;
	typedef uint64_t VkImageView;
	typedef uint64_t VkDescriptorSetLayout;
	typedef uint64_t VkDescriptorPool;
	typedef uint64_t VkDescriptorSet;
	typedef VkFlags VkMemoryPropertyFlags;
	typedef VkFlags VkMemoryHeapFlags;
	typedef VkFlags VkDescriptorSetLayoutCreateFlags;
	typedef VkFlags VkDescriptorPoolCreateFlags;
	typedef int32_t VkDescriptorType;
	typedef VkFlags VkShaderStageFlags;
	typedef int32_t VkFormat;
	typedef int32_t VkColorSpaceKHR;
	typedef int32_t VkPresentModeKHR;
	typedef int32_t VkSurfaceTransformFlagBitsKHR;
	typedef int32_t VkCompositeAlphaFlagBitsKHR;
	typedef VkFlags VkImageUsageFlags;
	typedef VkFlags VkSwapchainCreateFlagsKHR;
	typedef VkFlags VkSurfaceTransformFlagsKHR;
	typedef VkFlags VkCompositeAlphaFlagsKHR;
	typedef VkFlags VkPipelineLayoutCreateFlags;
	typedef VkFlags VkPipelineCreateFlags;
	typedef VkFlags VkRenderPassCreateFlags;
	typedef VkFlags VkFramebufferCreateFlags;
	typedef VkFlags VkCommandPoolCreateFlags;
	typedef VkFlags VkCommandBufferUsageFlags;
	typedef int32_t VkPipelineBindPoint;
	typedef int32_t VkSubpassContents;
	typedef int32_t VkCommandBufferLevel;
	typedef VkFlags VkImageCreateFlags;
	typedef int32_t VkImageType;
	typedef int32_t VkImageTiling;
	typedef int32_t VkImageLayout;

	typedef uint64_t VkSwapchainKHR;
	typedef uint64_t VkSurfaceKHR;

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
		const VkAllocationCallbacks* pAllocator,
		VkInstance* pInstance
	);

	VkResult vkEnumeratePhysicalDevices(
		VkInstance instance,
		uint32_t* pPhysicalDeviceCount,
		VkPhysicalDevice* pPhysicalDevices
	);

	typedef struct {
		VkBool32	robustBufferAccess;
		VkBool32	fullDrawIndexUint32;
		VkBool32	imageCubeArray;
		VkBool32	independentBlend;
		VkBool32	geometryShader;
		VkBool32	tessellationShader;
		VkBool32	sampleRateShading;
		VkBool32	dualSrcBlend;
		VkBool32	logicOp;
		VkBool32	multiDrawIndirect;
		VkBool32	drawIndirectFirstInstance;
		VkBool32	depthClamp;
		VkBool32	depthBiasClamp;
		VkBool32	fillModeNonSolid;
		VkBool32	depthBounds;
		VkBool32	wideLines;
		VkBool32	largePoints;
		VkBool32	alphaToOne;
		VkBool32	multiViewport;
		VkBool32	samplerAnisotropy;
		VkBool32	textureCompressionETC2;
		VkBool32	textureCompressionASTC_LDR;
		VkBool32	textureCompressionBC;
		VkBool32	occlusionQueryPrecise;
		VkBool32	pipelineStatisticsQuery;
		VkBool32	vertexPipelineStoresAndAtomics;
		VkBool32	fragmentStoresAndAtomics;
		VkBool32	shaderTessellationAndGeometryPointSize;
		VkBool32	shaderImageGatherExtended;
		VkBool32	shaderStorageImageExtendedFormats;
		VkBool32	shaderStorageImageMultisample;
		VkBool32	shaderStorageImageReadWithoutFormat;
		VkBool32	shaderStorageImageWriteWithoutFormat;
		VkBool32	shaderUniformBufferArrayDynamicIndexing;
		VkBool32	shaderSampledImageArrayDynamicIndexing;
		VkBool32	shaderStorageBufferArrayDynamicIndexing;
		VkBool32	shaderStorageImageArrayDynamicIndexing;
		VkBool32	shaderClipDistance;
		VkBool32	shaderCullDistance;
		VkBool32	shaderFloat64;
		VkBool32	shaderInt64;
		VkBool32	shaderInt16;
		VkBool32	shaderResourceResidency;
		VkBool32	shaderResourceMinLod;
		VkBool32	sparseBinding;
		VkBool32	sparseResidencyBuffer;
		VkBool32	sparseResidencyImage2D;
		VkBool32	sparseResidencyImage3D;
		VkBool32	sparseResidency2Samples;
		VkBool32	sparseResidency4Samples;
		VkBool32	sparseResidency8Samples;
		VkBool32	sparseResidency16Samples;
		VkBool32	sparseResidencyAliased;
		VkBool32	variableMultisampleRate;
		VkBool32	inheritedQueries;
	} VkPhysicalDeviceFeatures;

	typedef struct {
		uint32_t			maxImageDimension1D;
		uint32_t			maxImageDimension2D;
		uint32_t			maxImageDimension3D;
		uint32_t			maxImageDimensionCube;
		uint32_t			maxImageArrayLayers;
		uint32_t			maxTexelBufferElements;
		uint32_t			maxUniformBufferRange;
		uint32_t			maxStorageBufferRange;
		uint32_t			maxPushConstantsSize;
		uint32_t			maxMemoryAllocationCount;
		uint32_t			maxSamplerAllocationCount;
		VkDeviceSize		bufferImageGranularity;
		VkDeviceSize		sparseAddressSpaceSize;
		uint32_t			maxBoundDescriptorSets;
		uint32_t			maxPerStageDescriptorSamplers;
		uint32_t			maxPerStageDescriptorUniformBuffers;
		uint32_t			maxPerStageDescriptorStorageBuffers;
		uint32_t			maxPerStageDescriptorSampledImages;
		uint32_t			maxPerStageDescriptorStorageImages;
		uint32_t			maxPerStageDescriptorInputAttachments;
		uint32_t			maxPerStageResources;
		uint32_t			maxDescriptorSetSamplers;
		uint32_t			maxDescriptorSetUniformBuffers;
		uint32_t			maxDescriptorSetUniformBuffersDynamic;
		uint32_t			maxDescriptorSetStorageBuffers;
		uint32_t			maxDescriptorSetStorageBuffersDynamic;
		uint32_t			maxDescriptorSetSampledImages;
		uint32_t			maxDescriptorSetStorageImages;
		uint32_t			maxDescriptorSetInputAttachments;
		uint32_t			maxVertexInputAttributes;
		uint32_t			maxVertexInputBindings;
		uint32_t			maxVertexInputAttributeOffset;
		uint32_t			maxVertexInputBindingStride;
		uint32_t			maxVertexOutputComponents;
		uint32_t			maxTessellationGenerationLevel;
		uint32_t			maxTessellationPatchSize;
		uint32_t			maxTessellationControlPerVertexInputComponents;
		uint32_t			maxTessellationControlPerVertexOutputComponents;
		uint32_t			maxTessellationControlPerPatchOutputComponents;
		uint32_t			maxTessellationControlTotalOutputComponents;
		uint32_t			maxTessellationEvaluationInputComponents;
		uint32_t			maxTessellationEvaluationOutputComponents;
		uint32_t			maxGeometryShaderInvocations;
		uint32_t			maxGeometryInputComponents;
		uint32_t			maxGeometryOutputComponents;
		uint32_t			maxGeometryOutputVertices;
		uint32_t			maxGeometryTotalOutputComponents;
		uint32_t			maxFragmentInputComponents;
		uint32_t			maxFragmentOutputAttachments;
		uint32_t			maxFragmentDualSrcAttachments;
		uint32_t			maxFragmentCombinedOutputResources;
		uint32_t			maxComputeSharedMemorySize;
		uint32_t			maxComputeWorkGroupCount[3];
		uint32_t			maxComputeWorkGroupInvocations;
		uint32_t			maxComputeWorkGroupSize[3];
		uint32_t			subPixelPrecisionBits;
		uint32_t			subTexelPrecisionBits;
		uint32_t			mipmapPrecisionBits;
		uint32_t			maxDrawIndexedIndexValue;
		uint32_t			maxDrawIndirectCount;
		float				maxSamplerLodBias;
		float				maxSamplerAnisotropy;
		uint32_t			maxViewports;
		uint32_t			maxViewportDimensions[2];
		float				viewportBoundsRange[2];
		uint32_t			viewportSubPixelBits;
		size_t				minMemoryMapAlignment;
		VkDeviceSize		minTexelBufferOffsetAlignment;
		VkDeviceSize		minUniformBufferOffsetAlignment;
		VkDeviceSize		minStorageBufferOffsetAlignment;
		int32_t				minTexelOffset;
		uint32_t			maxTexelOffset;
		int32_t				minTexelGatherOffset;
		uint32_t			maxTexelGatherOffset;
		float				minInterpolationOffset;
		float				maxInterpolationOffset;
		uint32_t			subPixelInterpolationOffsetBits;
		uint32_t			maxFramebufferWidth;
		uint32_t			maxFramebufferHeight;
		uint32_t			maxFramebufferLayers;
		VkSampleCountFlags	framebufferColorSampleCounts;
		VkSampleCountFlags	framebufferDepthSampleCounts;
		VkSampleCountFlags	framebufferStencilSampleCounts;
		VkSampleCountFlags	framebufferNoAttachmentsSampleCounts;
		uint32_t			maxColorAttachments;
		VkSampleCountFlags	sampledImageColorSampleCounts;
		VkSampleCountFlags	sampledImageIntegerSampleCounts;
		VkSampleCountFlags	sampledImageDepthSampleCounts;
		VkSampleCountFlags	sampledImageStencilSampleCounts;
		VkSampleCountFlags	storageImageSampleCounts;
		uint32_t			maxSampleMaskWords;
		VkBool32			timestampComputeAndGraphics;
		float				timestampPeriod;
		uint32_t			maxClipDistances;
		uint32_t			maxCullDistances;
		uint32_t			maxCombinedClipAndCullDistances;
		uint32_t			discreteQueuePriorities;
		float				pointSizeRange[2];
		float				lineWidthRange[2];
		float				pointSizeGranularity;
		float				lineWidthGranularity;
		VkBool32			strictLines;
		VkBool32			standardSampleLocations;
		VkDeviceSize		optimalBufferCopyOffsetAlignment;
		VkDeviceSize		optimalBufferCopyRowPitchAlignment;
		VkDeviceSize		nonCoherentAtomSize;
	} VkPhysicalDeviceLimits;

	typedef struct {
		VkBool32	residencyStandard2DBlockShape;
		VkBool32	residencyStandard2DMultisampleBlockShape;
		VkBool32	residencyStandard3DBlockShape;
		VkBool32	residencyAlignedMipSize;
		VkBool32	residencyNonResidentStrict;
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
		VkPhysicalDeviceSparseProperties sparseProperties;
	} VkPhysicalDeviceProperties;

	typedef struct {
		VkDeviceSize    size;
		uint32_t        alignment;
		uint32_t        memoryTypeBits;
	} VkMemoryRequirements;

	typedef struct {
		VkMemoryPropertyFlags    propertyFlags;
		uint32_t                 heapIndex;
	} VkMemoryType;

	typedef struct {
		VkDeviceSize         size;
		VkMemoryHeapFlags    flags;
	} VkMemoryHeap;

	typedef struct {
		uint32_t        memoryTypeCount;
		VkMemoryType    memoryTypes[32];
		uint32_t        memoryHeapCount;
		VkMemoryHeap    memoryHeaps[16];
	} VkPhysicalDeviceMemoryProperties;

	typedef struct {
		VkStructureType    sType;
		const void*        pNext;
		uint32_t           allocationSize;
		uint32_t           memoryTypeIndex;
	} VkMemoryAllocateInfo;

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
		VkStructureType             sType;
		const void*                 pNext;
		VkBufferCreateFlags         flags;
		VkDeviceSize                size;
		VkBufferUsageFlags          usage;
		VkSharingMode               sharingMode;
		uint32_t                    queueFamilyIndexCount;
		const uint32_t*             pQueueFamilyIndices;
	} VkBufferCreateInfo;

	typedef struct {
		VkStructureType          sType;
		const void*              pNext;
		VkImageCreateFlags       flags;
		VkImageType              imageType;
		VkFormat                 format;
		VkExtent3D               extent;
		uint32_t                 mipLevels;
		uint32_t                 arrayLayers;
		VkSampleCountFlags       samples;
		VkImageTiling            tiling;
		VkImageUsageFlags        usage;
		VkSharingMode            sharingMode;
		uint32_t                 queueFamilyIndexCount;
		const uint32_t*          pQueueFamilyIndices;
		VkImageLayout            initialLayout;
	} VkImageCreateInfo;

	typedef struct {
		uint32_t    width;
		uint32_t    height;
		uint32_t    depth;
	} VkExtent3D;

	typedef struct {
		VkImageAspectFlags    aspectMask;
		uint32_t              mipLevel;
		uint32_t              baseArrayLayer;
		uint32_t              layerCount;
	} VkImageSubresourceLayers;

	typedef struct {
		VkDeviceSize                bufferOffset;
		uint32_t                    bufferRowLength;
		uint32_t                    bufferImageHeight;
		VkImageSubresourceLayers    imageSubresource;
		VkOffset3D                  imageOffset;
		VkExtent3D                  imageExtent;
	} VkBufferImageCopy;

	typedef struct {
		int32_t    x;
		int32_t    y;
		int32_t    z;
	} VkOffset3D;

	typedef VkFlags VkImageAspectFlags;

	typedef struct {
		VkStructureType              sType;
		const void*                  pNext;
		VkShaderModuleCreateFlags    flags;
		size_t                       codeSize;
		const uint32_t*              pCode;
	} VkShaderModuleCreateInfo;

	typedef struct {
		VkStructureType                 sType;
		const void*                     pNext;
		VkPipelineLayoutCreateFlags     flags;
		uint32_t                        setLayoutCount;
		const void*                     pSetLayouts;
		uint32_t                        pushConstantRangeCount;
		const void*                     pPushConstantRanges;
	} VkPipelineLayoutCreateInfo;

	typedef struct {
		VkStructureType              sType;
		const void*                  pNext;
		VkPipelineCreateFlags        flags;
		uint32_t                     stageCount;
		const void*                  pStages;
		const void*                  pVertexInputState;
		const void*                  pInputAssemblyState;
		const void*                  pTessellationState;
		const void*                  pViewportState;
		const void*                  pRasterizationState;
		const void*                  pMultisampleState;
		const void*                  pDepthStencilState;
		const void*                  pColorBlendState;
		const void*                  pDynamicState;
		VkPipelineLayout             layout;
		VkRenderPass                 renderPass;
		uint32_t                     subpass;
		VkPipeline                   basePipelineHandle;
		int32_t                      basePipelineIndex;
	} VkGraphicsPipelineCreateInfo;

	typedef struct {
		VkStructureType             sType;
		const void*                 pNext;
		VkRenderPassCreateFlags     flags;
		uint32_t                    attachmentCount;
		const void*                 pAttachments;
		uint32_t                    subpassCount;
		const void*                 pSubpasses;
		uint32_t                    dependencyCount;
		const void*                 pDependencies;
	} VkRenderPassCreateInfo;

	typedef struct {
		VkStructureType             sType;
		const void*                 pNext;
		VkFramebufferCreateFlags    flags;
		VkRenderPass                renderPass;
		uint32_t                    attachmentCount;
		const void*                 pAttachments;
		uint32_t                    width;
		uint32_t                    height;
		uint32_t                    layers;
	} VkFramebufferCreateInfo;

	typedef struct {
		VkStructureType             sType;
		const void*                 pNext;
		VkCommandPoolCreateFlags    flags;
		uint32_t                    queueFamilyIndex;
	} VkCommandPoolCreateInfo;

	typedef struct {
		VkStructureType         sType;
		const void*             pNext;
		VkCommandPool           commandPool;
		VkCommandBufferLevel    level;
		uint32_t                commandBufferCount;
	} VkCommandBufferAllocateInfo;

	typedef struct {
		VkStructureType                 sType;
		const void*                     pNext;
		VkCommandBufferUsageFlags       flags;
		const void*                     pInheritanceInfo;
	} VkCommandBufferBeginInfo;

	typedef struct {
		VkStructureType    sType;
		const void*        pNext;
		VkFlags            flags;
	} VkSemaphoreCreateInfo;

	typedef struct {
		VkStructureType    sType;
		const void*        pNext;
		VkFlags            flags;
	} VkFenceCreateInfo;

	typedef struct {
		uint32_t              binding;
		VkDescriptorType      descriptorType;
		uint32_t              descriptorCount;
		VkShaderStageFlags    stageFlags;
		const void*           pImmutableSamplers;
	} VkDescriptorSetLayoutBinding;

	typedef struct {
		VkStructureType                      sType;
		const void*                          pNext;
		VkDescriptorSetLayoutCreateFlags    flags;
		uint32_t                             bindingCount;
		const VkDescriptorSetLayoutBinding*  pBindings;
	} VkDescriptorSetLayoutCreateInfo;

	typedef struct {
		VkDescriptorType    type;
		uint32_t            descriptorCount;
	} VkDescriptorPoolSize;

	typedef struct {
		VkStructureType              sType;
		const void*                  pNext;
		VkDescriptorPoolCreateFlags  flags;
		uint32_t                     maxSets;
		uint32_t                     poolSizeCount;
		const VkDescriptorPoolSize*  pPoolSizes;
	} VkDescriptorPoolCreateInfo;

	typedef struct {
		VkStructureType                  sType;
		const void*                      pNext;
		VkDescriptorPool                 descriptorPool;
		uint32_t                         descriptorSetCount;
		const VkDescriptorSetLayout*     pSetLayouts;
	} VkDescriptorSetAllocateInfo;

	typedef struct {
		VkBuffer        buffer;
		VkDeviceSize    offset;
		VkDeviceSize    range;
	} VkDescriptorBufferInfo;

	typedef struct {
		VkSampler      sampler;
		VkImageView    imageView;
		VkImageLayout  imageLayout;
	} VkDescriptorImageInfo;

	typedef struct {
		VkStructureType                  sType;
		const void*                      pNext;
		VkDescriptorSet                  dstSet;
		uint32_t                         dstBinding;
		uint32_t                         dstArrayElement;
		uint32_t                         descriptorCount;
		VkDescriptorType                 descriptorType;
		const VkDescriptorImageInfo*     pImageInfo;
		const VkDescriptorBufferInfo*    pBufferInfo;
		const void*                      pTexelBufferView;
	} VkWriteDescriptorSet;

	typedef struct {
		uint32_t                         minImageCount;
		uint32_t                         maxImageCount;
		VkExtent2D                       currentExtent;
		VkExtent2D                       minImageExtent;
		VkExtent2D                       maxImageExtent;
		uint32_t                         maxImageArrayLayers;
		VkSurfaceTransformFlagsKHR       supportedTransforms;
		VkSurfaceTransformFlagBitsKHR    currentTransform;
		VkCompositeAlphaFlagsKHR         supportedCompositeAlpha;
		VkImageUsageFlags                supportedUsageFlags;
	} VkSurfaceCapabilitiesKHR;

	typedef struct {
		VkFormat           format;
		VkColorSpaceKHR    colorSpace;
	} VkSurfaceFormatKHR;

	typedef struct {
		VkStructureType                  sType;
		const void*                      pNext;
		VkSwapchainCreateFlagsKHR        flags;
		VkSurfaceKHR                     surface;
		uint32_t                         minImageCount;
		VkFormat                         imageFormat;
		VkColorSpaceKHR                  imageColorSpace;
		VkExtent2D                       imageExtent;
		uint32_t                         imageArrayLayers;
		VkImageUsageFlags                imageUsage;
		VkSharingMode                    imageSharingMode;
		uint32_t                         queueFamilyIndexCount;
		const uint32_t*                  pQueueFamilyIndices;
		VkSurfaceTransformFlagBitsKHR    preTransform;
		VkCompositeAlphaFlagBitsKHR      compositeAlpha;
		VkPresentModeKHR                 presentMode;
		VkBool32                         clipped;
		VkSwapchainKHR                   oldSwapchain;
	} VkSwapchainCreateInfoKHR;

	typedef struct {
		int32_t    x;
		int32_t    y;
	} VkOffset2D;

	typedef struct {
		uint32_t    width;
		uint32_t    height;
	} VkExtent2D;

	typedef struct {
		VkOffset2D    offset;
		VkExtent2D    extent;
	} VkRect2D;

	typedef struct {
		VkStructureType     sType;
		const void*         pNext;
		VkRenderPass        renderPass;
		VkFramebuffer       framebuffer;
		VkRect2D            renderArea;
		uint32_t            clearValueCount;
		const void*         pClearValues;
	} VkRenderPassBeginInfo;

	typedef struct {
		VkStructureType         sType;
		const void*             pNext;
		uint32_t                waitSemaphoreCount;
		const VkSemaphore*      pWaitSemaphores;
		const void*             pWaitDstStageMask;
		uint32_t                commandBufferCount;
		const VkCommandBuffer*  pCommandBuffers;
		uint32_t                signalSemaphoreCount;
		const VkSemaphore*      pSignalSemaphores;
	} VkSubmitInfo;

	typedef struct {
		VkStructureType          sType;
		const void*              pNext;
		uint32_t                 waitSemaphoreCount;
		const VkSemaphore*       pWaitSemaphores;
		uint32_t                 swapchainCount;
		const VkSwapchainKHR*    pSwapchains;
		const uint32_t*          pImageIndices;
		VkResult*                pResults;
	} VkPresentInfoKHR;

	VkResult vkGetPhysicalDeviceProperties(
		VkPhysicalDevice physicalDevice,
		VkPhysicalDeviceProperties* pProperties
	);

	void vkGetPhysicalDeviceMemoryProperties(
		VkPhysicalDevice physicalDevice,
		VkPhysicalDeviceMemoryProperties* pMemoryProperties
	);

	VkResult vkGetPhysicalDeviceSurfaceCapabilitiesKHR(
		VkPhysicalDevice physicalDevice,
		VkSurfaceKHR surface,
		VkSurfaceCapabilitiesKHR* pSurfaceCapabilities
	);

	VkResult vkGetPhysicalDeviceSurfaceFormatsKHR(
		VkPhysicalDevice physicalDevice,
		VkSurfaceKHR surface,
		uint32_t* pSurfaceFormatCount,
		VkSurfaceFormatKHR* pSurfaceFormats
	);

	VkResult vkGetPhysicalDeviceSurfacePresentModesKHR(
		VkPhysicalDevice physicalDevice,
		VkSurfaceKHR surface,
		uint32_t* pPresentModeCount,
		VkPresentModeKHR* pPresentModes
	);

	VkResult vkCreatePipelineLayout(
		VkDevice device,
		const VkPipelineLayoutCreateInfo* pCreateInfo,
		const VkAllocationCallbacks* pAllocator,
		VkPipelineLayout* pPipelineLayout
	);

	VkResult vkCreateGraphicsPipelines(
		VkDevice device,
		uint64_t pipelineCache,
		uint32_t createInfoCount,
		const VkGraphicsPipelineCreateInfo* pCreateInfos,
		const VkAllocationCallbacks* pAllocator,
		VkPipeline* pPipelines
	);

	VkResult vkCreateRenderPass(
		VkDevice device,
		const VkRenderPassCreateInfo* pCreateInfo,
		const VkAllocationCallbacks* pAllocator,
		VkRenderPass* pRenderPass
	);

	VkResult vkCreateFramebuffer(
		VkDevice device,
		const VkFramebufferCreateInfo* pCreateInfo,
		const VkAllocationCallbacks* pAllocator,
		VkFramebuffer* pFramebuffer
	);

	void vkGetBufferMemoryRequirements(
		VkDevice device,
		VkBuffer buffer,
		VkMemoryRequirements* pMemoryRequirements
	);

	void vkGetImageMemoryRequirements(
		VkDevice device,
		VkImage image,
		VkMemoryRequirements* pMemoryRequirements
	);

	VkResult vkCreateImage(
		VkDevice device,
		const VkImageCreateInfo* pCreateInfo,
		const VkAllocationCallbacks* pAllocator,
		VkImage* pImage
	);

	VkResult vkBindImageMemory(
		VkDevice device,
		VkImage image,
		VkDeviceMemory memory,
		VkDeviceSize memoryOffset
	);

	void vkCmdCopyBufferToImage(
		VkCommandBuffer commandBuffer,
		VkBuffer srcBuffer,
		VkImage dstImage,
		VkImageLayout dstImageLayout,
		uint32_t regionCount,
		const VkBufferImageCopy* pRegions
	);

	VkResult vkAllocateMemory(
		VkDevice device,
		const VkMemoryAllocateInfo* pAllocateInfo,
		const VkAllocationCallbacks* pAllocator,
		VkDeviceMemory* pMemory
	);

	VkResult vkBindBufferMemory(
		VkDevice device,
		VkBuffer buffer,
		VkDeviceMemory memory,
		VkDeviceSize memoryOffset
	);

	VkResult vkMapMemory(
		VkDevice device,
		VkDeviceMemory memory,
		VkDeviceSize offset,
		VkDeviceSize size,
		VkFlags flags,
		void** ppData
	);

	void vkUnmapMemory(
		VkDevice device,
		VkDeviceMemory memory
	);

	VkResult vkCreateCommandPool(
		VkDevice device,
		const VkCommandPoolCreateInfo* pCreateInfo,
		const VkAllocationCallbacks* pAllocator,
		VkCommandPool* pCommandPool
	);

	VkResult vkCreateDescriptorSetLayout(
		VkDevice device,
		const VkDescriptorSetLayoutCreateInfo* pCreateInfo,
		const VkAllocationCallbacks* pAllocator,
		VkDescriptorSetLayout* pSetLayout
	);

	VkResult vkCreateDescriptorPool(
		VkDevice device,
		const VkDescriptorPoolCreateInfo* pCreateInfo,
		const VkAllocationCallbacks* pAllocator,
		VkDescriptorPool* pDescriptorPool
	);

	VkResult vkAllocateDescriptorSets(
		VkDevice device,
		const VkDescriptorSetAllocateInfo* pAllocateInfo,
		VkDescriptorSet* pDescriptorSets
	);

	void vkUpdateDescriptorSets(
		VkDevice device,
		uint32_t descriptorWriteCount,
		const VkWriteDescriptorSet* pDescriptorWrites,
		uint32_t descriptorCopyCount,
		const void* pDescriptorCopies
	);

	VkResult vkAllocateCommandBuffers(
		VkDevice device,
		const VkCommandBufferAllocateInfo* pAllocateInfo,
		VkCommandBuffer* pCommandBuffers
	);

	VkResult vkBeginCommandBuffer(
		VkCommandBuffer commandBuffer,
		const VkCommandBufferBeginInfo* pBeginInfo
	);

	VkResult vkEndCommandBuffer(
		VkCommandBuffer commandBuffer
	);

	void vkCmdBeginRenderPass(
		VkCommandBuffer commandBuffer,
		const VkRenderPassBeginInfo* pRenderPassBegin,
		VkSubpassContents contents
	);

	void vkCmdEndRenderPass(
		VkCommandBuffer commandBuffer
	);

	void vkCmdBindPipeline(
		VkCommandBuffer commandBuffer,
		VkPipelineBindPoint pipelineBindPoint,
		VkPipeline pipeline
	);

	void vkCmdDraw(
		VkCommandBuffer commandBuffer,
		uint32_t vertexCount,
		uint32_t instanceCount,
		uint32_t firstVertex,
		uint32_t firstInstance
	);

	VkResult vkQueueSubmit(
		VkQueue queue,
		uint32_t submitCount,
		const VkSubmitInfo* pSubmits,
		uint64_t fence
	);

	VkResult vkQueueWaitIdle(
		VkQueue queue
	);

	void vkGetDeviceQueue(
		VkDevice device,
		uint32_t queueFamilyIndex,
		uint32_t queueIndex,
		VkQueue* pQueue
	);

	VkResult vkCreateSemaphore(
		VkDevice device,
		const VkSemaphoreCreateInfo* pCreateInfo,
		const VkAllocationCallbacks* pAllocator,
		VkSemaphore* pSemaphore
	);

	VkResult vkCreateFence(
		VkDevice device,
		const VkFenceCreateInfo* pCreateInfo,
		const VkAllocationCallbacks* pAllocator,
		VkFence* pFence
	);

	VkResult vkCreateSwapchainKHR(
		VkDevice device,
		const VkSwapchainCreateInfoKHR* pCreateInfo,
		const VkAllocationCallbacks* pAllocator,
		VkSwapchainKHR* pSwapchain
	);

	VkResult vkGetSwapchainImagesKHR(
		VkDevice device,
		VkSwapchainKHR swapchain,
		uint32_t* pSwapchainImageCount,
		VkImage* pSwapchainImages
	);

	VkResult vkAcquireNextImageKHR(
		VkDevice device,
		VkSwapchainKHR swapchain,
		uint64_t timeout,
		VkSemaphore semaphore,
		VkFence fence,
		uint32_t* pImageIndex
	);

	VkResult vkQueuePresentKHR(
		VkQueue queue,
		const VkPresentInfoKHR* pPresentInfo
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
---@class vk.DeviceSize: number
---@class vk.Buffer: number
---@class vk.PipelineLayout: number
---@class vk.Pipeline: number
---@class vk.RenderPass: number
---@class vk.Framebuffer: number
---@class vk.ShaderModule: number
---@class vk.CommandPool: number
---@class vk.CommandBuffer: number
---@class vk.DescriptorSetLayout: number
---@class vk.DescriptorPool: number
---@class vk.DescriptorSet: number
---@class vk.Queue: number
---@class vk.Semaphore: number
---@class vk.Fence: number
---@class vk.Image: number
---@class vk.DeviceMemory: number
---@class vk.Sampler: number
---@class vk.ImageView: number
---@class vk.SwapchainKHR: number
---@class vk.SurfaceKHR: number

---@class vk.MemoryRequirements: ffi.cdata*
---@field size vk.DeviceSize
---@field alignment vk.DeviceSize
---@field memoryTypeBits number

---@class vk.CreateImageInfoStruct: vk.BaseStruct
---@field imageType vk.ImageType
---@field format vk.Format
---@field extent vk.Extent3D
---@field mipLevels number
---@field arrayLayers number
---@field samples vk.SamplecountFlags
---@field tiling vk.ImageTiling
---@field usage vk.ImageUsageFlags
---@field sharingMode vk.SharingMode
---@field queueFamilyIndexCount number?
---@field pQueueFamilyIndices ffi.cdata*?
---@field initialLayout vk.ImageLayout

---@class vk.MemoryType: ffi.cdata*
---@field propertyFlags number
---@field heapIndex number

---@class vk.MemoryHeap: ffi.cdata*
---@field size number
---@field flags number

---@class vk.Extent2D: ffi.cdata*
---@field width number
---@field height number

---@class vk.Extent3D: ffi.cdata*
---@field width number
---@field height number
---@field depth number

---@class vk.PhysicalDeviceMemoryProperties: ffi.cdata*
---@field memoryTypeCount number
---@field memoryTypes ffi.cdata*
---@field memoryHeapCount number
---@field memoryHeaps ffi.cdata*

---@class vk.MemoryAllocateInfoStruct: vk.BaseStruct
---@field allocationSize number
---@field memoryTypeIndex number

---@class vk.SurfaceCapabilitiesKHR: ffi.cdata*
---@field minImageCount number
---@field maxImageCount number
---@field currentExtent table
---@field minImageExtent table
---@field maxImageExtent table
---@field maxImageArrayLayers number
---@field supportedTransforms number
---@field currentTransform number
---@field supportedCompositeAlpha number
---@field supportedUsageFlags number

---@class vk.SurfaceFormatKHR: ffi.cdata*
---@field format number
---@field colorSpace number

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

---@class vk.PipelineLayoutCreateInfoStruct: vk.BaseStruct
---@field setLayoutCount number?
---@field pSetLayouts userdata?
---@field pushConstantRangeCount number?
---@field pPushConstantRanges userdata?

---@class vk.GraphicsPipelineCreateInfoStruct: vk.BaseStruct
---@field stageCount number
---@field pStages userdata
---@field pVertexInputState userdata?
---@field pInputAssemblyState userdata?
---@field pTessellationState userdata?
---@field pViewportState userdata?
---@field pRasterizationState userdata?
---@field pMultisampleState userdata?
---@field pDepthStencilState userdata?
---@field pColorBlendState userdata?
---@field pDynamicState userdata?
---@field layout vk.PipelineLayout
---@field renderPass vk.RenderPass
---@field subpass number?

---@class vk.RenderPassCreateInfoStruct: vk.BaseStruct
---@field attachmentCount number?
---@field pAttachments userdata?
---@field subpassCount number
---@field pSubpasses userdata
---@field dependencyCount number?
---@field pDependencies userdata?

---@class vk.FramebufferCreateInfoStruct: vk.BaseStruct
---@field renderPass vk.RenderPass
---@field attachmentCount number?
---@field pAttachments userdata?
---@field width number
---@field height number
---@field layers number

---@class vk.CommandPoolCreateInfoStruct: vk.BaseStruct
---@field flags number?
---@field queueFamilyIndex number

---@class vk.CommandBufferAllocateInfoStruct: vk.BaseStruct
---@field commandPool vk.CommandPool
---@field level number
---@field commandBufferCount number

---@class vk.DescriptorSetLayoutBinding: ffi.cdata*
---@field binding number
---@field descriptorType number
---@field descriptorCount number
---@field stageFlags number
---@field pImmutableSamplers ffi.cdata*?

---@class vk.DescriptorSetLayoutCreateInfoStruct: vk.BaseStruct
---@field bindingCount number?
---@field pBindings ffi.cdata*?

---@class vk.DescriptorPoolSize: ffi.cdata*
---@field type number
---@field descriptorCount number

---@class vk.DescriptorPoolCreateInfoStruct: vk.BaseStruct
---@field maxSets number
---@field poolSizeCount number?
---@field pPoolSizes ffi.cdata*?

---@class vk.DescriptorSetAllocateInfoStruct: vk.BaseStruct
---@field descriptorPool vk.DescriptorPool
---@field descriptorSetCount number
---@field pSetLayouts ffi.cdata*

---@class vk.DescriptorBufferInfo: ffi.cdata*
---@field buffer vk.Buffer
---@field offset number
---@field range number

---@class vk.DescriptorImageInfo: ffi.cdata*
---@field sampler number
---@field imageView number
---@field imageLayout number

---@class vk.WriteDescriptorSetStruct: vk.BaseStruct
---@field dstSet vk.DescriptorSet
---@field dstBinding number
---@field dstArrayElement number
---@field descriptorCount number
---@field descriptorType number
---@field pImageInfo ffi.cdata*?
---@field pBufferInfo ffi.cdata*?
---@field pTexelBufferView ffi.cdata*?

---@class vk.SwapchainCreateInfoKHRStruct: vk.BaseStruct
---@field surface vk.SurfaceKHR
---@field minImageCount number
---@field imageFormat number
---@field imageColorSpace number
---@field imageExtent userdata
---@field imageArrayLayers number
---@field imageUsage number
---@field imageSharingMode number
---@field queueFamilyIndexCount number?
---@field pQueueFamilyIndices userdata?
---@field preTransform number
---@field compositeAlpha number
---@field presentMode number
---@field clipped number
---@field oldSwapchain vk.SwapchainKHR

---@class vk.CommandBufferBeginInfoStruct: vk.BaseStruct
---@field pInheritanceInfo userdata?

---@class vk.RenderPassBeginInfo: ffi.cdata*

---@class vk.RenderPassBeginInfoStruct: vk.BaseStruct
---@field renderPass vk.RenderPass
---@field framebuffer vk.Framebuffer
---@field renderArea table
---@field clearValueCount number?
---@field pClearValues userdata?

---@class vk.SemaphoreCreateInfoStruct: vk.BaseStruct

---@class vk.FenceCreateInfoStruct: vk.BaseStruct

---@class vk.PresentInfoKHRStruct: vk.BaseStruct
---@field waitSemaphoreCount number?
---@field pWaitSemaphores ffi.cdata*?
---@field swapchainCount number
---@field pSwapchains ffi.cdata*
---@field pImageIndices ffi.cdata*
---@field pResults ffi.cdata*?

---@class vk.SubmitInfoStruct: vk.BaseStruct
---@field waitSemaphoreCount number?
---@field pWaitSemaphores ffi.cdata*?
---@field pWaitDstStageMask ffi.cdata*?
---@field commandBufferCount number
---@field pCommandBuffers ffi.cdata*?
---@field signalSemaphoreCount number?
---@field pSignalSemaphores ffi.cdata*?

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

	---@param physicalDevice vk.PhysicalDevice
	---@return vk.PhysicalDeviceMemoryProperties
	function vkGlobal.getPhysicalDeviceMemoryProperties(physicalDevice)
		local memProperties = ffi.new("VkPhysicalDeviceMemoryProperties")
		C.vkGetPhysicalDeviceMemoryProperties(physicalDevice, memProperties)
		return memProperties --[[@as vk.PhysicalDeviceMemoryProperties]]
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

	vk.getPhysicalDeviceProperties = vkGlobal.getPhysicalDeviceProperties

	---@param info vk.RenderPassBeginInfoStruct
	function vk.newRenderPassBeginInfo(info)
		local info = ffi.new("VkRenderPassBeginInfo", info)
		info.sType = vk.StructureType.RENDER_PASS_BEGIN_INFO
		return info --[[@as vk.RenderPassBeginInfo]]
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
	---@param info vk.BufferCreateInfoStruct
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
	---@param info vk.ShaderModuleCreateInfoStruct
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
	---@param info vk.PipelineLayoutCreateInfoStruct
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
	---@param infos vk.GraphicsPipelineCreateInfoStruct[]
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
		local result = vkDevice.vkCreateGraphicsPipelines(device, pipelineCache or 0, count, infoArray, allocator, pipelines)
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
	---@param info vk.RenderPassCreateInfoStruct
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
	---@param info vk.FramebufferCreateInfoStruct
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
	---@param info vk.CommandPoolCreateInfoStruct
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
	---@param createInfo vk.CreateImageInfoStruct
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
	---@param info vk.MemoryAllocateInfoStruct
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
	---@param info vk.DescriptorSetLayoutCreateInfoStruct
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
	---@param info vk.DescriptorPoolCreateInfoStruct
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
	---@param info vk.DescriptorSetAllocateInfoStruct
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
	---@param writes vk.WriteDescriptorSetStruct[]
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
	---@param info vk.CommandBufferAllocateInfoStruct
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
	---@param info vk.CommandBufferBeginInfoStruct?
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

	---@type fun(commandBuffer: vk.CommandBuffer, info: vk.RenderPassBeginInfo, contents: vk.SubpassContents)
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
	---@param submits vk.SubmitInfoStruct[]
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
	---@param info vk.SemaphoreCreateInfoStruct
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
	---@param info vk.FenceCreateInfoStruct
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
	---@param info vk.SwapchainCreateInfoKHRStruct
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
	---@param info vk.PresentInfoKHRStruct
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
