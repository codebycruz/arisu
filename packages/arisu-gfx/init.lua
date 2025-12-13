local util = require("arisu-util")

---@alias PresentMode "immediate" | "vsync"

---@class gfx.Context
---@field new fun(window: winit.Window, sharedCtx: gfx.Context?): gfx.Context
---@field makeCurrent fun(self: gfx.Context): boolean
---@field swapBuffers fun(self: gfx.Context)
---@field destroy fun(self: gfx.Context)
local Context = util.isWindows()
	and require("arisu-gfx.context.win32")
	or require("arisu-gfx.context.x11") --[[@as gfx.Context]]

return Context
