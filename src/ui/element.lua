--- The View is a small layer above the Layout that bridges interactivity with the layout.
---@class Element<T>: { visualStyle: VisualStyle?, layoutStyle: LayoutStyle?, children: Element[]?, type: string, onclick: T, onmousemove: fun(x: number, y: number): T, onmousedown: T, onmouseup: T, layoutStyle: LayoutStyle, visualStyle: VisualStyle }

---@class Div<T>: { onclick: T | nil, onmousedown: T | nil, onmouseup: T | nil }
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
function Div:onMouseMove(message --[[@param message T]])
    self.onmousemove = message
    return self
end

---@generic T
function Div:onMouseDown(message --[[@param message T]])
    self.onmousedown = message
    return self
end

---@generic T
function Div:onMouseUp(message --[[@param message T]])
    self.onmouseup = message
    return self
end

---@class Text<T>: { onclick: T | nil }
---@field type "text"
---@field content string
---@field visualStyle VisualStyle
---@field layoutStyle LayoutStyle
local Text = {}
Text.__index = Text

function Text.from(content, bitmap)
    local row = Div.new()
        :withStyle({ direction = "row", bg = { r = 0, g = 0, b = 0, a = 0 } })

    for i = 1, #content do
        local char = content:sub(i, i)
        local quad = bitmap:getCharUVs(char)

        local charDiv = Div.new()
            :withStyle({
                bg = { r = 0.0, g = 0.0, b = 0.0, a = 1.0 },
                bgImage = 4,
                bgImageUV = quad,
                width = { abs = quad.width },
                height = { abs = quad.height },
            })

        table.insert(row.children, charDiv)
    end

    return row
end

function Text:withStyle(style --[[@param style LayoutStyle | VisualStyle]] )
    self.visualStyle = style
    self.layoutStyle = style
    return self
end

return {
    Div = Div,
    Text = Text
}
