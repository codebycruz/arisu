local GLBuffer = require("arisu-gfx.buffer.gl")
local GLCommandEncoder = require("arisu-gfx.command_encoder.gl")
local GLContext = require("arisu-gfx.gl_context")
local GLQueue = require("arisu-gfx.queue.gl")
local GLPipeline = require("arisu-gfx.pipeline.gl")
local GLBindGroup = require("arisu-gfx.bind_group")
local GLSampler = require("arisu-gfx.sampler.gl")
local GLTexture = require("arisu-gfx.texture.gl")
local GLComputePipeline = require("arisu-gfx.compute_pipeline.gl")

---@class gfx.gl.Device
---@field public queue gfx.gl.Queue
---@field ctx gfx.gl.Context
local GLDevice = {}
GLDevice.__index = GLDevice

function GLDevice.new()
	local ctx = GLContext.fromHeadless()
	local queue = GLQueue.new(ctx)

	return setmetatable({ queue = queue, ctx = ctx }, GLDevice)
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
	self.ctx:makeCurrent()
	return GLPipeline.new(self, descriptor)
end

---@param entries gfx.BindGroupEntry[]
function GLDevice:createBindGroup(entries)
	self.ctx:makeCurrent()
	return GLBindGroup.new(entries)
end

---@param descriptor gfx.SamplerDescriptor
function GLDevice:createSampler(descriptor)
	self.ctx:makeCurrent()
	return GLSampler.new(descriptor)
end

---@param descriptor gfx.TextureDescriptor
function GLDevice:createTexture(descriptor)
	self.ctx:makeCurrent()
	return GLTexture.new(self, descriptor)
end

---@param descriptor gfx.ComputePipelineDescriptor
function GLDevice:createComputePipeline(descriptor)
	self.ctx:makeCurrent()
	return GLComputePipeline.new(self, descriptor)
end

return GLDevice
