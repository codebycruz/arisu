local GLCommandBuffer = require("arisu-gfx.command_buffer.gl")

---@alias gfx.gl.Command
---| { type: "beginRendering", descriptor: gfx.RenderPassDescriptor }
---| { type: "endRendering" }
---| { type: "setViewport", x: number, y: number, width: number, height: number }
---| { type: "setVertexBuffer", slot: number, buffer: gfx.Buffer, offset: number }
---| { type: "setIndexBuffer", buffer: gfx.Buffer, offset: number }
---| { type: "setBindGroup", index: number, bindGroup: gfx.BindGroup }
---| { type: "setPipeline", pipeline: gfx.Pipeline }
---| { type: "draw", vertexCount: number, instanceCount: number, firstVertex: number, firstInstance: number }

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
---@param buffer gfx.Buffer
---@param offset number
function GLCommandEncoder:setVertexBuffer(slot, buffer, offset)
	self.commands[#self.commands + 1] = { type = "setVertexBuffer", slot = slot, buffer = buffer, offset = offset }
end

---@param buffer gfx.Buffer
---@param offset number
function GLCommandEncoder:setIndexBuffer(buffer, offset)
	self.commands[#self.commands + 1] = { type = "setIndexBuffer", buffer = buffer, offset = offset }
end

---@param index number
---@param bindGroup gfx.BindGroup
function GLCommandEncoder:setBindGroup(index, bindGroup)
	self.commands[#self.commands + 1] = { type = "setBindGroup", index = index, bindGroup = bindGroup }
end

---@param pipeline gfx.Pipeline
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

function GLCommandEncoder:finish()
	return GLCommandBuffer.new(self.commands)
end

return GLCommandEncoder
