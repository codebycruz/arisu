---@class gfx.AdapterConfig
---@field powerPreference? "low-power" | "high-performance"

---@class gfx.Adapter
---@field requestDevice fun(self: gfx.Adapter): gfx.Device
local Adapter = require("arisu-gfx.adapter.gl") --[[@as gfx.Adapter]]

return Adapter
