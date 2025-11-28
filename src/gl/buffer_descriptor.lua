local gl = require("src.bindings.gl")
local ffi = require("ffi")

---@alias AttributeType "f32" | "i32"
---@alias Attribute { type: "f32" | "i32", size: number, offset: number, normalized: boolean }

---@class BufferDescriptor
---@field attributes Attribute[]
---@field stride number?
local BufferDescriptor = {}
BufferDescriptor.__index = BufferDescriptor

function BufferDescriptor.new()
	return setmetatable({ attributes = {}, stride = 0 }, BufferDescriptor)
end

---@param attribute Attribute
function BufferDescriptor:withAttribute(attribute)
	table.insert(self.attributes, attribute)
	return self
end

function BufferDescriptor:withStride(stride)
	self.stride = stride
	return self
end

function BufferDescriptor:getStride()
	if self.stride and self.stride > 0 then
		return self.stride
	end

	local maxEnd = 0
	for _, attr in ipairs(self.attributes) do
		local typeSize
		if attr.type == "f32" then
			typeSize = ffi.sizeof("float")
		elseif attr.type == "i32" then
			typeSize = ffi.sizeof("int32_t")
		else
			error("Unknown attribute type: " .. tostring(attr.type))
		end

		local attrEnd = attr.offset + (typeSize * attr.size)
		maxEnd = math.max(maxEnd, attrEnd)
	end

	return maxEnd
end

return BufferDescriptor
