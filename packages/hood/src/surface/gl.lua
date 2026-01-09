local util = require("arisu-util")

local GLContext = require("hood.gl_context")
local GLSwapchain = require("hood.swapchain.gl")

---@class hood.gl.Surface
---@field window winit.Window
local GLSurface = {}
GLSurface.__index = GLSurface

---@param window winit.win32.Window
function GLSurface.new(window)
	return setmetatable({ window = window }, GLSurface)
end

---@param device hood.gl.Device
---@param config hood.SurfaceConfig
function GLSurface:configure(device, config)
	local context = GLContext.fromWindow(self.window, device.ctx)
	return GLSwapchain.new(context)
end

return GLSurface
