local Element

local function intoElement(value)
	if getmetatable(value) == Element then
		return value
	elseif type(value) == "string" then
		return Element.new("text"):withUserdata(value)
	else
		error("Cannot convert value to Element")
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

---@param style VisualStyle | LayoutStyle
function Element:withStyle(style)
	self.visualStyle = style
	self.layoutStyle = style
	return self
end

---@param data any
function Element:withUserdata(data)
	self.userdata = data
	return self
end

---@generic T
---@param message T
function Element:onMouseMove(message)
	self.onmousemove = message
	return self
end

---@generic T
---@param message T
function Element:onClick(message)
	self.onclick = message
	return self
end

---@generic T
---@param cons fun(): T
function Element:onMouseDown(cons)
	self.onmousedown = cons
	return self
end

---@generic T
---@param message T
function Element:onMouseUp(message)
	self.onmouseup = message
	return self
end

---@param style Style
---@param children Element[]
function Element.div(style, children)
	return Element.new("div"):withStyle(style):withChildren(children)
end

---@param style Style
---@param value string
function Element.text(style, value)
	return Element.from(value):withStyle(style)
end

---@param style Style
---@param src string
function Element.img(style, src)
	style.bgImage = src
	return Element.new("div"):withStyle(style)
end

return Element
