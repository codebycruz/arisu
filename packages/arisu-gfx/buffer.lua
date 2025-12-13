---@alias gfx.BufferDataType "u32" | "f32"

---@class gfx.Buffer
---@field new fun(): gfx.Buffer
---@field setData fun(self: gfx.Buffer, type: gfx.BufferDataType, data: number[])
---@field setSlice fun(self: gfx.Buffer, type: gfx.BufferDataType, offset: number, data: number[])
local Buffer = require("arisu-gfx.buffer.gl") --[[@as gfx.Buffer]]

return Buffer
