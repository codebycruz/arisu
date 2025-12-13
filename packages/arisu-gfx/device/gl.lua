local GLBuffer = require("arisu-gfx.buffer.gl")

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

return GLDevice
