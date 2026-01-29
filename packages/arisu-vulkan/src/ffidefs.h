typedef unsigned long long uint64_t;
typedef unsigned long uint32_t;

typedef long long int64_t;
typedef long int32_t;

typedef uint64_t size_t;
typedef unsigned char uint8_t;

typedef uint64_t VkInstance;
typedef uint64_t VkDevice;
typedef int32_t VkResult;
typedef int32_t VkStructureType;
typedef uint32_t VkFlags;
typedef void *VkPhysicalDevice;
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
typedef VkFlags VkImageAspectFlags;

typedef struct {
  uint32_t width;
  uint32_t height;
  uint32_t depth;
} VkExtent3D;

typedef struct {
  int32_t x;
  int32_t y;
  int32_t z;
} VkOffset3D;

typedef struct {
  int32_t x;
  int32_t y;
} VkOffset2D;

typedef struct {
  uint32_t width;
  uint32_t height;
} VkExtent2D;

typedef uint64_t VkSwapchainKHR;
typedef uint64_t VkSurfaceKHR;

typedef struct {
  VkStructureType sType;
  const void *pNext;
  const char *pApplicationName;
  uint32_t applicationVersion;
  const char *pEngineName;
  uint32_t engineVersion;
  uint32_t apiVersion;
} VkApplicationInfo;

typedef struct {
  VkStructureType sType;
  const void *pNext;
  VkFlags flags;
  const VkApplicationInfo *pApplicationInfo;
  uint32_t enabledLayerCount;
  const char *const *ppEnabledLayerNames;
  uint32_t enabledExtensionCount;
  const char *const *ppEnabledExtensionNames;
} VkInstanceCreateInfo;

void *vkGetInstanceProcAddr(VkInstance instance, const char *pName);
void *vkGetDeviceProcAddr(VkDevice device, const char *pName);

VkResult vkCreateInstance(const VkInstanceCreateInfo *pCreateInfo,
                          const VkAllocationCallbacks *pAllocator,
                          VkInstance *pInstance);

VkResult vkEnumeratePhysicalDevices(VkInstance instance,
                                    uint32_t *pPhysicalDeviceCount,
                                    VkPhysicalDevice *pPhysicalDevices);

typedef struct {
  VkBool32 robustBufferAccess;
  VkBool32 fullDrawIndexUint32;
  VkBool32 imageCubeArray;
  VkBool32 independentBlend;
  VkBool32 geometryShader;
  VkBool32 tessellationShader;
  VkBool32 sampleRateShading;
  VkBool32 dualSrcBlend;
  VkBool32 logicOp;
  VkBool32 multiDrawIndirect;
  VkBool32 drawIndirectFirstInstance;
  VkBool32 depthClamp;
  VkBool32 depthBiasClamp;
  VkBool32 fillModeNonSolid;
  VkBool32 depthBounds;
  VkBool32 wideLines;
  VkBool32 largePoints;
  VkBool32 alphaToOne;
  VkBool32 multiViewport;
  VkBool32 samplerAnisotropy;
  VkBool32 textureCompressionETC2;
  VkBool32 textureCompressionASTC_LDR;
  VkBool32 textureCompressionBC;
  VkBool32 occlusionQueryPrecise;
  VkBool32 pipelineStatisticsQuery;
  VkBool32 vertexPipelineStoresAndAtomics;
  VkBool32 fragmentStoresAndAtomics;
  VkBool32 shaderTessellationAndGeometryPointSize;
  VkBool32 shaderImageGatherExtended;
  VkBool32 shaderStorageImageExtendedFormats;
  VkBool32 shaderStorageImageMultisample;
  VkBool32 shaderStorageImageReadWithoutFormat;
  VkBool32 shaderStorageImageWriteWithoutFormat;
  VkBool32 shaderUniformBufferArrayDynamicIndexing;
  VkBool32 shaderSampledImageArrayDynamicIndexing;
  VkBool32 shaderStorageBufferArrayDynamicIndexing;
  VkBool32 shaderStorageImageArrayDynamicIndexing;
  VkBool32 shaderClipDistance;
  VkBool32 shaderCullDistance;
  VkBool32 shaderFloat64;
  VkBool32 shaderInt64;
  VkBool32 shaderInt16;
  VkBool32 shaderResourceResidency;
  VkBool32 shaderResourceMinLod;
  VkBool32 sparseBinding;
  VkBool32 sparseResidencyBuffer;
  VkBool32 sparseResidencyImage2D;
  VkBool32 sparseResidencyImage3D;
  VkBool32 sparseResidency2Samples;
  VkBool32 sparseResidency4Samples;
  VkBool32 sparseResidency8Samples;
  VkBool32 sparseResidency16Samples;
  VkBool32 sparseResidencyAliased;
  VkBool32 variableMultisampleRate;
  VkBool32 inheritedQueries;
} VkPhysicalDeviceFeatures;

typedef struct {
  uint32_t maxImageDimension1D;
  uint32_t maxImageDimension2D;
  uint32_t maxImageDimension3D;
  uint32_t maxImageDimensionCube;
  uint32_t maxImageArrayLayers;
  uint32_t maxTexelBufferElements;
  uint32_t maxUniformBufferRange;
  uint32_t maxStorageBufferRange;
  uint32_t maxPushConstantsSize;
  uint32_t maxMemoryAllocationCount;
  uint32_t maxSamplerAllocationCount;
  VkDeviceSize bufferImageGranularity;
  VkDeviceSize sparseAddressSpaceSize;
  uint32_t maxBoundDescriptorSets;
  uint32_t maxPerStageDescriptorSamplers;
  uint32_t maxPerStageDescriptorUniformBuffers;
  uint32_t maxPerStageDescriptorStorageBuffers;
  uint32_t maxPerStageDescriptorSampledImages;
  uint32_t maxPerStageDescriptorStorageImages;
  uint32_t maxPerStageDescriptorInputAttachments;
  uint32_t maxPerStageResources;
  uint32_t maxDescriptorSetSamplers;
  uint32_t maxDescriptorSetUniformBuffers;
  uint32_t maxDescriptorSetUniformBuffersDynamic;
  uint32_t maxDescriptorSetStorageBuffers;
  uint32_t maxDescriptorSetStorageBuffersDynamic;
  uint32_t maxDescriptorSetSampledImages;
  uint32_t maxDescriptorSetStorageImages;
  uint32_t maxDescriptorSetInputAttachments;
  uint32_t maxVertexInputAttributes;
  uint32_t maxVertexInputBindings;
  uint32_t maxVertexInputAttributeOffset;
  uint32_t maxVertexInputBindingStride;
  uint32_t maxVertexOutputComponents;
  uint32_t maxTessellationGenerationLevel;
  uint32_t maxTessellationPatchSize;
  uint32_t maxTessellationControlPerVertexInputComponents;
  uint32_t maxTessellationControlPerVertexOutputComponents;
  uint32_t maxTessellationControlPerPatchOutputComponents;
  uint32_t maxTessellationControlTotalOutputComponents;
  uint32_t maxTessellationEvaluationInputComponents;
  uint32_t maxTessellationEvaluationOutputComponents;
  uint32_t maxGeometryShaderInvocations;
  uint32_t maxGeometryInputComponents;
  uint32_t maxGeometryOutputComponents;
  uint32_t maxGeometryOutputVertices;
  uint32_t maxGeometryTotalOutputComponents;
  uint32_t maxFragmentInputComponents;
  uint32_t maxFragmentOutputAttachments;
  uint32_t maxFragmentDualSrcAttachments;
  uint32_t maxFragmentCombinedOutputResources;
  uint32_t maxComputeSharedMemorySize;
  uint32_t maxComputeWorkGroupCount[3];
  uint32_t maxComputeWorkGroupInvocations;
  uint32_t maxComputeWorkGroupSize[3];
  uint32_t subPixelPrecisionBits;
  uint32_t subTexelPrecisionBits;
  uint32_t mipmapPrecisionBits;
  uint32_t maxDrawIndexedIndexValue;
  uint32_t maxDrawIndirectCount;
  float maxSamplerLodBias;
  float maxSamplerAnisotropy;
  uint32_t maxViewports;
  uint32_t maxViewportDimensions[2];
  float viewportBoundsRange[2];
  uint32_t viewportSubPixelBits;
  size_t minMemoryMapAlignment;
  VkDeviceSize minTexelBufferOffsetAlignment;
  VkDeviceSize minUniformBufferOffsetAlignment;
  VkDeviceSize minStorageBufferOffsetAlignment;
  int32_t minTexelOffset;
  uint32_t maxTexelOffset;
  int32_t minTexelGatherOffset;
  uint32_t maxTexelGatherOffset;
  float minInterpolationOffset;
  float maxInterpolationOffset;
  uint32_t subPixelInterpolationOffsetBits;
  uint32_t maxFramebufferWidth;
  uint32_t maxFramebufferHeight;
  uint32_t maxFramebufferLayers;
  VkSampleCountFlags framebufferColorSampleCounts;
  VkSampleCountFlags framebufferDepthSampleCounts;
  VkSampleCountFlags framebufferStencilSampleCounts;
  VkSampleCountFlags framebufferNoAttachmentsSampleCounts;
  uint32_t maxColorAttachments;
  VkSampleCountFlags sampledImageColorSampleCounts;
  VkSampleCountFlags sampledImageIntegerSampleCounts;
  VkSampleCountFlags sampledImageDepthSampleCounts;
  VkSampleCountFlags sampledImageStencilSampleCounts;
  VkSampleCountFlags storageImageSampleCounts;
  uint32_t maxSampleMaskWords;
  VkBool32 timestampComputeAndGraphics;
  float timestampPeriod;
  uint32_t maxClipDistances;
  uint32_t maxCullDistances;
  uint32_t maxCombinedClipAndCullDistances;
  uint32_t discreteQueuePriorities;
  float pointSizeRange[2];
  float lineWidthRange[2];
  float pointSizeGranularity;
  float lineWidthGranularity;
  VkBool32 strictLines;
  VkBool32 standardSampleLocations;
  VkDeviceSize optimalBufferCopyOffsetAlignment;
  VkDeviceSize optimalBufferCopyRowPitchAlignment;
  VkDeviceSize nonCoherentAtomSize;
} VkPhysicalDeviceLimits;

typedef struct {
  VkBool32 residencyStandard2DBlockShape;
  VkBool32 residencyStandard2DMultisampleBlockShape;
  VkBool32 residencyStandard3DBlockShape;
  VkBool32 residencyAlignedMipSize;
  VkBool32 residencyNonResidentStrict;
} VkPhysicalDeviceSparseProperties;

typedef struct {
  uint32_t apiVersion;
  uint32_t driverVersion;
  uint32_t vendorID;
  uint32_t deviceID;
  VkPhysicalDeviceType deviceType;
  char deviceName[256];
  uint8_t pipelineCacheUUID[16];
  VkPhysicalDeviceLimits limits;
  VkPhysicalDeviceSparseProperties sparseProperties;
} VkPhysicalDeviceProperties;

typedef struct {
  VkDeviceSize size;
  uint32_t alignment;
  uint32_t memoryTypeBits;
} VkMemoryRequirements;

typedef struct {
  VkMemoryPropertyFlags propertyFlags;
  uint32_t heapIndex;
} VkMemoryType;

typedef struct {
  VkDeviceSize size;
  VkMemoryHeapFlags flags;
} VkMemoryHeap;

typedef struct {
  uint32_t memoryTypeCount;
  VkMemoryType memoryTypes[32];
  uint32_t memoryHeapCount;
  VkMemoryHeap memoryHeaps[16];
} VkPhysicalDeviceMemoryProperties;

typedef struct {
  VkStructureType sType;
  const void *pNext;
  uint32_t allocationSize;
  uint32_t memoryTypeIndex;
} VkMemoryAllocateInfo;

typedef struct {
  VkStructureType sType;
  const void *pNext;
  VkFlags flags;
  uint32_t queueCreateInfoCount;
  const void *pQueueCreateInfos;
  uint32_t _enabledLayerCount;
  const char *const *_ppEnabledLayerNames;
  uint32_t enabledExtensionCount;
  const char *const *ppEnabledExtensionNames;
  const VkPhysicalDeviceFeatures *pEnabledFeatures;
} VkDeviceCreateInfo;

typedef struct {
  VkStructureType sType;
  const void *pNext;
  VkBufferCreateFlags flags;
  VkDeviceSize size;
  VkBufferUsageFlags usage;
  VkSharingMode sharingMode;
  uint32_t queueFamilyIndexCount;
  const uint32_t *pQueueFamilyIndices;
} VkBufferCreateInfo;

typedef struct {
  VkStructureType sType;
  const void *pNext;
  VkImageCreateFlags flags;
  VkImageType imageType;
  VkFormat format;
  VkExtent3D extent;
  uint32_t mipLevels;
  uint32_t arrayLayers;
  VkSampleCountFlags samples;
  VkImageTiling tiling;
  VkImageUsageFlags usage;
  VkSharingMode sharingMode;
  uint32_t queueFamilyIndexCount;
  const uint32_t *pQueueFamilyIndices;
  VkImageLayout initialLayout;
} VkImageCreateInfo;

typedef struct {
  VkImageAspectFlags aspectMask;
  uint32_t mipLevel;
  uint32_t baseArrayLayer;
  uint32_t layerCount;
} VkImageSubresourceLayers;

typedef struct {
  VkDeviceSize bufferOffset;
  uint32_t bufferRowLength;
  uint32_t bufferImageHeight;
  VkImageSubresourceLayers imageSubresource;
  VkOffset3D imageOffset;
  VkExtent3D imageExtent;
} VkBufferImageCopy;

typedef struct {
  VkStructureType sType;
  const void *pNext;
  VkShaderModuleCreateFlags flags;
  size_t codeSize;
  const uint32_t *pCode;
} VkShaderModuleCreateInfo;

typedef struct {
  VkStructureType sType;
  const void *pNext;
  VkPipelineLayoutCreateFlags flags;
  uint32_t setLayoutCount;
  const void *pSetLayouts;
  uint32_t pushConstantRangeCount;
  const void *pPushConstantRanges;
} VkPipelineLayoutCreateInfo;

typedef struct {
  VkStructureType sType;
  const void *pNext;
  VkPipelineCreateFlags flags;
  uint32_t stageCount;
  const void *pStages;
  const void *pVertexInputState;
  const void *pInputAssemblyState;
  const void *pTessellationState;
  const void *pViewportState;
  const void *pRasterizationState;
  const void *pMultisampleState;
  const void *pDepthStencilState;
  const void *pColorBlendState;
  const void *pDynamicState;
  VkPipelineLayout layout;
  VkRenderPass renderPass;
  uint32_t subpass;
  VkPipeline basePipelineHandle;
  int32_t basePipelineIndex;
} VkGraphicsPipelineCreateInfo;

typedef struct {
  VkStructureType sType;
  const void *pNext;
  VkRenderPassCreateFlags flags;
  uint32_t attachmentCount;
  const void *pAttachments;
  uint32_t subpassCount;
  const void *pSubpasses;
  uint32_t dependencyCount;
  const void *pDependencies;
} VkRenderPassCreateInfo;

typedef struct {
  VkStructureType sType;
  const void *pNext;
  VkFramebufferCreateFlags flags;
  VkRenderPass renderPass;
  uint32_t attachmentCount;
  const void *pAttachments;
  uint32_t width;
  uint32_t height;
  uint32_t layers;
} VkFramebufferCreateInfo;

typedef struct {
  VkStructureType sType;
  const void *pNext;
  VkCommandPoolCreateFlags flags;
  uint32_t queueFamilyIndex;
} VkCommandPoolCreateInfo;

typedef struct {
  VkStructureType sType;
  const void *pNext;
  VkCommandPool commandPool;
  VkCommandBufferLevel level;
  uint32_t commandBufferCount;
} VkCommandBufferAllocateInfo;

typedef struct {
  VkStructureType sType;
  const void *pNext;
  VkCommandBufferUsageFlags flags;
  const void *pInheritanceInfo;
} VkCommandBufferBeginInfo;

typedef struct {
  VkStructureType sType;
  const void *pNext;
  VkFlags flags;
} VkSemaphoreCreateInfo;

typedef struct {
  VkStructureType sType;
  const void *pNext;
  VkFlags flags;
} VkFenceCreateInfo;

typedef struct {
  uint32_t binding;
  VkDescriptorType descriptorType;
  uint32_t descriptorCount;
  VkShaderStageFlags stageFlags;
  const void *pImmutableSamplers;
} VkDescriptorSetLayoutBinding;

typedef struct {
  VkStructureType sType;
  const void *pNext;
  VkDescriptorSetLayoutCreateFlags flags;
  uint32_t bindingCount;
  const VkDescriptorSetLayoutBinding *pBindings;
} VkDescriptorSetLayoutCreateInfo;

typedef struct {
  VkDescriptorType type;
  uint32_t descriptorCount;
} VkDescriptorPoolSize;

typedef struct {
  VkStructureType sType;
  const void *pNext;
  VkDescriptorPoolCreateFlags flags;
  uint32_t maxSets;
  uint32_t poolSizeCount;
  const VkDescriptorPoolSize *pPoolSizes;
} VkDescriptorPoolCreateInfo;

typedef struct {
  VkStructureType sType;
  const void *pNext;
  VkDescriptorPool descriptorPool;
  uint32_t descriptorSetCount;
  const VkDescriptorSetLayout *pSetLayouts;
} VkDescriptorSetAllocateInfo;

typedef struct {
  VkBuffer buffer;
  VkDeviceSize offset;
  VkDeviceSize range;
} VkDescriptorBufferInfo;

typedef struct {
  VkSampler sampler;
  VkImageView imageView;
  VkImageLayout imageLayout;
} VkDescriptorImageInfo;

typedef struct {
  VkStructureType sType;
  const void *pNext;
  VkDescriptorSet dstSet;
  uint32_t dstBinding;
  uint32_t dstArrayElement;
  uint32_t descriptorCount;
  VkDescriptorType descriptorType;
  const VkDescriptorImageInfo *pImageInfo;
  const VkDescriptorBufferInfo *pBufferInfo;
  const void *pTexelBufferView;
} VkWriteDescriptorSet;

typedef struct {
  uint32_t minImageCount;
  uint32_t maxImageCount;
  VkExtent2D currentExtent;
  VkExtent2D minImageExtent;
  VkExtent2D maxImageExtent;
  uint32_t maxImageArrayLayers;
  VkSurfaceTransformFlagsKHR supportedTransforms;
  VkSurfaceTransformFlagBitsKHR currentTransform;
  VkCompositeAlphaFlagsKHR supportedCompositeAlpha;
  VkImageUsageFlags supportedUsageFlags;
} VkSurfaceCapabilitiesKHR;

typedef struct {
  VkFormat format;
  VkColorSpaceKHR colorSpace;
} VkSurfaceFormatKHR;

typedef struct {
  VkStructureType sType;
  const void *pNext;
  VkSwapchainCreateFlagsKHR flags;
  VkSurfaceKHR surface;
  uint32_t minImageCount;
  VkFormat imageFormat;
  VkColorSpaceKHR imageColorSpace;
  VkExtent2D imageExtent;
  uint32_t imageArrayLayers;
  VkImageUsageFlags imageUsage;
  VkSharingMode imageSharingMode;
  uint32_t queueFamilyIndexCount;
  const uint32_t *pQueueFamilyIndices;
  VkSurfaceTransformFlagBitsKHR preTransform;
  VkCompositeAlphaFlagBitsKHR compositeAlpha;
  VkPresentModeKHR presentMode;
  VkBool32 clipped;
  VkSwapchainKHR oldSwapchain;
} VkSwapchainCreateInfoKHR;

typedef struct {
  VkOffset2D offset;
  VkExtent2D extent;
} VkRect2D;

typedef struct {
  VkStructureType sType;
  const void *pNext;
  VkRenderPass renderPass;
  VkFramebuffer framebuffer;
  VkRect2D renderArea;
  uint32_t clearValueCount;
  const void *pClearValues;
} VkRenderPassBeginInfo;

typedef struct {
  VkStructureType sType;
  const void *pNext;
  uint32_t waitSemaphoreCount;
  const VkSemaphore *pWaitSemaphores;
  const void *pWaitDstStageMask;
  uint32_t commandBufferCount;
  const VkCommandBuffer *pCommandBuffers;
  uint32_t signalSemaphoreCount;
  const VkSemaphore *pSignalSemaphores;
} VkSubmitInfo;

typedef struct {
  VkStructureType sType;
  const void *pNext;
  uint32_t waitSemaphoreCount;
  const VkSemaphore *pWaitSemaphores;
  uint32_t swapchainCount;
  const VkSwapchainKHR *pSwapchains;
  const uint32_t *pImageIndices;
  VkResult *pResults;
} VkPresentInfoKHR;

VkResult vkGetPhysicalDeviceProperties(VkPhysicalDevice physicalDevice,
                                       VkPhysicalDeviceProperties *pProperties);

void vkGetPhysicalDeviceMemoryProperties(
    VkPhysicalDevice physicalDevice,
    VkPhysicalDeviceMemoryProperties *pMemoryProperties);

VkResult vkGetPhysicalDeviceSurfaceCapabilitiesKHR(
    VkPhysicalDevice physicalDevice, VkSurfaceKHR surface,
    VkSurfaceCapabilitiesKHR *pSurfaceCapabilities);

VkResult vkGetPhysicalDeviceSurfaceFormatsKHR(
    VkPhysicalDevice physicalDevice, VkSurfaceKHR surface,
    uint32_t *pSurfaceFormatCount, VkSurfaceFormatKHR *pSurfaceFormats);

VkResult vkGetPhysicalDeviceSurfacePresentModesKHR(
    VkPhysicalDevice physicalDevice, VkSurfaceKHR surface,
    uint32_t *pPresentModeCount, VkPresentModeKHR *pPresentModes);

VkResult vkCreatePipelineLayout(VkDevice device,
                                const VkPipelineLayoutCreateInfo *pCreateInfo,
                                const VkAllocationCallbacks *pAllocator,
                                VkPipelineLayout *pPipelineLayout);

VkResult vkCreateGraphicsPipelines(
    VkDevice device, uint64_t pipelineCache, uint32_t createInfoCount,
    const VkGraphicsPipelineCreateInfo *pCreateInfos,
    const VkAllocationCallbacks *pAllocator, VkPipeline *pPipelines);

VkResult vkCreateRenderPass(VkDevice device,
                            const VkRenderPassCreateInfo *pCreateInfo,
                            const VkAllocationCallbacks *pAllocator,
                            VkRenderPass *pRenderPass);

VkResult vkCreateFramebuffer(VkDevice device,
                             const VkFramebufferCreateInfo *pCreateInfo,
                             const VkAllocationCallbacks *pAllocator,
                             VkFramebuffer *pFramebuffer);

void vkGetBufferMemoryRequirements(VkDevice device, VkBuffer buffer,
                                   VkMemoryRequirements *pMemoryRequirements);

void vkGetImageMemoryRequirements(VkDevice device, VkImage image,
                                  VkMemoryRequirements *pMemoryRequirements);

VkResult vkCreateImage(VkDevice device, const VkImageCreateInfo *pCreateInfo,
                       const VkAllocationCallbacks *pAllocator,
                       VkImage *pImage);

VkResult vkBindImageMemory(VkDevice device, VkImage image,
                           VkDeviceMemory memory, VkDeviceSize memoryOffset);

void vkCmdCopyBufferToImage(VkCommandBuffer commandBuffer, VkBuffer srcBuffer,
                            VkImage dstImage, VkImageLayout dstImageLayout,
                            uint32_t regionCount,
                            const VkBufferImageCopy *pRegions);

VkResult vkAllocateMemory(VkDevice device,
                          const VkMemoryAllocateInfo *pAllocateInfo,
                          const VkAllocationCallbacks *pAllocator,
                          VkDeviceMemory *pMemory);

VkResult vkBindBufferMemory(VkDevice device, VkBuffer buffer,
                            VkDeviceMemory memory, VkDeviceSize memoryOffset);

VkResult vkMapMemory(VkDevice device, VkDeviceMemory memory,
                     VkDeviceSize offset, VkDeviceSize size, VkFlags flags,
                     void **ppData);

void vkUnmapMemory(VkDevice device, VkDeviceMemory memory);

VkResult vkCreateCommandPool(VkDevice device,
                             const VkCommandPoolCreateInfo *pCreateInfo,
                             const VkAllocationCallbacks *pAllocator,
                             VkCommandPool *pCommandPool);

VkResult vkCreateDescriptorSetLayout(
    VkDevice device, const VkDescriptorSetLayoutCreateInfo *pCreateInfo,
    const VkAllocationCallbacks *pAllocator, VkDescriptorSetLayout *pSetLayout);

VkResult vkCreateDescriptorPool(VkDevice device,
                                const VkDescriptorPoolCreateInfo *pCreateInfo,
                                const VkAllocationCallbacks *pAllocator,
                                VkDescriptorPool *pDescriptorPool);

VkResult
vkAllocateDescriptorSets(VkDevice device,
                         const VkDescriptorSetAllocateInfo *pAllocateInfo,
                         VkDescriptorSet *pDescriptorSets);

void vkUpdateDescriptorSets(VkDevice device, uint32_t descriptorWriteCount,
                            const VkWriteDescriptorSet *pDescriptorWrites,
                            uint32_t descriptorCopyCount,
                            const void *pDescriptorCopies);

VkResult
vkAllocateCommandBuffers(VkDevice device,
                         const VkCommandBufferAllocateInfo *pAllocateInfo,
                         VkCommandBuffer *pCommandBuffers);

VkResult vkBeginCommandBuffer(VkCommandBuffer commandBuffer,
                              const VkCommandBufferBeginInfo *pBeginInfo);

VkResult vkEndCommandBuffer(VkCommandBuffer commandBuffer);

void vkCmdBeginRenderPass(VkCommandBuffer commandBuffer,
                          const VkRenderPassBeginInfo *pRenderPassBegin,
                          VkSubpassContents contents);

void vkCmdEndRenderPass(VkCommandBuffer commandBuffer);

void vkCmdBindPipeline(VkCommandBuffer commandBuffer,
                       VkPipelineBindPoint pipelineBindPoint,
                       VkPipeline pipeline);

void vkCmdDraw(VkCommandBuffer commandBuffer, uint32_t vertexCount,
               uint32_t instanceCount, uint32_t firstVertex,
               uint32_t firstInstance);

VkResult vkQueueSubmit(VkQueue queue, uint32_t submitCount,
                       const VkSubmitInfo *pSubmits, uint64_t fence);

VkResult vkQueueWaitIdle(VkQueue queue);

void vkGetDeviceQueue(VkDevice device, uint32_t queueFamilyIndex,
                      uint32_t queueIndex, VkQueue *pQueue);

VkResult vkCreateSemaphore(VkDevice device,
                           const VkSemaphoreCreateInfo *pCreateInfo,
                           const VkAllocationCallbacks *pAllocator,
                           VkSemaphore *pSemaphore);

VkResult vkCreateFence(VkDevice device, const VkFenceCreateInfo *pCreateInfo,
                       const VkAllocationCallbacks *pAllocator,
                       VkFence *pFence);

VkResult vkCreateSwapchainKHR(VkDevice device,
                              const VkSwapchainCreateInfoKHR *pCreateInfo,
                              const VkAllocationCallbacks *pAllocator,
                              VkSwapchainKHR *pSwapchain);

VkResult vkGetSwapchainImagesKHR(VkDevice device, VkSwapchainKHR swapchain,
                                 uint32_t *pSwapchainImageCount,
                                 VkImage *pSwapchainImages);

VkResult vkAcquireNextImageKHR(VkDevice device, VkSwapchainKHR swapchain,
                               uint64_t timeout, VkSemaphore semaphore,
                               VkFence fence, uint32_t *pImageIndex);

VkResult vkQueuePresentKHR(VkQueue queue, const VkPresentInfoKHR *pPresentInfo);
