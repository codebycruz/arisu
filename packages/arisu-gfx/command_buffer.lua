---@class gfx.CommandBuffer
local CommandBuffer = {}
CommandBuffer.__index = CommandBuffer

---@param commands gfx.Command[]
function CommandBuffer.new(commands)
	return setmetatable({ commands = commands }, CommandBuffer)
end

return CommandBuffer
