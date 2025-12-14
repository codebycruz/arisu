local GLBuffer = require("arisu-gfx.buffer.gl")
local GLEncoder = require("arisu-gfx.encoder.gl")

---@class gfx.gl.Device
local GLDevice = {}
GLDevice.__index = GLDevice

function GLDevice.new()
	return setmetatable({}, GLDevice)
end

---@param descriptor gfx.BufferDescriptor
function GLDevice:createBuffer(descriptor)
	return GLBuffer.new(descriptor)
end

function GLDevice:createCommandEncoder()
	return GLEncoder.new()
end

return GLDevice
