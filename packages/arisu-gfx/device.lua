---@class gfx.Device
---@field createBuffer fun(self: gfx.Device, descriptor: gfx.BufferDescriptor): gfx.Buffer
local Device = require("arisu-gfx.device.gl") --[[@as gfx.Device]]

return Device
