local GLBuffer = require("arisu-gfx.buffer.gl")
local GLEncoder = require("arisu-gfx.encoder.gl")
local GLContext = require("arisu-gfx.gl_context")

---@class gfx.gl.Device
---@field globalContext gfx.gl.Context
local GLDevice = {}
GLDevice.__index = GLDevice

function GLDevice.new()
	local context = GLContext.fromHeadless()
	return setmetatable({ globalContext = context }, GLDevice)
end

---@param descriptor gfx.BufferDescriptor
function GLDevice:createBuffer(descriptor)
	-- todo: enable this when vaos dont exist
	-- self.globalContext:makeCurrent()
	return GLBuffer.new(descriptor)
end

function GLDevice:createCommandEncoder()
	return GLEncoder.new()
end

return GLDevice
