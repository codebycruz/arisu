local GLBuffer = require("arisu-gfx.buffer.gl")
local GLCommandEncoder = require("arisu-gfx.command_encoder.gl")
local GLContext = require("arisu-gfx.gl_context")
local GLQueue = require("arisu-gfx.queue.gl")

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
	-- todo: enable this when vaos dont exist
	-- self.ctx:makeCurrent()
	return GLBuffer.new(descriptor)
end

function GLDevice:createCommandEncoder()
	return GLCommandEncoder.new()
end

---@param buffer gfx.gl.CommandBuffer
function GLDevice:submit(buffer)
	buffer:execute()
end

return GLDevice
