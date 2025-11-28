local gl = require("bindings.gl")
local ffi = require("ffi")

---@class VAO
---@field id number
local VAO = {}
VAO.__index = VAO

function VAO.new()
	local handle = ffi.new("GLuint[1]")
	gl.createVertexArrays(1, handle)
	return setmetatable({ id = handle[0] }, VAO)
end

function VAO:bind()
	gl.bindVertexArray(self.id)
end

function VAO:unbind()
	gl.bindVertexArray(0)
end

---@param buffer Buffer
---@param descriptor BufferDescriptor
---@param bindingIndex number?
function VAO:setVertexBuffer(buffer, descriptor, bindingIndex)
	bindingIndex = bindingIndex or 0

	gl.vertexArrayVertexBuffer(self.id, bindingIndex, buffer.id, 0, descriptor:getStride())

	for i, attr in ipairs(descriptor.attributes) do
		local location = i - 1

		local glType
		local normalized = attr.normalized and 1 or 0

		if attr.type == "f32" then
			glType = gl.FLOAT
		elseif attr.type == "i32" then
			glType = gl.INT
		else
			error("Unsupported attribute type: " .. tostring(attr.type))
		end

		gl.enableVertexArrayAttrib(self.id, location)
		gl.vertexArrayAttribFormat(self.id, location, attr.size, glType, normalized, attr.offset)
		gl.vertexArrayAttribBinding(self.id, location, bindingIndex)
	end
end

---@param buffer Buffer
function VAO:setIndexBuffer(buffer)
	gl.vertexArrayElementBuffer(self.id, buffer.id)
end

function VAO:destroy()
	local handle = ffi.new("GLuint[1]", self.id)
	gl.deleteVertexArrays(1, handle)
	self.id = 0
end

return VAO
