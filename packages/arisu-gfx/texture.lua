---@alias gfx.TextureUsage
--- | "COPY_SRC"
--- | "COPY_DST"
--- | "TEXTURE_BINDING"
--- | "RENDER_ATTACHMENT"
--- | "STORAGE_BINDING"

---@alias gfx.TextureExtents
--- | { dim: "3d", width: number, height: number, depth: number }
--- | { dim: "2d", width: number, height: number, count?: number }
--- | { dim: "1d", width: number, count?: number }

---@class gfx.TextureDescriptor
---@field extents gfx.TextureExtents
---@field format gfx.TextureFormat
---@field usages gfx.TextureUsage[]
---@field mipLevelCount number?
---@field sampleCount number?

---@class gfx.Texture
---@field new fun(device: gfx.Device, descriptor: gfx.TextureDescriptor): gfx.Texture
---@field destroy fun(self: gfx.Texture)
local Texture = require("arisu-gfx.texture.gl") --[[@as gfx.Texture]]

return Texture
