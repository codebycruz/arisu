---@class gfx.Swapchain
---@field present fun(self: gfx.Swapchain)
---@field getCurrentTexture fun(self: gfx.Swapchain): gfx.Texture
local Swapchain = require("arisu-gfx.swapchain.gl") --[[@as gfx.Swapchain]]

return Swapchain
