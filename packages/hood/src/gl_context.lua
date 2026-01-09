local util = require("arisu-util")

---@class hood.gl.Context
---@field fromHeadless fun(sharedCtx: hood.gl.Context?): hood.gl.Context
---@field fromWindow fun(window: winit.Window, sharedCtx: hood.gl.Context?): hood.gl.Context
---@field makeCurrent fun(self: hood.gl.Context): boolean
---@field swapBuffers fun(self: hood.gl.Context)
---@field destroy fun(self: hood.gl.Context)
local Context = util.isWindows() and require("hood.gl_context.win32") or require("hood.gl_context.x11") --[[@as hood.gl.Context]]

return Context
