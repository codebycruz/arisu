local gl = require("arisu-opengl")
local ffi = require("ffi")

local GLProgram = require("arisu-gfx.gl_program")

---@class gfx.gl.Pipeline
---@field private id number
---@field fragment gfx.FragmentState
---@field vertex gfx.VertexState
---@field depthStencil? gfx.DepthStencilState
local GLPipeline = {}
GLPipeline.__index = GLPipeline

---@param device gfx.gl.Device
---@param descriptor gfx.PipelineDescriptor
function GLPipeline.new(device, descriptor)
	local pipeline = gl.genProgramPipelines(1)[1]

	if descriptor.vertex.module.type == "glsl" then
		local program = GLProgram.new(gl.ShaderType.VERTEX, descriptor.vertex.module.source)
		local stage = gl.VERTEX_SHADER_BIT

		gl.useProgramStages(pipeline, stage, program.id)
	end

	if descriptor.fragment.module.type == "glsl" then
		local program = GLProgram.new(gl.ShaderType.FRAGMENT, descriptor.fragment.module.source)
		local stage = gl.FRAGMENT_SHADER_BIT

		gl.useProgramStages(pipeline, stage, program.id)
	end

	return setmetatable({
		id = pipeline,
		fragment = descriptor.fragment,
		vertex = descriptor.vertex,
		depthStencil = descriptor.depthStencil
	}, GLPipeline)
end

function GLPipeline:bind()
	gl.bindProgramPipeline(self.id)
end

function GLPipeline:destroy()
	gl.deleteProgramPipelines(1, ffi.new("GLuint[1]", self.id))
end

return GLPipeline
