local GLCommandEncoder = require("hood.command_encoder.gl")

---@class hood.gl.Queue
---@field private ctx hood.gl.Context # The headless GL context
local GLQueue = {}
GLQueue.__index = GLQueue

---@param ctx hood.gl.Context
function GLQueue.new(ctx)
	return setmetatable({ ctx = ctx }, GLQueue)
end

---@param buffer hood.gl.CommandBuffer
function GLQueue:submit(buffer)
	self.ctx:makeCurrent()
	buffer:execute()
end

--- Helper method to write data to a buffer
---@param buffer hood.gl.Buffer
---@param size number
---@param data ffi.cdata*
---@param offset number?
function GLQueue:writeBuffer(buffer, size, data, offset)
	local cmd = GLCommandEncoder.new()
	cmd:writeBuffer(buffer, size, data, offset)
	self:submit(cmd:finish())
end

--- Helper method to write data to a texture
---@param texture hood.gl.Texture
---@param descriptor hood.TextureWriteDescriptor
---@param data ffi.cdata*
function GLQueue:writeTexture(texture, descriptor, data)
	local cmd = GLCommandEncoder.new()
	cmd:writeTexture(texture, descriptor, data)
	self:submit(cmd:finish())
end

return GLQueue
