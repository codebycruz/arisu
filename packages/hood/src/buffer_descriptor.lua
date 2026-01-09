---@alias hood.BufferUsage
--- | "COPY_DST"
--- | "COPY_SRC"
--- | "VERTEX"
--- | "INDEX"
--- | "UNIFORM"
--- | "STORAGE"

---@class hood.BufferDescriptor
---@field size number
---@field usages hood.BufferUsage[]
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

---@param usages hood.BufferUsage[]
function BufferDescriptor:withUsages(usages)
	self.usages = usages
	return self
end

return BufferDescriptor
