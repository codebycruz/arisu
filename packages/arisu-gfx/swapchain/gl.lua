local gl = require("arisu-opengl")

---@class gfx.gl.Swapchain
---@field ctx gfx.gl.Context
local GLSwapchain = {}

---@param ctx gfx.gl.Context
function GLSwapchain.new(ctx)
	return setmetatable({ ctx = ctx }, GLSwapchain)
end

function GLSwapchain:present()
	self.ctx:swapBuffers()
end

return GLSwapchain
