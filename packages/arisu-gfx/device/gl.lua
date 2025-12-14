local GLBuffer = require("arisu-gfx.buffer.gl")
local GLCommandEncoder = require("arisu-gfx.command_encoder.gl")
local GLContext = require("arisu-gfx.gl_context")
local GLQueue = require("arisu-gfx.queue.gl")
local GLPipeline = require("arisu-gfx.pipeline.gl")
local GLBindGroup = require("arisu-gfx.bind_group")

---@class gfx.gl.Device
---@field public queue gfx.gl.Queue
---@field private ctx gfx.gl.Context
local GLDevice = {}
GLDevice.__index = GLDevice

function GLDevice.new()
	local context = GLContext.fromHeadless()
	local queue = GLQueue.new()

	return setmetatable({ queue = queue, ctx = context }, GLDevice)
end

---@param descriptor gfx.BufferDescriptor
function GLDevice:createBuffer(descriptor)
	self.ctx:makeCurrent()
	return GLBuffer.new(descriptor)
end

function GLDevice:createCommandEncoder()
	return GLCommandEncoder.new()
end

---@param descriptor gfx.PipelineDescriptor
function GLDevice:createPipeline(descriptor)
	return GLPipeline.new(self, descriptor)
end

---@param buffer gfx.gl.CommandBuffer
function GLDevice:submit(buffer)
	buffer:execute()
end

---@param entries gfx.BindGroupEntry[]
function GLDevice:createBindGroup(entries)
	return GLBindGroup.new(entries)
end

return GLDevice
