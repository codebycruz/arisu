local Arisu = require "src.arisu"
local Element = require "src.ui.element"
local Image = require "src.image"
local Bitmap = require "src.font.bitmap"
local ffi = require("ffi")

---@alias Message
--- | { type: "BrushClicked" }
--- | { type: "EraserClicked" }
--- | { type: "ColorClicked" }
--- | { type: "ClearClicked" }
--- | { type: "SaveClicked" }
--- | { type: "LoadClicked" }
--- | { type: "StartDrawing" }
--- | { type: "StopDrawing" }
--- | { type: "Hovered", x: number, y: number, elementWidth: number, elementHeight: number }

---@class App
---@field patternTexture Texture
---@field qoiTexture Texture
---@field canvasTexture Texture
---@field textureManager TextureManager
---@field jbmFont Bitmap
---@field canvasBuffer userdata
---@field isDrawing boolean
---@field lastGPUUpdate number
---@field gpuUpdateInterval number
---@field fps number
---@field lastFrameTime number
local App = {}
App.__index = App

function App:view()
    local borderColor = { r = 0.0, g = 0.0, b = 0.0, a = 0.7 }

    return Element.Div.new()
        :withStyle({
            direction = "column",
            bg = { r = 0.95, g = 0.95, b = 0.95, a = 1.0 }
        })
        :withChildren(
            -- Top toolbar
            Element.Div.new()
                :withStyle({
                    height = { abs = 100 },
                    direction = "row",
                    align = "center",
                    padding = { bottom = 2 },
                })
                :withChildren(
                    Element.Div.new()
                        :withStyle({
                            direction = "column",
                            width = { abs = 150 },
                            height = { rel = 1.0 },
                            border = { right = { width = 1, color = borderColor } }
                        })
                        :withChildren(
                            Element.Text.from("Center", self.jbmFont)
                                :withStyle({
                                    padding = { top = 3, bottom = 3, left = 3, right = 3 },
                                    height = { rel = 0.7 },
                                }),
                            Element.Text.from("Clipboard", self.jbmFont)
                                :withStyle({
                                    align = "center",
                                    justify = "center",
                                    height = { rel = 0.3 },
                                })
                        ),
                    Element.Div.new()
                        :withStyle({
                            direction = "column",
                            width = { abs = 180 },
                            height = { rel = 1.0 },
                            border = { right = { width = 1, color = borderColor } }
                        })
                        :withChildren(
                            Element.Text.from("Center", self.jbmFont)
                                :withStyle({
                                    padding = { top = 3, bottom = 3, left = 3, right = 3 },
                                    height = { rel = 0.7 },
                                }),
                            Element.Text.from("Image", self.jbmFont)
                                :withStyle({
                                    align = "center",
                                    justify = "center",
                                    height = { rel = 0.3 },
                                })
                        ),
                    Element.Div.new()
                        :withStyle({
                            direction = "column",
                            width = { abs = 150 },
                            height = { rel = 1.0 },
                            border = { right = { width = 1, color = borderColor } }
                        })
                        :withChildren(
                            Element.Text.from("Center", self.jbmFont)
                                :withStyle({
                                    padding = { top = 3, bottom = 3, left = 3, right = 3 },
                                    height = { rel = 0.7 },
                                }),
                            Element.Text.from("Tools", self.jbmFont)
                                :withStyle({
                                    align = "center",
                                    justify = "center",
                                    height = { rel = 0.3 },
                                })
                        ),
                    Element.Div.new()
                        :withStyle({
                            direction = "column",
                            width = { abs = 100 },
                            height = { rel = 1.0 },
                            border = { right = { width = 1, color = borderColor } }
                        })
                        :withChildren(
                            Element.Text.from("Center", self.jbmFont)
                                :withStyle({
                                    padding = { top = 3, bottom = 3, left = 3, right = 3 },
                                    height = { rel = 0.7 },
                                }),
                            Element.Text.from("Brushes", self.jbmFont)
                                :withStyle({
                                    align = "center",
                                    justify = "center",
                                    height = { rel = 0.3 },
                                })
                        ),

                    Element.Div.new()
                        :withStyle({
                            direction = "column",
                            width = { abs = 200 },
                            height = { rel = 1.0 },
                            border = { right = { width = 1, color = borderColor } }
                        })
                        :withChildren(
                            Element.Text.from("Center", self.jbmFont)
                                :withStyle({
                                    padding = { top = 3, bottom = 3, left = 3, right = 3 },
                                    height = { rel = 0.7 },
                                }),
                            Element.Text.from("Shapes", self.jbmFont)
                                :withStyle({
                                    align = "center",
                                    justify = "center",
                                    height = { rel = 0.3 },
                                })
                        ),

                    Element.Div.new()
                        :withStyle({
                            direction = "column",
                            width = { abs = 400 },
                            height = { rel = 1.0 },
                            border = { right = { width = 1, color = borderColor } }
                        })
                        :withChildren(
                            Element.Text.from("Center", self.jbmFont)
                                :withStyle({
                                    padding = { top = 3, bottom = 3, left = 3, right = 3 },
                                    height = { rel = 0.7 },
                                }),
                            Element.Text.from("Colors", self.jbmFont)
                                :withStyle({
                                    align = "center",
                                    justify = "center",
                                    height = { rel = 0.3 },
                                })
                        )
                ),
            -- Bottom section
            Element.Div.new()
                :withStyle({
                    align = "center",
                    justify = "center",
                    bg = { r = 0.7, g = 0.7, b = 0.8, a = 1.0 },
                })
                :withChildren(
                    Element.Div.new()
                        :withStyle({
                            bg = { r = 1, g = 1, b = 1, a = 1 },
                            bgImage = self.canvasTexture,
                            width = { rel = 0.95 },
                            height = { rel = 0.95 },
                        })
                        :onMouseDown({ type = "StartDrawing" })
                        :onMouseUp({ type = "StopDrawing" })
                        :onMouseMove(function(x, y, elementWidth, elementHeight)
                            return { type = "Hovered", x = x, y = y, elementWidth = elementWidth, elementHeight = elementHeight }
                        end)
                )
        )
end

---@param event Event
function App:event(event)
    if event.name == "redraw" then
        local currentTime = os.clock()
        local deltaTime = currentTime - self.lastFrameTime
        local frameTime = 1.0 / 60

        if deltaTime >= frameTime then
            if self.lastFrameTime > 0 then
                local actualFps = 1.0 / deltaTime
                self.fps = self.fps * 0.9 + actualFps * 0.1
            end
            self.lastFrameTime = currentTime
        end
    end
end

---@param message Message
function App:update(message)
    if message.type == "BrushClicked" then
    elseif message.type == "StartDrawing" then
        self.isDrawing = true
    elseif message.type == "StopDrawing" then
        self.isDrawing = false
        local canvasImage = Image.new(800, 600, 4, self.canvasBuffer, "")
        self.textureManager:update(self.canvasTexture, canvasImage)
        self.lastGPUUpdate = os.clock()
    elseif message.type == "EraserClicked" then
    elseif message.type == "ColorClicked" then
    elseif message.type == "ClearClicked" then
        for i = 0, 800 * 600 * 4 - 1 do
            self.canvasBuffer[i] = 255
        end

        local canvasImage = Image.new(800, 600, 4, self.canvasBuffer, "")
        self.textureManager:update(self.canvasTexture, canvasImage)
        self.lastGPUUpdate = os.clock()
    elseif message.type == "SaveClicked" then
    elseif message.type == "LoadClicked" then
    elseif message.type == "Hovered" then
        if self.isDrawing and message.elementWidth and message.elementHeight then
            -- Map UI coordinates to texture coordinates
            local textureX = (message.x / message.elementWidth) * 800
            local textureY = (message.y / message.elementHeight) * 600

            local pixelX = math.floor(textureX)
            local pixelY = math.floor(textureY)

            if pixelX >= 0 and pixelX < 800 and pixelY >= 0 and pixelY < 600 then
                local brushSize = 3
                for dy = -brushSize, brushSize do
                    for dx = -brushSize, brushSize do
                        local x = pixelX + dx
                        local y = pixelY + dy
                        if x >= 0 and x < 800 and y >= 0 and y < 600 then
                            if dx * dx + dy * dy <= brushSize * brushSize then
                                local index = (y * 800 + x) * 4
                                self.canvasBuffer[index + 0] = 0
                                self.canvasBuffer[index + 1] = 0
                                self.canvasBuffer[index + 2] = 0
                                self.canvasBuffer[index + 3] = 255
                            end
                        end
                    end
                end

                local currentTime = os.clock()
                if currentTime - self.lastGPUUpdate >= self.gpuUpdateInterval then
                    local canvasImage = Image.new(800, 600, 4, self.canvasBuffer, "")
                    self.textureManager:update(self.canvasTexture, canvasImage)
                    self.lastGPUUpdate = currentTime
                end
            end
        end
    end

    return true
end

Arisu.runApp(function(textureManager)
    local this = setmetatable({}, App)
    this.isDrawing = false
    this.textureManager = textureManager
    this.lastGPUUpdate = 0
    this.gpuUpdateInterval = 1.0 / 30
    this.fps = 60
    this.lastFrameTime = 0

    local patternImage = assert(Image.fromPath("assets/gradient.qoi"), "Failed to load pattern image")
    this.patternTexture = textureManager:upload(patternImage)

    local qoiImage = assert(Image.fromPath("assets/airman.qoi"), "Failed to load QOI image")
    this.qoiTexture = textureManager:upload(qoiImage)

    local characters = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
    local jbmFont = assert(Bitmap.fromPath({ ymargin = 2, xmargin = 4, gridWidth = 18, gridHeight = 18, characters = characters, perRow = 19 }, "assets/JetBrainsMono.qoi"), "Failed to load bitmap font")
    textureManager:upload(jbmFont.image)
    this.jbmFont = jbmFont

    this.canvasBuffer = ffi.new("uint8_t[?]", 800 * 600 * 4)
    for i = 0, 800 * 600 * 4 - 1 do
        this.canvasBuffer[i] = 255
    end

    local canvasImage = Image.new(800, 600, 4, this.canvasBuffer, "")
    this.canvasTexture = textureManager:upload(canvasImage)

    return this
end)
