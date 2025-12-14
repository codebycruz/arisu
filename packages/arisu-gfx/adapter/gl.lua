local GLDevice = require("arisu-gfx.device.gl")

---@class gfx.gl.Adapter
local GLAdapter = {}
GLAdapter.__index = GLAdapter

---@param config gfx.AdapterConfig
function GLAdapter.new(config)
	return setmetatable({ config = config }, GLAdapter)
end

function GLAdapter:requestDevice()
	return GLDevice.new()
end

return GLAdapter
