local Arisu = require "src.arisu"
local Element = require "src.ui.element"
local Image = require "src.image"
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
--- | { type: "Hovered", x: number, y: number }

---@class App
---@field r number
---@field patternImage Image
---@field patternTexture Texture
---@field qoiImage Image
---@field qoiTexture Texture
---@field canvasTexture Texture
---@field textureManager TextureManager
---@field canvasBuffer userdata
---@field isDrawing boolean
---@field lastGPUUpdate number
---@field gpuUpdateInterval number
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
                    size = {1.0, nil},
                    height = { abs = 60 },
                    direction = "row",
                    gap = 10,
                    align = "center",
                    padding = { left = 20, right = 20 },
                    bg = { r = 0.85, g = 0.85, b = 0.85, a = 1.0 }
                })
                :withChildren(
                    -- Brush tool
                    Element.Div.new()
                        :withStyle({
                            width = { abs = 50 },
                            height = { abs = 40 },
                            bg = { r = 0.7, g = 0.7, b = 0.7, a = 1.0 },
                            justify = "center",
                            align = "center"
                        })
                        :onMouseDown({ type = "BrushClicked" }),

                    -- Eraser tool
                    Element.Div.new()
                        :withStyle({
                            width = { abs = 50 },
                            height = { abs = 40 },
                            bg = { r = 0.7, g = 0.7, b = 0.7, a = 1.0 },
                            justify = "center",
                            align = "center"
                        })
                        :onMouseDown({ type = "EraserClicked" }),

                    -- Color picker
                    Element.Div.new()
                        :withStyle({
                            width = { abs = 50 },
                            height = { abs = 40 },
                            bg = { r = 0.2, g = 0.2, b = 0.2, a = 1.0 },
                            justify = "center",
                            align = "center"
                        })
                        :onMouseDown({ type = "ColorClicked" }),

                    -- Clear canvas
                    Element.Div.new()
                        :withStyle({
                            width = { abs = 50 },
                            height = { abs = 40 },
                            bg = { r = 0.9, g = 0.5, b = 0.5, a = 1.0 },
                            justify = "center",
                            align = "center"
                        })
                        :onMouseDown({ type = "ClearClicked" }),

                    -- Save button
                    Element.Div.new()
                        :withStyle({
                            width = { abs = 50 },
                            height = { abs = 40 },
                            bg = { r = 0.5, g = 0.8, b = 0.5, a = 1.0 },
                            justify = "center",
                            align = "center"
                        })
                        :onMouseDown({ type = "SaveClicked" }),

                    -- Load button
                    Element.Div.new()
                        :withStyle({
                            width = { abs = 50 },
                            height = { abs = 40 },
                            bg = { r = 0.5, g = 0.5, b = 0.8, a = 1.0 },
                            justify = "center",
                            align = "center"
                        })
                        :onMouseDown({ type = "LoadClicked" })
                ),

            -- Main canvas area
            Element.Div.new()
                :withStyle({
                    size = {1.0, 1.0},
                    justify = "center",
                    align = "center",
                    bg = { r = 0.9, g = 0.9, b = 0.9, a = 1.0 }
                })
                :withChildren(
                    Element.Div.new()
                        :withStyle({
                            width = { abs = 600 },
                            height = { abs = 450 },
                            bg = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },
                            bgImage = self.canvasTexture
                        })
                        :onMouseDown({ type = "StartDrawing" })
                        :onMouseUp({ type = "StopDrawing" })
                        :onMouseMove(function(x, y)
                            return { type = "Hovered", x = x, y = y }
                        end)
                )
        )
end

---@param message Message
function App:update(message)
    if message.type == "BrushClicked" then
    elseif message.type == "StartDrawing" then
        self.isDrawing = true
    elseif message.type == "StopDrawing" then
        self.isDrawing = false
        local canvasImage = Image.new(600, 450, 4, self.canvasBuffer, "")
        self.textureManager:update(self.canvasTexture, canvasImage)
        self.lastGPUUpdate = os.clock()
    elseif message.type == "EraserClicked" then
    elseif message.type == "ColorClicked" then
    elseif message.type == "ClearClicked" then
        for i = 0, 600 * 450 * 4 - 1 do
            self.canvasBuffer[i] = 255
        end

        local canvasImage = Image.new(600, 450, 4, self.canvasBuffer, "")
        self.textureManager:update(self.canvasTexture, canvasImage)
        self.lastGPUUpdate = os.clock()
    elseif message.type == "SaveClicked" then
    elseif message.type == "LoadClicked" then
    elseif message.type == "Hovered" then
        if self.isDrawing then
            local pixelX = math.floor(message.x)
            local pixelY = math.floor(message.y)
            if pixelX >= 0 and pixelX < 600 and pixelY >= 0 and pixelY < 450 then
                local brushSize = 3
                for dy = -brushSize, brushSize do
                    for dx = -brushSize, brushSize do
                        local x = pixelX + dx
                        local y = pixelY + dy
                        if x >= 0 and x < 600 and y >= 0 and y < 450 then
                            if dx * dx + dy * dy <= brushSize * brushSize then
                                local index = (y * 600 + x) * 4
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
                    local canvasImage = Image.new(600, 450, 4, self.canvasBuffer, "")
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
    this.r = 1.0
    this.isDrawing = false
    this.textureManager = textureManager
    this.lastGPUUpdate = 0
    this.gpuUpdateInterval = 1.0 / 30

    this.patternImage = assert(Image.fromPath("assets/gradient.qoi"), "Failed to load pattern image")
    this.patternTexture = textureManager:upload(this.patternImage)

    this.qoiImage = assert(Image.fromPath("assets/airman.qoi"), "Failed to load QOI image")
    this.qoiTexture = textureManager:upload(this.qoiImage)

    this.canvasBuffer = ffi.new("uint8_t[?]", 600 * 450 * 4)
    for i = 0, 600 * 450 * 4 - 1 do
        this.canvasBuffer[i] = 255
    end

    local canvasImage = Image.new(600, 450, 4, this.canvasBuffer, "")
    this.canvasTexture = textureManager:upload(canvasImage)

    return this
end)
