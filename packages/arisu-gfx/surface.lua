---@class gfx.SurfaceConfig

---@class gfx.Surface
---@field new fun(window: winit.Window): gfx.Surface
---@field configure fun(self: gfx.Surface, device: gfx.Device, config: gfx.SurfaceConfig): gfx.Swapchain
local Surface = require("arisu-gfx.surface.gl") --[[@as gfx.Surface]]

return Surface
