local GLCommandEncoder = require("arisu-gfx.command_encoder.gl")

---@class gfx.gl.Queue
local GLQueue = {}
GLQueue.__index = GLQueue

function GLQueue.new()
	return setmetatable({}, GLQueue)
end

---@param buffer gfx.gl.CommandBuffer
function GLQueue:submit(buffer)
	buffer:execute()
end

--- Helper method to write data to a buffer
---@param buffer gfx.Buffer
---@param size number
---@param data ffi.cdata*
---@param offset number?
function GLQueue:writeBuffer(buffer, size, data, offset)
	local cmd = GLCommandEncoder.new()
	cmd:writeBuffer(buffer, size, data, offset)
	self:submit(cmd:finish())
end

return GLQueue
