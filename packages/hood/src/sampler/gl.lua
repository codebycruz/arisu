local gl = require("hood-opengl")
local hood = require("hood")
local ffi = require("ffi")

---@class hood.gl.Sampler
---@field id number
local GLSampler = {}
GLSampler.__index = GLSampler

local addressModesMap = {
	[hood.AddressMode.CLAMP_TO_EDGE] = gl.CLAMP_TO_EDGE,
	[hood.AddressMode.REPEAT] = gl.REPEAT,
	[hood.AddressMode.MIRRORED_REPEAT] = gl.MIRRORED_REPEAT,
}

local filterModesMap = {
	[hood.FilterMode.NEAREST] = gl.NEAREST,
	[hood.FilterMode.LINEAR] = gl.LINEAR,
}

local compareFnsMap = {
	[hood.CompareFunction.NEVER] = gl.NEVER,
	[hood.CompareFunction.LESS] = gl.LESS,
	[hood.CompareFunction.EQUAL] = gl.EQUAL,
	[hood.CompareFunction.LESS_EQUAL] = gl.LESS_EQUAL,
	[hood.CompareFunction.GREATER] = gl.GREATER,
	[hood.CompareFunction.NOT_EQUAL] = gl.NOTEQUAL,
	[hood.CompareFunction.GREATER_EQUAL] = gl.GREATER_EQUAL,
	[hood.CompareFunction.ALWAYS] = gl.ALWAYS,
}

---@param desc hood.SamplerDescriptor
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
