local util = require("arisu-util")

---@class gfx.gl.Surface
---@field context gfx.Context
local GLSurface = {}
GLSurface.__index = GLSurface

---@class gfx.Context
---@field new fun(window: winit.Window, sharedCtx: gfx.Context?): gfx.Context
---@field makeCurrent fun(self: gfx.Context): boolean
---@field swapBuffers fun(self: gfx.Context)
---@field destroy fun(self: gfx.Context)
local Context = util.isWindows()
	and require("arisu-gfx.surface.gl.win32")
	or require("arisu-gfx.surface.gl.x11") --[[@as gfx.Context]]

---@param window winit.win32.Window
function GLSurface.new(window)
	local context = Context.new(window, nil)
	return setmetatable({ context = context, window = window }, GLSurface)
end

return GLSurface
