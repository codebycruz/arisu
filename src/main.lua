local Arisu = require "src.arisu"
local Element = require "src.ui.element"

---@enum Message
local Message = {
    GreenClicked = 1,
    YellowClicked = 2,
    BlueClicked = 3
}

---@class App
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
            bg = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },
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
    print("Hi updated")
end

Arisu.runApp(App)
