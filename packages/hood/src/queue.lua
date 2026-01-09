---@class hood.Queue
---@field submit fun(self: hood.Queue, commandBuffer: hood.CommandBuffer)
---@field writeBuffer fun(self: hood.Queue, buffer: hood.Buffer, size: number, data: ffi.cdata*, offset: number?)
---@field writeTexture fun(self: hood.Queue, texture: hood.Texture, descriptor: hood.TextureWriteDescriptor, data: ffi.cdata*)
local Queue = require("hood.queue.gl") --[[@as hood.Queue]]

return Queue
