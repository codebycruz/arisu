local GLAdapter = require("arisu-gfx.adapter.gl")

---@class gfx.gl.Instance
local GLInstance = {}
GLInstance.__index = GLInstance

function GLInstance.new()
	return setmetatable({}, GLInstance)
end

---@param config gfx.AdapterConfig
function GLInstance:requestAdapter(config)
	return GLAdapter.new(config)
end

return GLInstance
