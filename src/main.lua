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
    return Element.Div.new()
        :withStyle({
            size = {1.0, 1.0},
            direction = "column",
            bg = { r = 0.95, g = 0.95, b = 0.95, a = 1.0 }
        })
        :withChildren(
            -- Top toolbar
            Element.Div.new()
                :withStyle({
                    size = {1.0, 0.2},
                    height = { abs = 120 },
                    direction = "row",
                    gap = 10,
                    align = "center",
                    padding = { left = 20, right = 20 },
                    bg = { r = 0.85, g = 0.85, b = 0.85, a = 1.0 },
                    border = { bottom = { width = 1, color = { r = 0.0, g = 0.0, b = 0.0, a = 0.7 } } }
                })
                :withChildren(
                    -- Brush tool
                    Element.Div.new()
                        :withStyle({
                            width = { abs = 60 },
                            height = { abs = 40 },
                            bg = { r = 0.7, g = 0.7, b = 0.7, a = 1.0 },
                            justify = "center",
                            align = "center",
                            padding = { top = 5, bottom = 5, left = 5, right = 5 },
                            margin = { right = 5 },
                            border = { width = 2, color = { r = 0, g = 0, b = 0, a = 1.0 } }
                        })
                        :onMouseDown({ type = "BrushClicked" })
                        :withChildren(
                            Element.Text.from("Brush", self.jbmFont)
                        ),

                    -- Eraser tool
                    Element.Div.new()
                        :withStyle({
                            width = { abs = 60 },
                            height = { abs = 40 },
                            bg = { r = 0.7, g = 0.7, b = 0.7, a = 1.0 },
                            justify = "center",
                            align = "center",
                            padding = { top = 5, bottom = 5, left = 5, right = 5 },
                            margin = { right = 5 },
                            border = { width = 2, color = { r = 0, g = 0, b = 0, a = 1.0 } }
                        })
                        :onMouseDown({ type = "EraserClicked" })
                        :withChildren(
                            Element.Text.from("Erase", self.jbmFont)
                        ),

                    -- Color picker
                    Element.Div.new()
                        :withStyle({
                            width = { abs = 50 },
                            height = { abs = 40 },
                            bg = { r = 0.2, g = 0.2, b = 0.2, a = 1.0 },
                            justify = "center",
                            align = "center",
                            padding = { top = 5, bottom = 5, left = 5, right = 5 },
                            margin = { left = 15, right = 15 },
                            border = { width = 5, color = { r = 0.0, g = 1.0, b = 0.0, a = 1.0 } }
                        })
                        :onMouseDown({ type = "ColorClicked" })
                        :withChildren(
                            Element.Text.from("Color", self.jbmFont)
                        ),

                    -- Clear canvas
                    Element.Div.new()
                        :withStyle({
                            width = { abs = 50 },
                            height = { abs = 40 },
                            bg = { r = 0.9, g = 0.5, b = 0.5, a = 1.0 },
                            justify = "center",
                            align = "center",
                            padding = { top = 5, bottom = 5, left = 5, right = 5 },
                            margin = { left = 15, right = 5 },
                            border = { width = 5, color = { r = 1.0, g = 1.0, b = 0.0, a = 1.0 } }
                        })
                        :onMouseDown({ type = "ClearClicked" })
                        :withChildren(
                            Element.Text.from("Clear", self.jbmFont)
                        ),

                    -- Save button
                    Element.Div.new()
                        :withStyle({
                            width = { abs = 50 },
                            height = { abs = 40 },
                            bg = { r = 0.5, g = 0.8, b = 0.5, a = 1.0 },
                            justify = "center",
                            align = "center",
                            padding = { top = 5, bottom = 5, left = 5, right = 5 },
                            margin = { right = 5 },
                            border = { width = 5, color = { r = 1.0, g = 0.0, b = 1.0, a = 1.0 } }
                        })
                        :onMouseDown({ type = "SaveClicked" })
                        :withChildren(
                            Element.Text.from("Save", self.jbmFont)
                        ),

                    -- Load button
                    Element.Div.new()
                        :withStyle({
                            width = { abs = 50 },
                            height = { abs = 40 },
                            bg = { r = 0.5, g = 0.5, b = 0.8, a = 1.0 },
                            justify = "center",
                            align = "center",
                            padding = { top = 5, bottom = 5, left = 5, right = 5 },
                            border = { width = 5, color = { r = 0.0, g = 1.0, b = 1.0, a = 1.0 } }
                        })
                        :onMouseDown({ type = "LoadClicked" })
                        :withChildren(
                            Element.Text.from("Load", self.jbmFont)
                        ),
            -- FPS Counter
            Element.Div.new()
                :withStyle({
                    width = { abs = 80 },
                    height = { abs = 40 },
                    bg = { r = 0.8, g = 0.8, b = 0.8, a = 1.0 },
                    justify = "center",
                    align = "center",
                    padding = { top = 5, bottom = 5, left = 5, right = 5 },
                    margin = { left = 20 }
                })
                :withChildren(
                    Element.Text.from("FPS: " .. math.floor(self.fps), self.jbmFont)
                )
            ),

            -- Main canvas area
            Element.Div.new()
                :withStyle({
                    widthh = { rel = 1.0 },
                    height = { rel = 0.8 },
                    justify = "center",
                    align = "center",
                    bg = { r = 0.9, g = 0.9, b = 0.9, a = 1.0 },
                    padding = { top = 5, bottom = 5, left = 5, right = 5 },
                    margin = { top = 10 }
                })
                :withChildren(
                    Element.Div.new()
                        :withStyle({
                            width = { rel = 1.0 },
                            height = { rel = 1.0 },
                            bg = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },
                            bgImage = self.canvasTexture,
                            padding = { top = 10, bottom = 10, left = 10, right = 10 },
                            margin = { top = 20, bottom = 20, left = 20, right = 20 },
                            border = { width = 10, color = { r = 0.0, g = 0.0, b = 0.0, a = 1.0 } }
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
