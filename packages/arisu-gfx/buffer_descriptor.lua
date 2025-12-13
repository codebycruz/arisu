---@alias gfx.BufferUsage
--- | "COPY_DST"
--- | "COPY_SRC"
--- | "VERTEX"
--- | "INDEX"

---@class gfx.BufferDescriptor
---@field size number
---@field usages gfx.BufferUsage[]
local BufferDescriptor = {}
BufferDescriptor.__index = BufferDescriptor

function BufferDescriptor.new()
	return setmetatable({}, BufferDescriptor)
end

---@param size number
function BufferDescriptor:withSize(size)
	self.size = size
	return self
end

---@param usages gfx.BufferUsage[]
function BufferDescriptor:withUsages(usages)
	self.usages = usages
	return self
end

return BufferDescriptor
