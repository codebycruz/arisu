local gl = require "src.bindings.gl"
local ffi = require("ffi")

---@alias UniformType "int" | "float" | "vec2" | "vec3" | "vec4" | "mat4" | "sampler2D"

---@class Uniform
---@field id number
---@field type UniformType
local Uniform = {}
Uniform.__index = Uniform

---@param type UniformType
---@param id number
function Uniform.new(type, id)
    return setmetatable({ type = type, id = id }, Uniform)
end

local matBuffer = ffi.new("float[16]")
function Uniform:set(value)
    if self.type == "int" then
        gl.uniform1i(self.id, value)
    elseif self.type == "float" then
        gl.uniform1f(self.id, value)
    elseif self.type == "vec2" then
        gl.uniform2f(self.id, value[1], value[2])
    elseif self.type == "vec3" then
        gl.uniform3f(self.id, value[1], value[2], value[3])
    elseif self.type == "vec4" then
        gl.uniform4f(self.id, value[1], value[2], value[3], value[4])
    elseif self.type == "mat4" then
        ffi.copy(matBuffer, value, 16 * ffi.sizeof("float"))
        gl.uniformMatrix4fv(self.id, 1, gl.GL_FALSE, matBuffer)
    elseif self.type == "sampler2D" then
        gl.uniform1i(self.id, value)
    else
        error("Unsupported uniform type: " .. tostring(self.type))
    end
end

return Uniform
