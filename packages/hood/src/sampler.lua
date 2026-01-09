---@class hood.SamplerDescriptor
---@field addressModeU hood.AddressMode
---@field addressModeV hood.AddressMode
---@field addressModeW hood.AddressMode
---@field magFilter hood.FilterMode
---@field minFilter hood.FilterMode
-- @field mipmapFilter hood.FilterMode
---@field lodMinClamp number?
---@field lodMaxClamp number?
---@field maxAnisotropy number?
---@field compareOp hood.CompareFunction?

---@class hood.Sampler
---@field new fun(desc: hood.SamplerDescriptor): hood.Sampler
---@field destroy fun(self: hood.Sampler)
local Sampler = require("hood.sampler.gl") --[[@as hood.Sampler]]
