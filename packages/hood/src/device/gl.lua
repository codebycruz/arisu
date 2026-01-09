local GLBuffer = require("hood.buffer.gl")
local GLCommandEncoder = require("hood.command_encoder.gl")
local GLContext = require("hood.gl_context")
local GLQueue = require("hood.queue.gl")
local GLPipeline = require("hood.pipeline.gl")
local GLBindGroup = require("hood.bind_group")
local GLSampler = require("hood.sampler.gl")
local GLTexture = require("hood.texture.gl")
local GLComputePipeline = require("hood.compute_pipeline.gl")

---@class hood.gl.Device
---@field public queue hood.gl.Queue
---@field ctx hood.gl.Context
local GLDevice = {}
GLDevice.__index = GLDevice

function GLDevice.new()
	local ctx = GLContext.fromHeadless()
	local queue = GLQueue.new(ctx)

	return setmetatable({ queue = queue, ctx = ctx }, GLDevice)
end

---@param descriptor hood.BufferDescriptor
function GLDevice:createBuffer(descriptor)
	self.ctx:makeCurrent()
	return GLBuffer.new(descriptor)
end

function GLDevice:createCommandEncoder()
	return GLCommandEncoder.new()
end

---@param descriptor hood.PipelineDescriptor
function GLDevice:createPipeline(descriptor)
	self.ctx:makeCurrent()
	return GLPipeline.new(self, descriptor)
end

---@param entries hood.BindGroupEntry[]
function GLDevice:createBindGroup(entries)
	self.ctx:makeCurrent()
	return GLBindGroup.new(entries)
end

---@param descriptor hood.SamplerDescriptor
function GLDevice:createSampler(descriptor)
	self.ctx:makeCurrent()
	return GLSampler.new(descriptor)
end

---@param descriptor hood.TextureDescriptor
function GLDevice:createTexture(descriptor)
	self.ctx:makeCurrent()
	return GLTexture.new(self, descriptor)
end

---@param descriptor hood.ComputePipelineDescriptor
function GLDevice:createComputePipeline(descriptor)
	self.ctx:makeCurrent()
	return GLComputePipeline.new(self, descriptor)
end

return GLDevice
