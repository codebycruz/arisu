---@class vk.ffi.BaseStruct
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

---@class vk.ffi.CreateImageInfo: vk.ffi.BaseStruct
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

---@class vk.QueueFamilyProperties: ffi.cdata*
---@field queueFlags number
---@field queueCount number
---@field timestampValidBits number
---@field minImageTransferGranularity vk.Extent3D

---@class vk.ffi.MemoryAllocateInfo: vk.ffi.BaseStruct
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

---@class vk.ffi.InstanceCreateInfo: vk.ffi.BaseStruct
---@field pApplicationInfo ffi.cdata*?
---@field enabledLayerCount number?
---@field ppEnabledLayerNames ffi.cdata*?
---@field enabledExtensionCount number?
---@field ppEnabledExtensionNames ffi.cdata*?

---@class vk.ffi.DeviceCreateInfo: vk.ffi.BaseStruct
---@field queueCreateInfoCount number?
---@field pQueueCreateInfos userdata?
---@field enabledExtensionCount number?
---@field ppEnabledExtensionNames userdata?
---@field pEnabledFeatures userdata?

---@class vk.ffi.BufferCreateInfo: vk.ffi.BaseStruct
---@field size number
---@field usage vk.BufferUsage
---@field sharingMode vk.SharingMode?
---@field queueFamilyIndexCount number?
---@field pQueueFamilyIndices userdata?

---@class vk.ffi.ShaderModuleCreateInfo: vk.ffi.BaseStruct
---@field codeSize number
---@field pCode userdata

---@class vk.ffi.PipelineLayoutCreateInfo: vk.ffi.BaseStruct
---@field setLayoutCount number?
---@field pSetLayouts userdata?
---@field pushConstantRangeCount number?
---@field pPushConstantRanges userdata?

---@class vk.ffi.GraphicsPipelineCreateInfo: vk.ffi.BaseStruct
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

---@class vk.ffi.RenderPassCreateInfo: vk.ffi.BaseStruct
---@field attachmentCount number?
---@field pAttachments userdata?
---@field subpassCount number
---@field pSubpasses userdata
---@field dependencyCount number?
---@field pDependencies userdata?

---@class vk.ffi.FramebufferCreateInfo: vk.ffi.BaseStruct
---@field renderPass vk.RenderPass
---@field attachmentCount number?
---@field pAttachments userdata?
---@field width number
---@field height number
---@field layers number

---@class vk.ffi.CommandPoolCreateInfo: vk.ffi.BaseStruct
---@field flags number?
---@field queueFamilyIndex number

---@class vk.ffi.CommandBufferAllocateInfo: vk.ffi.BaseStruct
---@field commandPool vk.CommandPool
---@field level number
---@field commandBufferCount number

---@class vk.DescriptorSetLayoutBinding: ffi.cdata*
---@field binding number
---@field descriptorType number
---@field descriptorCount number
---@field stageFlags number
---@field pImmutableSamplers ffi.cdata*?

---@class vk.ffi.DescriptorSetLayoutCreateInfo: vk.ffi.BaseStruct
---@field bindingCount number?
---@field pBindings ffi.cdata*?

---@class vk.DescriptorPoolSize: ffi.cdata*
---@field type number
---@field descriptorCount number

---@class vk.ffi.DescriptorPoolCreateInfo: vk.ffi.BaseStruct
---@field maxSets number
---@field poolSizeCount number?
---@field pPoolSizes ffi.cdata*?

---@class vk.ffi.DescriptorSetAllocateInfo: vk.ffi.BaseStruct
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

---@class vk.ffi.WriteDescriptorSet: vk.ffi.BaseStruct
---@field dstSet vk.DescriptorSet
---@field dstBinding number
---@field dstArrayElement number
---@field descriptorCount number
---@field descriptorType number
---@field pImageInfo ffi.cdata*?
---@field pBufferInfo ffi.cdata*?
---@field pTexelBufferView ffi.cdata*?

---@class vk.ffi.SwapchainCreateInfoKHR: vk.ffi.BaseStruct
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

---@class vk.ffi.CommandBufferBeginInfo: vk.ffi.BaseStruct
---@field pInheritanceInfo userdata?

---@class vk.ffi.RenderPassBeginInfo: vk.ffi.BaseStruct
---@field renderPass vk.RenderPass
---@field framebuffer vk.Framebuffer
---@field renderArea table
---@field clearValueCount number?
---@field pClearValues userdata?

---@class vk.ffi.SemaphoreCreateInfo: vk.ffi.BaseStruct

---@class vk.ffi.FenceCreateInfo: vk.ffi.BaseStruct

---@class vk.ffi.PresentInfoKHR: vk.ffi.BaseStruct
---@field waitSemaphoreCount number?
---@field pWaitSemaphores ffi.cdata*?
---@field swapchainCount number
---@field pSwapchains ffi.cdata*
---@field pImageIndices ffi.cdata*
---@field pResults ffi.cdata*?

---@class vk.ffi.SubmitInfo: vk.ffi.BaseStruct
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
