---@alias gfx.EncoderCommand
---| { type: "clear", color: gfx.Color }

---@class gfx.Encoder
---@field finish fun(self: gfx.Encoder): gfx.EncoderCommand[]
---@field clear fun(self: gfx.Encoder, color: gfx.Color)
local Encoder = require("arisu-gfx.encoder.gl") --[[@as gfx.Encoder]]

return Encoder
