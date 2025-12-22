local GLCommandEncoder = require("arisu-gfx.command_encoder.gl")

---@class gfx.gl.Queue
---@field private ctx gfx.gl.Context # The headless GL context
local GLQueue = {}
GLQueue.__index = GLQueue

---@param ctx gfx.gl.Context
function GLQueue.new(ctx)
	return setmetatable({ ctx = ctx }, GLQueue)
end

---@param buffer gfx.gl.CommandBuffer
function GLQueue:submit(buffer)
	self.ctx:makeCurrent()
	buffer:execute()
end

--- Helper method to write data to a buffer
---@param buffer gfx.gl.Buffer
---@param size number
---@param data ffi.cdata*
---@param offset number?
function GLQueue:writeBuffer(buffer, size, data, offset)
	local cmd = GLCommandEncoder.new()
	cmd:writeBuffer(buffer, size, data, offset)
	self:submit(cmd:finish())
end

--- Helper method to write data to a texture
---@param texture gfx.gl.Texture
---@param descriptor gfx.TextureWriteDescriptor
---@param data ffi.cdata*
function GLQueue:writeTexture(texture, descriptor, data)
	local cmd = GLCommandEncoder.new()
	cmd:writeTexture(texture, descriptor, data)
	self:submit(cmd:finish())
end

return GLQueue
