---@class hood.SurfaceConfig

---@class hood.Surface
---@field new fun(window: winit.Window): hood.Surface
---@field configure fun(self: hood.Surface, device: hood.Device, config: hood.SurfaceConfig): hood.Swapchain
local Surface = require("hood.surface.gl") --[[@as hood.Surface]]

return Surface
