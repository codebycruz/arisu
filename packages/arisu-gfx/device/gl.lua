local GLBuffer = require("arisu-gfx.buffer.gl")
local GLCommandEncoder = require("arisu-gfx.command_encoder.gl")
local GLContext = require("arisu-gfx.gl_context")
local GLQueue = require("arisu-gfx.queue.gl")
local GLPipeline = require("arisu-gfx.pipeline.gl")
local GLBindGroup = require("arisu-gfx.bind_group")
local GLSampler = require("arisu-gfx.sampler.gl")
local GLTexture = require("arisu-gfx.texture.gl")

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

---@param desc gfx.SamplerDescriptor
function GLDevice:createSampler(desc)
	self.ctx:makeCurrent()
	return GLSampler.new(desc)
end

---@param desc gfx.TextureDescriptor
function GLDevice:createTexture(desc)
	self.ctx:makeCurrent()
	return GLTexture.new(self, desc)
end

return GLDevice
