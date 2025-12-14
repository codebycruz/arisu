local GLCommandBuffer = require("arisu-gfx.command_buffer.gl")

---@alias gfx.gl.Command
---| { type: "beginRendering", descriptor: gfx.RenderPassDescriptor }
---| { type: "endRendering" }
---| { type: "setViewport", x: number, y: number, width: number, height: number }
---| { type: "setVertexBuffer", slot: number, buffer: gfx.gl.Buffer, offset: number }
---| { type: "setIndexBuffer", buffer: gfx.gl.Buffer, offset: number }
---| { type: "setBindGroup", index: number, bindGroup: gfx.BindGroup }
---| { type: "setPipeline", pipeline: gfx.gl.Pipeline }
---| { type: "draw", vertexCount: number, instanceCount: number, firstVertex: number, firstInstance: number }
---| { type: "drawIndexed", indexCount: number, instanceCount: number, firstIndex: number, baseVertex: number, firstInstance: number }
---| { type: "writeBuffer", buffer: gfx.gl.Buffer, size: number, data: ffi.cdata*, offset: number }

---@class gfx.gl.Encoder
---@field commands gfx.gl.Command[]
local GLCommandEncoder = {}
GLCommandEncoder.__index = GLCommandEncoder

function GLCommandEncoder.new()
	return setmetatable({ commands = {} }, GLCommandEncoder)
end

function GLCommandEncoder:beginRendering(descriptor)
	self.commands[#self.commands + 1] = { type = "beginRendering", descriptor = descriptor }
end

function GLCommandEncoder:endRendering()
	self.commands[#self.commands + 1] = { type = "endRendering" }
end

---@param x number
---@param y number
---@param width number
---@param height number
function GLCommandEncoder:setViewport(x, y, width, height)
	self.commands[#self.commands + 1] = { type = "setViewport", x = x, y = y, width = width, height = height }
end

---@param slot number
---@param buffer gfx.gl.Buffer
---@param offset number?
function GLCommandEncoder:setVertexBuffer(slot, buffer, offset)
	self.commands[#self.commands + 1] = { type = "setVertexBuffer", slot = slot, buffer = buffer, offset = offset or 0 }
end

---@param buffer gfx.gl.Buffer
---@param offset number
function GLCommandEncoder:setIndexBuffer(buffer, offset)
	self.commands[#self.commands + 1] = { type = "setIndexBuffer", buffer = buffer, offset = offset or 0 }
end

---@param index number
---@param bindGroup gfx.BindGroup
function GLCommandEncoder:setBindGroup(index, bindGroup)
	self.commands[#self.commands + 1] = { type = "setBindGroup", index = index, bindGroup = bindGroup }
end

---@param pipeline gfx.gl.Pipeline
function GLCommandEncoder:setPipeline(pipeline)
	self.commands[#self.commands + 1] = { type = "setPipeline", pipeline = pipeline }
end

---@param vertexCount number
---@param instanceCount number
---@param firstVertex number?
---@param firstInstance number?
function GLCommandEncoder:draw(vertexCount, instanceCount, firstVertex, firstInstance)
	self.commands[#self.commands + 1] = {
		type = "draw",
		vertexCount = vertexCount,
		instanceCount = instanceCount,
		firstVertex = firstVertex or 0,
		firstInstance = firstInstance or 0
	}
end

---@param indexCount number
---@param instanceCount number
---@param firstIndex number?
---@param baseVertex number?
---@param firstInstance number?
function GLCommandEncoder:drawIndexed(indexCount, instanceCount, firstIndex, baseVertex, firstInstance)
	self.commands[#self.commands + 1] = {
		type = "drawIndexed",
		indexCount = indexCount,
		instanceCount = instanceCount,
		firstIndex = firstIndex or 0,
		baseVertex = baseVertex or 0,
		firstInstance = firstInstance or 0
	}
end

---@param buffer gfx.gl.Buffer
---@param size number
---@param data ffi.cdata*
---@param offset number?
function GLCommandEncoder:writeBuffer(buffer, size, data, offset)
	self.commands[#self.commands + 1] = {
		type = "writeBuffer",
		buffer = buffer,
		size = size,
		data = data,
		offset = offset or 0
	}
end

function GLCommandEncoder:finish()
	return GLCommandBuffer.new(self.commands)
end

return GLCommandEncoder
