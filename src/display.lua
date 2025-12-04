local util = require("util")

---@class Display
---@field new fun(): Display
local Display = util.isWindows() and require("display.win32") or require("display.x11")

return Display
