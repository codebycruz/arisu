local glx = require("arisu-x11.glx")
local x11 = require("arisu-x11.x11")
local gl = require("arisu-opengl")

--- @class X11Context
--- @field display XDisplay
--- @field window winit.Window
--- @field ctx userdata
local X11Context = {}
X11Context.__index = X11Context

---@param window X11Window
---@param sharedCtx X11Context?
function X11Context.new(window, sharedCtx)
	local display = window.display
	local screen = x11.defaultScreen(display)

	local fbConfig = glx.chooseFBConfig(display, screen, {
		glx.RENDER_TYPE,
		glx.RGBA_BIT,
		glx.DRAWABLE_TYPE,
		glx.WINDOW_BIT,
		glx.DOUBLEBUFFER,
		1,
		glx.DEPTH_SIZE,
		24,
	})
	if not fbConfig then
		error("Failed to choose FBConfig")
	end

	local ctx = glx.createContextAttribsARB(display, fbConfig, sharedCtx and sharedCtx.ctx, 1, {
		glx.CONTEXT_MAJOR_VERSION_ARB,
		3,
		glx.CONTEXT_MINOR_VERSION_ARB,
		3,
	})
	if not ctx then
		error("Failed to create GLX context with attributes")
	end

	return setmetatable({ ctx = ctx, display = display, window = window }, X11Context)
end

---@return boolean # true on success, false on failure
function X11Context:makeCurrent()
	return glx.makeCurrent(self.display, self.window.id, self.ctx) ~= 0
end

function X11Context:swapBuffers()
	glx.swapBuffers(self.display, self.window.id)
end

function X11Context:destroy()
	glx.destroyContext(self.display, self.ctx)
end

return X11Context
