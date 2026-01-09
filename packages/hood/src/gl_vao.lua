local gl = require("arisu-opengl")
local ffi = require("ffi")

---@class hood.gl.VAO
---@field id number
local GLVAO = {}
GLVAO.__index = GLVAO

function GLVAO.new()
	local handle = ffi.new("GLuint[1]")
	gl.createVertexArrays(1, handle)
	return setmetatable({ id = handle[0] }, GLVAO)
end

function GLVAO:bind()
	gl.bindVertexArray(self.id)
end

function GLVAO:unbind()
	gl.bindVertexArray(0)
end

---@param buffer hood.gl.Buffer
---@param descriptor hood.VertexLayout
---@param bindingIndex number?
function GLVAO:setVertexBuffer(buffer, descriptor, bindingIndex)
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

---@param buffer hood.gl.Buffer
function GLVAO:setIndexBuffer(buffer)
	gl.vertexArrayElementBuffer(self.id, buffer.id)
end

function GLVAO:destroy()
	local handle = ffi.new("GLuint[1]", self.id)
	gl.deleteVertexArrays(1, handle)
	self.id = 0
end

function GLVAO:__tostring()
	if not gl.isVertexArray(self.id) then
		return "GLVAO(NULL)"
	end

	return "GLVAO(" .. tostring(self.id) .. ")"
end

return GLVAO
