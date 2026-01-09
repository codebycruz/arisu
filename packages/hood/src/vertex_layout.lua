local ffi = require("ffi")

---@alias AttributeType "f32" | "i32"
---@alias Attribute { type: "f32" | "i32", size: number, offset: number, normalized: boolean }

---@class hood.VertexLayout
---@field attributes Attribute[]
---@field stride number?
local VertexLayout = {}
VertexLayout.__index = VertexLayout

function VertexLayout.new()
	return setmetatable({ attributes = {}, stride = 0 }, VertexLayout)
end

---@param attribute Attribute
function VertexLayout:withAttribute(attribute)
	table.insert(self.attributes, attribute)
	return self
end

function VertexLayout:withStride(stride)
	self.stride = stride
	return self
end

function VertexLayout:getStride()
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

return VertexLayout
