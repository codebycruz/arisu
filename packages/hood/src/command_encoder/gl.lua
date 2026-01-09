local GLCommandBuffer = require("hood.command_buffer.gl")

---@alias hood.gl.Command
---| { type: "beginRendering", descriptor: hood.RenderPassDescriptor }
---| { type: "endRendering" }
---| { type: "setViewport", x: number, y: number, width: number, height: number }
---| { type: "setVertexBuffer", slot: number, buffer: hood.gl.Buffer, offset: number }
---| { type: "setIndexBuffer", buffer: hood.gl.Buffer, offset: number, format: hood.IndexFormat }
---| { type: "setBindGroup", index: number, bindGroup: hood.BindGroup }
---| { type: "setPipeline", pipeline: hood.gl.Pipeline }
---| { type: "draw", vertexCount: number, instanceCount: number, firstVertex: number, firstInstance: number }
---| { type: "drawIndexed", indexCount: number, instanceCount: number, firstIndex: number, baseVertex: number, firstInstance: number }
---| { type: "writeBuffer", buffer: hood.gl.Buffer, size: number, data: ffi.cdata*, offset: number }
---| { type: "writeTexture", texture: hood.gl.Texture, descriptor: hood.TextureWriteDescriptor, data: ffi.cdata* }
--- # Compute
---| { type: "beginComputePass", descriptor: hood.ComputePassDescriptor }
---| { type: "dispatchWorkgroups", x: number, y: number, z: number }
---| { type: "setComputePipeline", pipeline: hood.gl.ComputePipeline }

---@class hood.gl.Encoder
---@field commands hood.gl.Command[]
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
---@param buffer hood.gl.Buffer
---@param offset number?
function GLCommandEncoder:setVertexBuffer(slot, buffer, offset)
	self.commands[#self.commands + 1] = { type = "setVertexBuffer", slot = slot, buffer = buffer, offset = offset or 0 }
end

---@param buffer hood.gl.Buffer
---@param format hood.IndexFormat
---@param offset number?
function GLCommandEncoder:setIndexBuffer(buffer, format, offset)
	self.commands[#self.commands + 1] = { type = "setIndexBuffer", buffer = buffer, format = format, offset = offset or 0 }
end

---@param index number
---@param bindGroup hood.BindGroup
function GLCommandEncoder:setBindGroup(index, bindGroup)
	self.commands[#self.commands + 1] = { type = "setBindGroup", index = index, bindGroup = bindGroup }
end

---@param pipeline hood.gl.Pipeline
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
		firstInstance = firstInstance or 0,
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
		firstInstance = firstInstance or 0,
	}
end

---@param buffer hood.gl.Buffer
---@param size number
---@param data ffi.cdata*
---@param offset number?
function GLCommandEncoder:writeBuffer(buffer, size, data, offset)
	self.commands[#self.commands + 1] = {
		type = "writeBuffer",
		buffer = buffer,
		size = size,
		data = data,
		offset = offset or 0,
	}
end

---@param texture hood.gl.Texture
---@param descriptor hood.TextureWriteDescriptor
---@param data ffi.cdata*
function GLCommandEncoder:writeTexture(texture, descriptor, data)
	self.commands[#self.commands + 1] = {
		type = "writeTexture",
		texture = texture,
		descriptor = descriptor,
		data = data,
	}
end

--[[
	Compute Functions
]]

---@param descriptor hood.ComputePassDescriptor
function GLCommandEncoder:beginComputePass(descriptor)
	self.commands[#self.commands + 1] = { type = "beginComputePass", descriptor = descriptor }
end

---@param x number
---@param y number
---@param z number
function GLCommandEncoder:dispatchWorkgroups(x, y, z)
	self.commands[#self.commands + 1] = { type = "dispatchWorkgroups", x = x, y = y, z = z }
end

---@param pipeline hood.gl.ComputePipeline
function GLCommandEncoder:setComputePipeline(pipeline)
	self.commands[#self.commands + 1] = { type = "setComputePipeline", pipeline = pipeline }
end

function GLCommandEncoder:finish()
	return GLCommandBuffer.new(self.commands)
end

return GLCommandEncoder
