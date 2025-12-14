---@class gfx.Device
---@field queue gfx.Queue
---@field createPipeline fun(self: gfx.Device, descriptor: gfx.PipelineDescriptor): gfx.Pipeline
---@field createBuffer fun(self: gfx.Device, descriptor: gfx.BufferDescriptor): gfx.Buffer
---@field createCommandEncoder fun(self: gfx.Device): gfx.CommandEncoder
---@field createBindGroup fun(self: gfx.Device, entries: gfx.BindGroupEntry[]): gfx.BindGroup
local Device = require("arisu-gfx.device.gl") --[[@as gfx.Device]]

return Device
