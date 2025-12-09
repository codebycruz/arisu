local util = require("util")

---@alias PresentMode "immediate" | "vsync"

---@class Context
---@field new fun(window: Window, sharedCtx: Context?): Context
---@field makeCurrent fun(self: Context): boolean
---@field setPresentMode fun(self: Context, mode: PresentMode)
---@field swapBuffers fun(self: Context)
---@field destroy fun(self: Context)
local Context = util.isWindows() and require("context.win32") or require("context.x11") --[[@as Context]]

return Context
