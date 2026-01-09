---@alias hood.TextureUsage
--- | "COPY_SRC"
--- | "COPY_DST"
--- | "TEXTURE_BINDING"
--- | "RENDER_ATTACHMENT"
--- | "STORAGE_BINDING"

---@alias hood.TextureExtents
--- | { dim: "3d", width: number, height: number, depth: number }
--- | { dim: "2d", width: number, height: number, count?: number }
--- | { dim: "1d", width: number, count?: number }

---@class hood.TextureDescriptor
---@field extents hood.TextureExtents
---@field format hood.TextureFormat
---@field usages hood.TextureUsage[]
---@field mipLevelCount number?
---@field sampleCount number?

---@class hood.Texture
---@field new fun(device: hood.Device, descriptor: hood.TextureDescriptor): hood.Texture
---@field destroy fun(self: hood.Texture)
local Texture = require("hood.texture.gl") --[[@as hood.Texture]]

return Texture
