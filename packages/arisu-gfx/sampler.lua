---@class gfx.SamplerDescriptor
---@field addressModeU gfx.AddressMode
---@field addressModeV gfx.AddressMode
---@field addressModeW gfx.AddressMode
---@field magFilter gfx.FilterMode
---@field minFilter gfx.FilterMode
---@field mipmapFilter gfx.FilterMode
---@field lodMinClamp number
---@field lodMaxClamp number
---@field maxAnisotropy number
---@field compareOp gfx.CompareFunction?

---@class gfx.Sampler
---@field new fun(desc: gfx.SamplerDescriptor): gfx.Sampler
local Sampler = require("arisu-gfx.sampler.gl") --[[@as gfx.Sampler]]
