local gl = require("arisu-opengl")
local ffi = require("ffi")

---@class gfx.gl.Buffer
---@field id number
local GLBuffer = {}
GLBuffer.__index = GLBuffer

function GLBuffer.new()
	local handle = ffi.new("GLuint[1]")
	gl.createBuffers(1, handle)
	return setmetatable({ id = handle[0] }, GLBuffer)
end

---@alias BufferDataType "u32" | "f32"

local typeSizes = {
	u32 = ffi.sizeof("uint32_t"),
	f32 = ffi.sizeof("float"),
}

local typeConstructors = {
	u32 = function(data)
		local arr = ffi.new("uint32_t[?]", #data)
		for i = 1, #data do
			arr[i - 1] = data[i]
		end
		return arr
	end,
	f32 = function(data)
		local arr = ffi.new("float[?]", #data)
		for i = 1, #data do
			arr[i - 1] = data[i]
		end
		return arr
	end,
}

---@param type BufferDataType
---@param data table?
function GLBuffer:setData(type, data)
	local constructor = assert(typeConstructors[type], "Invalid buffer data type: " .. tostring(type))
	gl.namedBufferData(self.id, #data * typeSizes[type], constructor(data), 0x88E4)
end

---@param type BufferDataType
---@param offset number
---@param data table
function GLBuffer:setSlice(type, offset, data)
	local constructor = assert(typeConstructors[type], "Invalid buffer data type: " .. tostring(type))
	gl.namedBufferSubData(self.id, offset, #data * typeSizes[type], constructor(data))
end

return GLBuffer
