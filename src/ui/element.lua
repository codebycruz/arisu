--- The View is a small layer above the Layout that bridges interactivity with the layout.

---@alias Element Div | Button | Text

---@class Div
---@field type "div"
---@field children Element[]
---@field visualStyle VisualStyle
---@field layoutStyle LayoutStyle
local Div = {}
Div.__index = Div

function Div.new()
    return setmetatable({ children = {}, type = "div", visualStyle = {}, layoutStyle = {} }, Div)
end

function Div:withChildren(...)
    self.children = {...}
    return self
end

function Div:withLayoutStyle(style --[[@param style LayoutStyle]] )
    self.layoutStyle = style
    return self
end

function Div:withVisualStyle(style --[[@param style VisualStyle]] )
    self.visualStyle = style
    return self
end

function Div:withStyle(style --[[@param style LayoutStyle | VisualStyle]] )
    self.visualStyle = style
    self.layoutStyle = style
    return self
end

---@class Button
---@field type "button"
---@field onclick fun()
---@field inner Element
local Button = {}
Button.__index = Button

function Button.new()
    return setmetatable({ type = "button", inner = Div.new() }, Button)
end

function Button:withInner(element --[[@param element Element]] )
    self.inner = element
    return self
end

function Button:onClick(callback --[[@param callback fun()]] )
    self.onclick = callback
    return self
end

---@class Text
---@field type "text"
---@field content string
---@field visualStyle VisualStyle
---@field layoutStyle LayoutStyle
local Text = {}
Text.__index = Text

function Text.from(content)
    return setmetatable({ type = "text", visualStyle = {}, layoutStyle = {}, content = content }, Text)
end

return {
    Div = Div,
    Button = Button,
    Text = Text
}
