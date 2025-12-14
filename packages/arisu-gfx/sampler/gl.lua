---@class gfx.gl.Sampler
---@field desc gfx.SamplerDescriptor
local GLSampler = {}
GLSampler.__index = GLSampler

---@param desc gfx.SamplerDescriptor
function GLSampler.new(desc)
	return setmetatable({ desc = desc }, GLSampler)
end

return GLSampler
