---@class hood.Instance
---@field new fun(): hood.Instance
---@field requestAdapter fun(self: hood.Instance, options: hood.AdapterConfig?): hood.Adapter
---@field createSurface fun(self: hood.Instance, window: winit.Window)
local Instance = require("hood.instance.gl") --[[@as hood.Instance]]

return Instance
