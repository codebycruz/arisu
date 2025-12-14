local util = require("arisu-util")

local GLContext = require("arisu-gfx.gl_context")
local GLSwapchain = require("arisu-gfx.swapchain.gl")

---@class gfx.gl.Surface
---@field window winit.Window
local GLSurface = {}
GLSurface.__index = GLSurface

---@param window winit.win32.Window
function GLSurface.new(window)
	return setmetatable({ window = window }, GLSurface)
end

---@param device gfx.gl.Device
---@param config gfx.SurfaceConfig
function GLSurface:configure(device, config)
	local context = GLContext.fromWindow(self.window, device.globalContext)
	return GLSwapchain.new(context)
end

return GLSurface
