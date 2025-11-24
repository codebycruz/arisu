local Arisu = require "src.arisu"
local Element = require "src.ui.element"
local Image = require "src.image"

---@enum Message
local Message = {
    GreenClicked = 1,
    YellowClicked = 2,
    BlueClicked = 3
}

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
                    Element.Div.new()
                        :withStyle({
                            width = { abs = 128 },
                            height = { abs = 128 },
                            bg = { r = 1.0, g = 1.0, b = 0.0, a = 1.0 }
                        })
                        :onClick(Message.YellowClicked)
                )
                :onClick(Message.GreenClicked),
            Element.Div.new()
                :withStyle({
                    width = { abs = 256 },
                    height = { abs = 256 },
                    bg = { r = 0.0, g = 0.0, b = 1.0, a = 1.0 }
                })
                :onClick(Message.BlueClicked)
        )
end

---@param message Message
function App:update(message)
    if message == Message.GreenClicked then
        print("Green clicked!")
        self.r = math.min(self.r + 0.1, 1.0)
    elseif message == Message.YellowClicked then
        print("Yellow clicked!")
    elseif message == Message.BlueClicked then
        print("Blue clicked!")
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
