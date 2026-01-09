local gl = require("arisu-opengl")
local ffi = require("ffi")

local GLProgram = require("hood.gl_program")

---@class hood.gl.ComputePipeline
---@field module hood.ShaderModule
local GLComputePipeline = {}
GLComputePipeline.__index = GLComputePipeline

---@param device hood.gl.Device
---@param descriptor hood.ComputePipelineDescriptor
function GLComputePipeline.new(device, descriptor)
	if descriptor.module.type ~= "glsl" then
		error("Only GLSL shaders are supported in the OpenGL backend.")
	end

	return setmetatable({ module = descriptor.module }, GLComputePipeline)
end

---@class hood.gl.RawComputePipeline
---@field id number
local GLRawComputePipeline = {}
GLRawComputePipeline.__index = GLRawComputePipeline

function GLRawComputePipeline.new(id)
	return setmetatable({ id = id }, GLRawComputePipeline)
end

--- GL Specific pipeline generation for the current context
--- This isn't done at pipeline creation time because contexts cannot share pipelines.
function GLComputePipeline:genForCurrentContext()
	local pipeline = gl.genProgramPipelines(1)[1]

	-- todo: destroy when pipeline is destroyed
	local program = GLProgram.new(gl.ShaderType.COMPUTE, self.module.source)
	gl.useProgramStages(pipeline, gl.COMPUTE_SHADER_BIT, program.id)

	return GLRawComputePipeline.new(pipeline)
end

function GLRawComputePipeline:bind()
	gl.bindProgramPipeline(self.id)
end

function GLRawComputePipeline:destroy()
	gl.deleteProgramPipelines(1, ffi.new("GLuint[1]", self.id))
end

function GLRawComputePipeline:__tostring()
	return "GLRawComputePipeline(" .. tostring(self.id) .. ")"
end

return GLComputePipeline
