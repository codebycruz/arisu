local gl = require("hood-opengl")

---@class hood.gl.Program
---@field id number
local Program = {}
Program.__index = Program

---@param type gl.ShaderType
---@param src string
function Program.new(type, src)
	local id = gl.createShaderProgram(type, src)
	return setmetatable({ id = id }, Program)
end

function Program:destroy()
	gl.deleteProgram(self.id)
end

return Program
