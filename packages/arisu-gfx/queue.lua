---@class gfx.Queue
---@field submit fun(self: gfx.Queue, commandBuffer: gfx.gl.CommandBuffer)
local Queue = require("arisu-gfx.queue.gl") --[[@as gfx.Queue]]

return Queue
