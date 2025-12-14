---@class gfx.Device
---@field createBuffer fun(self: gfx.Device, descriptor: gfx.BufferDescriptor): gfx.Buffer
---@field createCommandEncoder fun(self: gfx.Device): gfx.Encoder
local Device = require("arisu-gfx.device.gl") --[[@as gfx.Device]]

return Device
