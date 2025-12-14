---@class gfx.Queue
---@field submit fun(self: gfx.Queue, commandBuffer: gfx.CommandBuffer)
---@field writeBuffer fun(self: gfx.Queue, buffer: gfx.Buffer, size: number, data: ffi.cdata*, offset: number?)
local Queue = require("arisu-gfx.queue.gl") --[[@as gfx.Queue]]

return Queue
