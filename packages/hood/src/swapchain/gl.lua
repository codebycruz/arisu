local GLTexture = require("hood.texture.gl")

---@class hood.gl.Swapchain
---@field ctx hood.gl.Context
local GLSwapchain = {}
GLSwapchain.__index = GLSwapchain

---@param ctx hood.gl.Context
function GLSwapchain.new(ctx)
	return setmetatable({ ctx = ctx }, GLSwapchain)
end

function GLSwapchain:getCurrentTexture()
	return GLTexture.forContextViewport(self.ctx)
end

function GLSwapchain:present()
	self.ctx:makeCurrent()
	self.ctx:swapBuffers()
end

return GLSwapchain
