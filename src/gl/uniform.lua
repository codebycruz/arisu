local gl = require("bindings.gl")
local ffi = require("ffi")

---@alias UniformType "int" | "float" | "vec2" | "ivec2" | "vec3" | "vec4" | "mat4" | "sampler2D" | "sampler2DArray"

---@class Uniform
---@field id number
---@field program Program
---@field type UniformType
local Uniform = {}
Uniform.__index = Uniform

---@param program Program
---@param type UniformType
---@param id number
function Uniform.new(program, type, id)
	return setmetatable({ program = program, type = type, id = id }, Uniform)
end

local matBuffer = ffi.new("float[16]")
function Uniform:set(value)
	if self.type == "int" then
		gl.programUniform1i(self.program.id, self.id, value)
	elseif self.type == "float" then
		gl.programUniform1f(self.program.id, self.id, value)
	elseif self.type == "vec2" then
		gl.programUniform2f(self.program.id, self.id, value[1], value[2])
	elseif self.type == "ivec2" then
		gl.programUniform2i(self.program.id, self.id, value[1], value[2])
	elseif self.type == "vec3" then
		gl.programUniform3f(self.program.id, self.id, value[1], value[2], value[3])
	elseif self.type == "vec4" then
		gl.programUniform4f(self.program.id, self.id, value[1], value[2], value[3], value[4])
	elseif self.type == "mat4" then
		ffi.copy(matBuffer, value, 16 * ffi.sizeof("float"))
		gl.programUniformMatrix4fv(self.program.id, self.id, 1, gl.GL_FALSE, matBuffer)
	elseif self.type == "sampler2D" then
		gl.programUniform1i(self.program.id, self.id, value)
	elseif self.type == "sampler2DArray" then
		gl.programUniform1i(self.program.id, self.id, value)
	else
		error("Unsupported uniform type: " .. tostring(self.type))
	end
end

return Uniform
