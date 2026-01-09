---@class hood.Device
---@field queue hood.Queue
---@field createPipeline fun(self: hood.Device, descriptor: hood.PipelineDescriptor): hood.Pipeline
---@field createBuffer fun(self: hood.Device, descriptor: hood.BufferDescriptor): hood.Buffer
---@field createCommandEncoder fun(self: hood.Device): hood.CommandEncoder
---@field createBindGroup fun(self: hood.Device, entries: hood.BindGroupEntry[]): hood.BindGroup
---@field createSampler fun(self: hood.Device, descriptor: hood.SamplerDescriptor): hood.Sampler
---@field createTexture fun(self: hood.Device, descriptor: hood.TextureDescriptor): hood.Texture
---@field createComputePipeline fun(self: hood.Device, descriptor: hood.ComputePipelineDescriptor): hood.ComputePipeline
local Device = require("hood.device.gl") --[[@as hood.Device]]

return Device
