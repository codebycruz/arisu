local util = require("arisu-util")

---@class gfx.gl.Context
---@field fromHeadless fun(sharedCtx: gfx.gl.Context?): gfx.gl.Context
---@field fromWindow fun(window: winit.Window, sharedCtx: gfx.gl.Context?): gfx.gl.Context
---@field makeCurrent fun(self: gfx.gl.Context): boolean
---@field swapBuffers fun(self: gfx.gl.Context)
---@field destroy fun(self: gfx.gl.Context)
local Context = util.isWindows()
	and require("arisu-gfx.gl_context.win32")
	or require("arisu-gfx.gl_context.x11") --[[@as gfx.gl.Context]]

return Context
