local gl = require("arisu-opengl")

local Buffer = require("arisu-gfx.buffer")

---@class UniformBlock
---@field location number
---@field buffer gfx.gl.Buffer
local UniformBlock = {}
UniformBlock.__index = UniformBlock

---@param location number
function UniformBlock.new(location)
	local buffer = Buffer.new()
	return setmetatable({ buffer = buffer, location = location }, UniformBlock)
end

---@param type BufferDataType
---@param data table
function UniformBlock:set(type, data)
	gl.bindBufferBase(gl.UNIFORM_BUFFER, self.location, self.buffer.id)
	self.buffer:setData(type, data)
end

return UniformBlock
