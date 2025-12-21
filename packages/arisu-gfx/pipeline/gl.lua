local gl = require("arisu-opengl")
local ffi = require("ffi")

local GLProgram = require("arisu-gfx.gl_program")

---@class gfx.gl.Pipeline
---@field fragment gfx.FragmentState
---@field vertex gfx.VertexState
---@field depthStencil? gfx.DepthStencilState
local GLPipeline = {}
GLPipeline.__index = GLPipeline

---@param device gfx.gl.Device
---@param descriptor gfx.PipelineDescriptor
function GLPipeline.new(device, descriptor)
	if descriptor.vertex.module.type ~= "glsl" or descriptor.fragment.module.type ~= "glsl" then
		error("Only GLSL shaders are supported in the OpenGL backend.")
	end

	return setmetatable({
		fragment = descriptor.fragment,
		vertex = descriptor.vertex,
		depthStencil = descriptor.depthStencil
	}, GLPipeline)
end

---@class gfx.gl.RawPipeline
---@field id number
local GLRawPipeline = {}
GLRawPipeline.__index = GLRawPipeline

function GLRawPipeline.new(id)
	return setmetatable({ id = id }, GLRawPipeline)
end

--- GL Specific pipeline generation for the current context
--- This isn't done at pipeline creation time because contexts cannot share pipelines.
---@return gfx.gl.RawPipeline
function GLPipeline:genForCurrentContext()
	local pipeline = gl.genProgramPipelines(1)[1]

	do -- Vertex
		local program = GLProgram.new(gl.ShaderType.VERTEX, self.vertex.module.source)
		gl.useProgramStages(pipeline, gl.VERTEX_SHADER_BIT, program.id)
	end

	do -- Fragment
		local program = GLProgram.new(gl.ShaderType.FRAGMENT, self.fragment.module.source)
		gl.useProgramStages(pipeline, gl.FRAGMENT_SHADER_BIT, program.id)
	end

	return GLRawPipeline.new(pipeline)
end

function GLRawPipeline:bind()
	gl.bindProgramPipeline(self.id)
end

function GLRawPipeline:destroy()
	gl.deleteProgramPipelines(1, ffi.new("GLuint[1]", self.id))
end

function GLRawPipeline:__tostring()
	return "GLRawPipeline(" .. tostring(self.id) .. ")"
end

return GLPipeline
