--- The View is a small layer above the Layout that bridges interactivity with the layout.

---@alias Element Div | Text

---@class Div<T>: { onclick: T | nil }
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

---@generic T
function Div:onClick(message --[[@param message T]] )
    self.onclick = message
    return self
end

---@class Text<T>: { onclick: T | nil }
---@field type "text"
---@field content string
---@field visualStyle VisualStyle
---@field layoutStyle LayoutStyle
local Text = {}
Text.__index = Text

function Text.from(content)
    return setmetatable({ type = "text", visualStyle = {}, layoutStyle = {}, content = content }, Text)
end

---@generic T
function Text:onClick(message --[[@param message T]] )
    self.onclick = message
    return self
end

return {
    Div = Div,
    Text = Text
}
