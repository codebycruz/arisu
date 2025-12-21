local gl = require("arisu-opengl")
local ffi = require("ffi")

---@class gfx.gl.Buffer
---@field id number
---@field isUniform boolean
---@field descriptor gfx.BufferDescriptor
local GLBuffer = {}
GLBuffer.__index = GLBuffer

---@param descriptor gfx.BufferDescriptor
function GLBuffer.new(descriptor)
	local handle = ffi.new("GLuint[1]")
	gl.createBuffers(1, handle)

	-- Allocate the buffer (might be necessary for setSlice to work)
	gl.namedBufferData(handle[0], descriptor.size, nil, gl.DYNAMIC_DRAW)

	local isUniform = false
	for _, usage in ipairs(descriptor.usages) do
		if usage == "UNIFORM" then
			isUniform = true
			break
		end
	end

	return setmetatable({ id = handle[0], isUniform = isUniform, descriptor = descriptor }, GLBuffer)
end

---@param size number
---@param data ffi.cdata*
---@param offset number?
function GLBuffer:setSlice(size, data, offset)
	gl.namedBufferSubData(self.id, offset or 0, size, data)
end

function GLBuffer:destroy()
	gl.deleteBuffers(1, ffi.new("GLuint[1]", self.id))
end

function GLBuffer:__tostring()
	if not gl.isBuffer(self.id) then
		return "GLBuffer(NULL)"
	end

	return "GLBuffer(" .. tostring(self.id) .. ")"
end

return GLBuffer
