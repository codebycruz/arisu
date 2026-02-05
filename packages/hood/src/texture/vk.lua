local vk = require("arisu-vulkan")

---@class hood.vk.Texture
local VKTexture = {}
VKTexture.__index = VKTexture

---@param device hood.vk.Device
---@param descriptor hood.TextureDescriptor
function VKTexture.new(device, descriptor) end
