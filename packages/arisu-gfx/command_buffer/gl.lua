---@class gfx.gl.CommandBuffer
local GLCommandBuffer = {}
GLCommandBuffer.__index = GLCommandBuffer

---@param commands gfx.gl.Command[]
function GLCommandBuffer.new(commands)
	return setmetatable({ commands = commands }, GLCommandBuffer)
end

function GLCommandBuffer:execute()
end

return GLCommandBuffer
