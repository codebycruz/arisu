local GLAdapter = require("hood.adapter.gl")

---@class hood.gl.Instance
local GLInstance = {}
GLInstance.__index = GLInstance

function GLInstance.new()
	return setmetatable({}, GLInstance)
end

---@param config hood.AdapterConfig
function GLInstance:requestAdapter(config)
	return GLAdapter.new(config)
end

return GLInstance
