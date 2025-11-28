local Element

local function intoElement(value)
	if getmetatable(value) == Element then
		return value
	elseif type(value) == "string" then
		return Element.new("text"):withUserdata(value)
	else
		error "Cannot convert value to Element"
	end
end

---@alias IntoElement Element | string

--- The View is a small layer above the Layout that bridges interactivity with the layout.
---@class Element<T>: { onclick: T?, onmousemove: (fun(x: number, y: number): T)?, onmousedown: T?, onmouseup: T? }
---@field visualStyle VisualStyle?
---@field layoutStyle LayoutStyle?
---@field children Element[]?
---@field type string
---@field userdata any?
---@field id string?
Element = {}
Element.__index = Element

---@param type string
function Element.new(type)
	return setmetatable({ type = type, children = {}, visualStyle = {}, layoutStyle = {} }, Element)
end

---@param val IntoElement
function Element.from(val)
	return intoElement(val)
end

---@param id string
function Element:withId(id)
	self.id = id
	return self
end

---@param children IntoElement[]
function Element:withChildren(children)
	local elems = {}
	for i, child in ipairs(children) do
		elems[i] = intoElement(child)
	end

	self.children = elems
	return self
end

function Element:withLayoutStyle(
	style --[[@param style LayoutStyle]]
)
	self.layoutStyle = style
	return self
end

function Element:withVisualStyle(
	style --[[@param style VisualStyle]]
)
	self.visualStyle = style
	return self
end

function Element:withStyle(
	style --[[@param style LayoutStyle | VisualStyle]]
)
	self.visualStyle = style
	self.layoutStyle = style
	return self
end

function Element:withUserdata(
	data --[[@param data any]]
)
	self.userdata = data
	return self
end

---@generic T
function Element:onMouseMove(
	message --[[@param message T]]
)
	self.onmousemove = message
	return self
end

---@generic T
function Element:onClick(
	message --[[@param message T]]
)
	self.onmousedown = function()
		return message
	end
	return self
end

---@generic T
function Element:onMouseDown(
	cons --[[@param cons fun(): T]]
)
	self.onmousedown = cons
	return self
end

---@generic T
function Element:onMouseUp(
	message --[[@param message T]]
)
	self.onmouseup = message
	return self
end

return Element
