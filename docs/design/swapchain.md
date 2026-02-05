# Swapchain

The presence of the Swapchain differs from WebGPU and aligns more with Vulkan/DirectX APIs.

Most notably to the user, however, is that submitting work via the queue to your framebuffer will not automatically present to the screen.

To do so, you must use `device.queue.present(swapchain)`.

This was chosen because

1. It aligns closer to Vulkan's design, which requires an explicit present call from the queue.
2. It aligns with DirectX's design, however without the swapchain storing a reference to the command queue and calling present from the swapchain.
