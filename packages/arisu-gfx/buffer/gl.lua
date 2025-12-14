local gl = require("arisu-opengl")
local ffi = require("ffi")

---@class gfx.gl.Buffer
---@field id number
local GLBuffer = {}
GLBuffer.__index = GLBuffer

---@param descriptor gfx.BufferDescriptor
function GLBuffer.new(descriptor)
	local handle = ffi.new("GLuint[1]")
	gl.createBuffers(1, handle)
	return setmetatable({ id = handle[0], descriptor = descriptor }, GLBuffer)
end

---@param size number
---@param data ffi.cdata*
function GLBuffer:setData(size, data)
	gl.namedBufferData(self.id, size, data, 0x88E4)
end

---@param len number
---@param offset number
---@param data ffi.cdata*
function GLBuffer:setSlice(len, offset, data)
	gl.namedBufferSubData(self.id, offset, len, data)
end

return GLBuffer
