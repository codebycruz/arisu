local gl = require("arisu-opengl")
local ffi = require("ffi")

--- @class gfx.gl.GLPipeline
--- @field id number
--- @field stages table<gl.ShaderType, gfx.gl.Program>
local GLPipeline = {}
GLPipeline.__index = GLPipeline

function GLPipeline.new()
	local pipeline = gl.genProgramPipelines(1)[1]
	return setmetatable({ id = pipeline, stages = {} }, GLPipeline)
end

---@param type gl.ShaderType
---@param program gfx.gl.Program
function GLPipeline:setProgram(type, program)
	local stage = ({
		[gl.ShaderType.VERTEX] = gl.VERTEX_SHADER_BIT,
		[gl.ShaderType.FRAGMENT] = gl.FRAGMENT_SHADER_BIT,
		[gl.ShaderType.COMPUTE] = gl.COMPUTE_SHADER_BIT,
	})[type]

	self.stages[type] = program
	gl.useProgramStages(self.id, stage, program.id)
end

function GLPipeline:bind()
	gl.bindProgramPipeline(self.id)
end

---@param x number
---@param y number
---@param z number
function GLPipeline:dispatchCompute(x, y, z)
	gl.dispatchCompute(x, y, z)
end

function GLPipeline:destroy()
	for _, program in pairs(self.stages) do
		program:destroy()
	end

	gl.deleteProgramPipelines(1, ffi.new("GLuint[1]", self.id))
end

return GLPipeline
