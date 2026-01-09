local GLDevice = require("hood.device.gl")

---@class hood.gl.Adapter
local GLAdapter = {}
GLAdapter.__index = GLAdapter

---@param config hood.AdapterConfig
function GLAdapter.new(config)
	return setmetatable({ config = config }, GLAdapter)
end

function GLAdapter:requestDevice()
	return GLDevice.new()
end

return GLAdapter
