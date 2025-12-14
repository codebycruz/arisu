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

return GLQueue
