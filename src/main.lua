local Arisu = require "src.arisu"
local Element = require "src.ui.element"
local Image = require "src.image"

---@alias Message
--- | { type: "GreenClicked" }
--- | { type: "YellowClicked" }
--- | { type: "BlueClicked" }
--- | { type: "Hovered", x: number, y: number }

---@class Canvas<T>: Element<T>
---@field type "canvas"
---@field visualStyle VisualStyle
---@field layoutStyle LayoutStyle
local Canvas = {}
Canvas.__index = Canvas

function Canvas.new()
    return setmetatable({ type = "canvas" }, Canvas)
end

---@param style VisualStyle | LayoutStyle
function Canvas:withStyle(style)
    self.visualStyle = style
    self.layoutStyle = style
    return self
end

function Canvas:onMouseMove(message)
    self.onmousemove = message
    return self
end

function Canvas:onClick(message)
    self.onclick = message
    return self
end

---@class App
---@field r number
local App = {}
App.__index = App

function App:view()
    return Element.Div.new()
        :withStyle({
            size = {1.0, 1.0},
            direction = "row",
            gap = 40 * 4,
            justify = "center",
            align = "center",
            bg = { r = self.r, g = 1.0, b = 1.0, a = 1.0 },
            bgImage = 3
        })
        :withChildren(
            Element.Div.new()
                :withStyle({
                    width = { abs = 256 },
                    height = { abs = 256 },
                    bg = { r = 0.0, g = 1.0, b = 0.0, a = 1.0 }
                })
                :withChildren(
                    Canvas.new()
                        :withStyle({
                            width = { abs = 128 },
                            height = { abs = 128 },
                            bg = { r = 1.0, g = 1.0, b = 0.0, a = 1.0 }
                        })
                        :onClick({ type = "YellowClicked" })
                        :onMouseMove(function(x, y)
                            return { type = "Hovered", x = x, y = y }
                        end)
                )
                :onClick({ type = "GreenClicked" }),
            Element.Div.new()
                :withStyle({
                    width = { abs = 256 },
                    height = { abs = 256 },
                    bg = { r = 0.0, g = 0.0, b = 1.0, a = 1.0 }
                })
                :onClick({ type = "BlueClicked" })
        )
end

---@param message Message
function App:update(message)
    if message.type == "GreenClicked" then
        print("Green clicked!")
        self.r = math.random()
    elseif message.type == "YellowClicked" then
        print("Yellow clicked!")
    elseif message.type == "BlueClicked" then
        print("Blue clicked!")
    elseif message.type == "Hovered" then
        print(string.format("Hovered at (%.2f, %.2f)", message.x, message.y))
    end

    return true
end

Arisu.runApp(function(textureManager)
    local this = setmetatable({}, App)
    this.r = 1.0

    local pattern = Image.fromPath("assets/texture1.ppm")
    assert(pattern, "Failed to load texture image")

    local patternTexture = textureManager:upload(pattern)

    local qoiImage = Image.fromPath("assets/airman.qoi")
    assert(qoiImage, "Failed to load QOI image")

    local qoiTexture = textureManager:upload(qoiImage)

    return this
end)
