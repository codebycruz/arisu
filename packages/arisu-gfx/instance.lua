---@class gfx.Instance
---@field new fun(): gfx.Instance
---@field requestAdapter fun(self: gfx.Instance, options: gfx.AdapterOptions?): gfx.Adapter
local Instance = require("arisu-gfx.instance.gl") --[[@as gfx.Instance]]

return Instance
