local GLCommandBuffer = require("arisu-gfx.command_buffer.gl")

---@alias gfx.gl.Command
---| { type: "beginRendering", descriptor: gfx.RenderPassDescriptor }
---| { type: "endRendering" }
---| { type: "setViewport", x: number, y: number, width: number, height: number }
---| { type: "setVertexBuffer", slot: number, buffer: gfx.gl.Buffer, offset: number }
---| { type: "setIndexBuffer", buffer: gfx.gl.Buffer, offset: number, format: gfx.IndexFormat }
---| { type: "setBindGroup", index: number, bindGroup: gfx.BindGroup }
---| { type: "setPipeline", pipeline: gfx.gl.Pipeline }
---| { type: "draw", vertexCount: number, instanceCount: number, firstVertex: number, firstInstance: number }
---| { type: "drawIndexed", indexCount: number, instanceCount: number, firstIndex: number, baseVertex: number, firstInstance: number }
---| { type: "writeBuffer", buffer: gfx.gl.Buffer, size: number, data: ffi.cdata*, offset: number }
---| { type: "writeTexture", texture: gfx.gl.Texture, descriptor: gfx.TextureWriteDescriptor, data: ffi.cdata* }
--- # Compute
---| { type: "beginComputePass", descriptor: gfx.ComputePassDescriptor }
---| { type: "dispatchWorkgroups", x: number, y: number, z: number }
---| { type: "setComputePipeline", pipeline: gfx.gl.ComputePipeline }

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
---@param format gfx.IndexFormat
---@param offset number?
function GLCommandEncoder:setIndexBuffer(buffer, format, offset)
	self.commands[#self.commands + 1] = { type = "setIndexBuffer", buffer = buffer, format = format, offset = offset or 0 }
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

---@param texture gfx.gl.Texture
---@param descriptor gfx.TextureWriteDescriptor
---@param data ffi.cdata*
function GLCommandEncoder:writeTexture(texture, descriptor, data)
	self.commands[#self.commands + 1] = {
		type = "writeTexture",
		texture = texture,
		descriptor = descriptor,
		data = data
	}
end

--[[
	Compute Functions
]]

---@param descriptor gfx.ComputePassDescriptor
function GLCommandEncoder:beginComputePass(descriptor)
	self.commands[#self.commands + 1] = { type = "beginComputePass", descriptor = descriptor }
end

---@param x number
---@param y number
---@param z number
function GLCommandEncoder:dispatchWorkgroups(x, y, z)
	self.commands[#self.commands + 1] = { type = "dispatchWorkgroups", x = x, y = y, z = z }
end

---@param pipeline gfx.gl.ComputePipeline
function GLCommandEncoder:setComputePipeline(pipeline)
	self.commands[#self.commands + 1] = { type = "setComputePipeline", pipeline = pipeline }
end

function GLCommandEncoder:finish()
	return GLCommandBuffer.new(self.commands)
end

return GLCommandEncoder
