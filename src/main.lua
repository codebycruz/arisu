local Arisu = require "src.arisu"
local Element = require "src.ui.element"
local Image = require "src.image"
local ffi = require("ffi")

---@alias Message
--- | { type: "GreenClicked" }
--- | { type: "YellowClicked" }
--- | { type: "BlueClicked" }
--- | { type: "Hovered", x: number, y: number }

---@class App
---@field r number
---@field patternImage Image
---@field patternTexture Texture
---@field qoiImage Image
---@field qoiTexture Texture
---@field canvasTexture Texture
---@field canvasBuffer userdata
---@field isDrawing boolean
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
            bgImage = self.qoiTexture
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
                            bg = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },
                            bgImage = self.canvasTexture
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
        self.isDrawing = not self.isDrawing
        print("Drawing mode:", self.isDrawing)
    elseif message.type == "BlueClicked" then
        print("Blue clicked!")
    elseif message.type == "Hovered" then
        print(string.format("Hovered at (%.2f, %.2f)", message.x, message.y))
        if self.isDrawing then
            local pixelX = math.floor(message.x)
            local pixelY = math.floor(message.y)
            if pixelX >= 0 and pixelX < 128 and pixelY >= 0 and pixelY < 128 then
                local index = (pixelY * 128 + pixelX) * 4
                self.canvasBuffer[index + 0] = 0
                self.canvasBuffer[index + 1] = 0
                self.canvasBuffer[index + 2] = 0
                self.canvasBuffer[index + 3] = 255

                local canvasImage = Image.new(128, 128, 4, self.canvasBuffer, "")
                self.textureManager:update(self.canvasTexture, canvasImage)
            end
        end
    end

    return true
end

Arisu.runApp(function(textureManager)
    local this = setmetatable({}, App)
    this.r = 1.0
    this.isDrawing = false
    this.textureManager = textureManager

    this.patternImage = assert(Image.fromPath("assets/gradient.qoi"), "Failed to load pattern image")
    this.patternTexture = textureManager:upload(this.patternImage)

    this.qoiImage = assert(Image.fromPath("assets/airman.qoi"), "Failed to load QOI image")
    this.qoiTexture = textureManager:upload(this.qoiImage)

    this.canvasBuffer = ffi.new("uint8_t[?]", 128 * 128 * 4)
    for i = 0, 128 * 128 * 4 - 1 do
        this.canvasBuffer[i] = 255
    end

    local canvasImage = Image.new(128, 128, 4, this.canvasBuffer, "")
    this.canvasTexture = textureManager:upload(canvasImage)

    return this
end)
