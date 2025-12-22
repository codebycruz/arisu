---@class gfx.Queue
---@field submit fun(self: gfx.Queue, commandBuffer: gfx.CommandBuffer)
---@field writeBuffer fun(self: gfx.Queue, buffer: gfx.Buffer, size: number, data: ffi.cdata*, offset: number?)
---@field writeTexture fun(self: gfx.Queue, texture: gfx.Texture, descriptor: gfx.TextureWriteDescriptor, data: ffi.cdata*)
local Queue = require("arisu-gfx.queue.gl") --[[@as gfx.Queue]]

return Queue
