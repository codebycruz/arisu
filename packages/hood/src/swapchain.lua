---@class hood.Swapchain
---@field present fun(self: hood.Swapchain)
---@field getCurrentTexture fun(self: hood.Swapchain): hood.Texture
local Swapchain = require("hood.swapchain.gl") --[[@as hood.Swapchain]]

return Swapchain
