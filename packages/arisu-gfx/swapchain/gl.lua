local GLTexture = require("arisu-gfx.texture.gl")

---@class gfx.gl.Swapchain
---@field ctx gfx.gl.Context
local GLSwapchain = {}
GLSwapchain.__index = GLSwapchain

---@param ctx gfx.gl.Context
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
