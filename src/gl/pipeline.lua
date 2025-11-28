local gl = require "src.bindings.gl"
local ffi = require "ffi"

--- @class Pipeline
--- @field id number
--- @field stages table<ShaderType, Program>
local Pipeline = {}
Pipeline.__index = Pipeline

function Pipeline.new()
	local pipeline = gl.genProgramPipelines(1)[1]
	return setmetatable({ id = pipeline, stages = {} }, Pipeline)
end

---@param type ShaderType
---@param program Program
function Pipeline:setProgram(type, program)
	local stage = ({
		[gl.ShaderType.VERTEX] = gl.VERTEX_SHADER_BIT,
		[gl.ShaderType.FRAGMENT] = gl.FRAGMENT_SHADER_BIT,
		[gl.ShaderType.COMPUTE] = gl.COMPUTE_SHADER_BIT,
	})[type]

	self.stages[type] = program
	gl.useProgramStages(self.id, stage, program.id)
end

function Pipeline:bind()
	gl.bindProgramPipeline(self.id)
end

---@param x number
---@param y number
---@param z number
function Pipeline:dispatchCompute(x, y, z)
	gl.dispatchCompute(x, y, z)
end

function Pipeline:destroy()
	for _, program in pairs(self.stages) do
		program:destroy()
	end

	gl.deleteProgramPipelines(1, ffi.new("GLuint[1]", self.id))
end

return Pipeline
