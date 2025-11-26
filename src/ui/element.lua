--- The View is a small layer above the Layout that bridges interactivity with the layout.
---@class Element<T>: { onclick: T?, onmousemove: (fun(x: number, y: number): T)?, onmousedown: T?, onmouseup: T? }
---@field visualStyle VisualStyle?
---@field layoutStyle LayoutStyle?
---@field children Element[]?
---@field type string
local Element = {}
Element.__index = Element

---@param type string
function Element.new(type)
    return setmetatable({ type = type, children = {} }, Element)
end

function Element:withChildren(...)
    self.children = {...}
    return self
end

function Element:withLayoutStyle(style --[[@param style LayoutStyle]] )
    self.layoutStyle = style
    return self
end

function Element:withVisualStyle(style --[[@param style VisualStyle]] )
    self.visualStyle = style
    return self
end

function Element:withStyle(style --[[@param style LayoutStyle | VisualStyle]] )
    self.visualStyle = style
    self.layoutStyle = style
    return self
end

function Element:withUserdata(data --[[@param data any]] )
    self.userdata = data
    return self
end

---@generic T
function Element:onMouseMove(message --[[@param message T]])
    self.onmousemove = message
    return self
end

---@generic T
function Element:onMouseDown(message --[[@param message T]])
    self.onmousedown = message
    return self
end

---@generic T
function Element:onMouseUp(message --[[@param message T]])
    self.onmouseup = message
    return self
end

Element.Div = {}
function Element.Div.new()
    return Element.new("div")
end

Element.Text = {}
function Element.Text.new(content)
    return Element.new("text")
        :withUserdata(content)
end

-- ---@param content string
-- ---@param bitmap Bitmap
-- function Text.from(content)
    -- local row = Div.new()
    --     :withStyle({ direction = "row", bg = { r = 0, g = 0, b = 0, a = 0 } })

    -- for i = 1, #content do
    --     local char = content:sub(i, i)
    --     local quad = bitmap:getCharUVs(char)

    --     local charDiv = Div.new()
    --         :withStyle({
    --             bg = { r = 0.0, g = 0.0, b = 0.0, a = 1.0 },
    --             bgImage = 6,
    --             bgImageUV = quad,
    --             width = { abs = quad.width },
    --             height = { abs = quad.height },
    --         })

    --     table.insert(row.children, charDiv)
    -- end

    -- return row
-- end

return Element
