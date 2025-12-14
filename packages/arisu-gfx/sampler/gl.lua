local gl = require("arisu-opengl")
local gfx = require("arisu-gfx")
local ffi = require("ffi")

---@class gfx.gl.Sampler
---@field id number
local GLSampler = {}
GLSampler.__index = GLSampler

local addressModesMap = {
	[gfx.AddressMode.CLAMP_TO_EDGE] = gl.CLAMP_TO_EDGE,
	[gfx.AddressMode.REPEAT] = gl.REPEAT,
	[gfx.AddressMode.MIRRORED_REPEAT] = gl.MIRRORED_REPEAT,
}

local filterModesMap = {
	[gfx.FilterMode.NEAREST] = gl.NEAREST,
	[gfx.FilterMode.LINEAR] = gl.LINEAR,
}

local compareFnsMap = {
	[gfx.CompareFunction.NEVER] = gl.NEVER,
	[gfx.CompareFunction.LESS] = gl.LESS,
	[gfx.CompareFunction.EQUAL] = gl.EQUAL,
	[gfx.CompareFunction.LESS_EQUAL] = gl.LESS_EQUAL,
	[gfx.CompareFunction.GREATER] = gl.GREATER,
	[gfx.CompareFunction.NOT_EQUAL] = gl.NOTEQUAL,
	[gfx.CompareFunction.GREATER_EQUAL] = gl.GREATER_EQUAL,
	[gfx.CompareFunction.ALWAYS] = gl.ALWAYS,
}

---@param desc gfx.SamplerDescriptor
function GLSampler.new(desc)
	local id = gl.genSamplers(1)[1]

	gl.samplerParameteri(id, gl.TEXTURE_WRAP_S, addressModesMap[desc.addressModeU])
	gl.samplerParameteri(id, gl.TEXTURE_WRAP_T, addressModesMap[desc.addressModeV])
	gl.samplerParameteri(id, gl.TEXTURE_WRAP_R, addressModesMap[desc.addressModeW])

	gl.samplerParameteri(id, gl.TEXTURE_MIN_FILTER, filterModesMap[desc.minFilter])
	gl.samplerParameteri(id, gl.TEXTURE_MAG_FILTER, filterModesMap[desc.magFilter])

	if desc.lodMinClamp then
		gl.samplerParameterf(id, gl.TEXTURE_MIN_LOD, desc.lodMinClamp)
	end

	if desc.lodMaxClamp then
		gl.samplerParameterf(id, gl.TEXTURE_MAX_LOD, desc.lodMaxClamp)
	end

	if desc.compareOp then
		gl.samplerParameteri(id, gl.TEXTURE_COMPARE_MODE, gl.COMPARE_REF_TO_TEXTURE)
		gl.samplerParameteri(id, gl.TEXTURE_COMPARE_FUNC, compareFnsMap[desc.compareOp])
	else
		gl.samplerParameteri(id, gl.TEXTURE_COMPARE_MODE, gl.NONE)
	end

	if desc.maxAnisotropy then
		gl.samplerParameterf(id, gl.TEXTURE_MAX_ANISOTROPY, desc.maxAnisotropy)
	end

	return setmetatable({ id = id }, GLSampler)
end

function GLSampler:destroy()
	gl.deleteSamplers(1, ffi.new("GLuint[1]", self.id))
end

return GLSampler
