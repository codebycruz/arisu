--- The View is a small layer above the Layout that bridges interactivity with the layout.

---@alias Element Div | Text

---@class Div
---@field type "div"
---@field children Element[]
---@field visualStyle VisualStyle
---@field layoutStyle LayoutStyle
---@field onclick fun() | nil
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

function Div:onClick(callback --[[@param callback fun()]] )
    self.onclick = callback
    return self
end

---@class Text
---@field type "text"
---@field content string
---@field visualStyle VisualStyle
---@field layoutStyle LayoutStyle
---@field onclick fun() | nil
local Text = {}
Text.__index = Text

function Text.from(content)
    return setmetatable({ type = "text", visualStyle = {}, layoutStyle = {}, content = content }, Text)
end

function Text:onClick(callback --[[@param callback fun()]] )
    self.onclick = callback
    return self
end

return {
    Div = Div,
    Text = Text
}