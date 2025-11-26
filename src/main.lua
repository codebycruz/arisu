local Arisu = require "src.arisu"
local Element = require "src.ui.element"
local Image = require "src.image"
local Task = require "src.task"
local Compute = require "src.tools.compute"

local WindowBuilder = (require "src.window").WindowBuilder

local ffi = require("ffi")

---@alias Message
--- | { type: "EraserClicked" }
--- | { type: "ColorClicked", r: number, g: number, b: number }
--- | { type: "ToolClicked", tool: string }
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
---@field brushTexture Texture
---@field eraserTexture Texture
---@field pencilTexture Texture
---@field bucketTexture Texture
---@field textTexture Texture
---@field paletteTexture Texture
---@field selectTexture Texture
---@field pasteTexture Texture
---@field magnifierTexture Texture
---@field soundTexture Texture
---@field soundMuteTexture Texture
---@field vectorTexture Texture
---@field copyTexture Texture
---@field cutTexture Texture
---@field cropTexture Texture
---@field resizeTexture Texture
---@field rotateTexture Texture
---@field brushesTexture Texture
---@field textureManager TextureManager
---@field fontManager FontManager
---@field compute Compute
---@field mainWindow Window
---@field canvasBuffer userdata
---@field isDrawing boolean
---@field lastGPUUpdate number
---@field gpuUpdateInterval number
---@field fps number
---@field lastFrameTime number
---@field currentColor {r: number, g: number, b: number, a: number}
---@field selectedTool string
local App = {}
App.__index = App

---@param window Window
---@param textureManager TextureManager
---@param fontManager FontManager
function App.new(window, textureManager, fontManager)
    local arisuImage = assert(Image.fromPath("assets/brushes.qoi"), "Failed to load window icon")
    window:setIcon(arisuImage)

    local this = setmetatable({}, App)
    this.isDrawing = false
    this.textureManager = textureManager
    this.fontManager = fontManager
    this.lastGPUUpdate = 0
    this.gpuUpdateInterval = 1.0 / 30
    this.fps = 60
    this.lastFrameTime = 0
    this.currentColor = { r = 0.0, g = 0.0, b = 0.0, a = 1.0 }
    this.selectedTool = "brush"

    local brushImage = assert(Image.fromPath("assets/paintbrush.qoi"), "Failed to load brush image")
    this.brushTexture = textureManager:upload(brushImage)

    local bucketImage = assert(Image.fromPath("assets/paintcan.qoi"), "Failed to load bucket image")
    this.bucketTexture = textureManager:upload(bucketImage)

    local paletteImage = assert(Image.fromPath("assets/palette.qoi"), "Failed to load palette image")
    this.paletteTexture = textureManager:upload(paletteImage)

    local pencilImage = assert(Image.fromPath("assets/pencil.qoi"), "Failed to load pencil image")
    this.pencilTexture = textureManager:upload(pencilImage)

    local textImage = assert(Image.fromPath("assets/text.qoi"), "Failed to load text image")
    this.textTexture = textureManager:upload(textImage)

    local eraserImage = assert(Image.fromPath("assets/eraser.qoi"), "Failed to load eraser image")
    this.eraserTexture = textureManager:upload(eraserImage)

    local magnifierImage = assert(Image.fromPath("assets/magnifier.qoi"), "Failed to load magnifier image")
    this.magnifierTexture = textureManager:upload(magnifierImage)

    local pasteImage = assert(Image.fromPath("assets/paste.qoi"), "Failed to load paste image")
    this.pasteTexture = textureManager:upload(pasteImage)

    local selectImage = assert(Image.fromPath("assets/select.qoi"), "Failed to load select image")
    this.selectTexture = textureManager:upload(selectImage)

    local soundImage = assert(Image.fromPath("assets/sound.qoi"), "Failed to load sound image")
    this.soundTexture = textureManager:upload(soundImage)

    local soundMuteImage = assert(Image.fromPath("assets/sound_mute.qoi"), "Failed to load sound mute image")
    this.soundMuteTexture = textureManager:upload(soundMuteImage)

    local copyImage = assert(Image.fromPath("assets/copy.qoi"), "Failed to load copy image")
    this.copyTexture = textureManager:upload(copyImage)

    local cutImage = assert(Image.fromPath("assets/cut.qoi"), "Failed to load cut image")
    this.cutTexture = textureManager:upload(cutImage)

    local cropImage = assert(Image.fromPath("assets/crop.qoi"), "Failed to load crop image")
    this.cropTexture = textureManager:upload(cropImage)

    local resizeImage = assert(Image.fromPath("assets/resize.qoi"), "Failed to load resize image")
    this.resizeTexture = textureManager:upload(resizeImage)

    local rotateImage = assert(Image.fromPath("assets/rotate.qoi"), "Failed to load rotate image")
    this.rotateTexture = textureManager:upload(rotateImage)

    local brushesImage = assert(Image.fromPath("assets/brushes.qoi"), "Failed to load brushes image")
    this.brushesTexture = textureManager:upload(brushesImage)

    this.canvasBuffer = ffi.new("uint8_t[?]", 800 * 600 * 4)
    for i = 0, 800 * 600 * 4 - 1 do
        this.canvasBuffer[i] = 255
    end

    local canvasImage = Image.new(800, 600, 4, this.canvasBuffer, "")
    this.canvasTexture = textureManager:upload(canvasImage)

    local compute = Compute.new(textureManager, this.canvasTexture)
    this.compute = compute

    this.mainWindow = window

    return this
end

---@param window Window
function App:view(window)
    if window ~= self.mainWindow then
        return Element.new("div")
            :withStyle({
                direction = "column",
                width = { abs = 500 },
                height = { abs = 500 },
                bg = { r = 1, g = 0, b = 0, a = 1 }
             })
    end

    local borderColor = { r = 0.8, g = 0.8, b = 0.8, a = 1 }
    local squareBorder = {
        top = { width = 1, color = borderColor },
        bottom = { width = 1, color = borderColor },
        left = { width = 1, color = borderColor },
        right = { width = 1, color = borderColor }
    }

    return Element.new("div")
        :withStyle({
            direction = "column",
            bg = { r = 0.95, g = 0.95, b = 0.95, a = 1.0 }
        })
        :withChildren({
            -- Menu bar
            Element.new("div")
                :withStyle({
                    height = { abs = 30 },
                    direction = "row",
                    align = "center",
                    gap = 5,
                    padding = { left = 5, top = 5 },
                    border = {
                        bottom = { width = 1, color = borderColor }
                    }
                })
                :withChildren({
                    Element.from("File")
                        :withStyle({ width = { abs = 50 } })
                        :onClick({ type = "FileClicked" }),
                    Element.from("Edit")
                        :withStyle({ width = { abs = 50 } }),
                    Element.from("View")
                        :withStyle({ width = { abs = 50 } }),
                    Element.from("Clear")
                        :withStyle({ width = { abs = 50 } })
                        :onClick({ type = "ClearClicked" })
                }),
            -- Top toolbar
            Element.new("div")
                :withStyle({
                    height = { abs = 100 },
                    direction = "row",
                    align = "center",
                    padding = { bottom = 2 },
                })
                :withChildren({
                    Element.new("div")
                        :withStyle({
                            direction = "column",
                            width = { abs = 150 },
                            height = { rel = 1.0 },
                            border = { right = { width = 1, color = borderColor } }
                        })
                        :withChildren({
                            Element.new("div")
                                :withStyle({
                                    padding = { top = 6, bottom = 6, left = 6, right = 6 },
                                    height = { rel = 0.7 },
                                    gap = 16,
                                    direction = "row"
                                })
                                :withChildren({
                                    Element.new("div")
                                        :withStyle({
                                            direction = "column",
                                            width = { rel = 1/3 },
                                            height = { rel = 1.0 },
                                            gap = 8,
                                        })
                                        :withChildren({
                                            Element.new("div")
                                                :withStyle({
                                                    bgImage = self.pasteTexture,
                                                    height = { rel = 2/3 }
                                                }),
                                            Element.from("Paste")
                                                :withStyle({ height = { rel = 1/3 } })
                                        }),
                                    Element.new("div")
                                        :withStyle({
                                            direction = "column",
                                            width = { rel = 1/2 },
                                            height = { rel = 1 },
                                            gap = 2
                                        })
                                        :withChildren({
                                            Element.new("div")
                                                :withStyle({
                                                    direction = "row",
                                                    gap = 5,
                                                    width = { rel = 1/2 },
                                                    height = { rel = 1/3 }
                                                })
                                                :withChildren({
                                                    Element.new("div")
                                                        :withStyle({
                                                            bgImage = self.cutTexture,
                                                            width = { abs = 15 },
                                                            height = { abs = 15 },
                                                            margin = { right = 2 }
                                                        }),
                                                    Element.from("Cut")
                                                        :withStyle({ height = { rel = 1.0 } })
                                                }),
                                            Element.new("div")
                                                :withStyle({
                                                    direction = "row",
                                                    gap = 5,
                                                    width = { rel = 1/2 },
                                                    height = { rel = 1/3 }
                                                })
                                                :withChildren({
                                                    Element.new("div")
                                                        :withStyle({
                                                            bgImage = self.copyTexture,
                                                            width = { abs = 15 },
                                                            height = { abs = 15 },
                                                            margin = { right = 2 }
                                                        }),
                                                    Element.from("Copy")
                                                        :withStyle({ height = { rel = 1.0 } })
                                                })
                                        }),
                                }),
                            Element.from("Clipboard")
                                :withStyle({
                                    align = "center",
                                    justify = "center",
                                    height = { rel = 0.3 },
                                })
                        }),
                    Element.new("div")
                        :withStyle({
                            direction = "column",
                            width = { abs = 180 },
                            height = { rel = 1.0 },
                            border = { right = { width = 1, color = borderColor } }
                        })
                        :withChildren({
                            Element.new("div")
                                :withStyle({
                                    padding = { top = 3, bottom = 3, left = 3, right = 3 },
                                    height = { rel = 0.7 },
                                    gap = 16,
                                    direction = "row"
                                })
                                :withChildren({
                                    Element.new("div")
                                        :withStyle({
                                            direction = "column",
                                            width = { rel = 1/3 },
                                            height = { rel = 1.0 },
                                            gap = 8,
                                        })
                                        :withChildren({
                                            Element.new("div")
                                                :withStyle({
                                                    border = squareBorder,
                                                    bgImage = self.selectTexture,
                                                    height = { rel = 2/3 }
                                                }),
                                            Element.from("Select")
                                                :withStyle({ height = { rel = 1/3 } })
                                                }),
                                    Element.new("div")
                                        :withStyle({
                                            direction = "column",
                                            width = { rel = 1/2 },
                                            height = { rel = 1.0 },
                                            gap = 2
                                        })
                                        :withChildren({
                                            Element.new("div")
                                                :withStyle({
                                                    direction = "row",
                                                    gap = 5,
                                                    width = { rel = 1/2 },
                                                    height = { rel = 1/3 }
                                                })
                                                :withChildren({
                                                    Element.new("div")
                                                        :withStyle({
                                                            bgImage = self.cropTexture,
                                                            width = { abs = 15 },
                                                            height = { abs = 15 },
                                                            margin = { right = 2 }
                                                        }),
                                                    Element.from("Crop")
                                                        :withStyle({ height = { rel = 1.0 } })
                                                }),
                                            Element.new("div")
                                                :withStyle({
                                                    direction = "row",
                                                    gap = 5,
                                                    width = { rel = 1/2 },
                                                    height = { rel = 1/3 }
                                                })
                                                :withChildren({
                                                    Element.new("div")
                                                        :withStyle({
                                                            bgImage = self.resizeTexture,
                                                            width = { abs = 15 },
                                                            height = { abs = 15 },
                                                            margin = { right = 2 }
                                                        }),
                                                    Element.from("Resize")
                                                        :withStyle({ height = { rel = 1.0 } })
                                                }),
                                            Element.new("div")
                                                :withStyle({
                                                    direction = "row",
                                                    gap = 5,
                                                    width = { rel = 1/2 },
                                                    height = { rel = 1/3 }
                                                })
                                                :withChildren({
                                                    Element.new("div")
                                                        :withStyle({
                                                            bgImage = self.rotateTexture,
                                                            width = { abs = 15 },
                                                            height = { abs = 15 },
                                                            margin = { right = 2 }
                                                        }),
                                                    Element.from("Rotate")
                                                        :withStyle({ height = { rel = 1.0 } })
                                                })
                                        })
                                }),
                            Element.from("Image")
                                :withStyle({
                                    align = "center",
                                    justify = "center",
                                    height = { rel = 0.3 },
                                })
                        }),
                    Element.new("div")
                        :withStyle({
                            direction = "column",
                            width = { abs = 120 },
                            height = { rel = 1.0 },
                            border = { right = { width = 1, color = borderColor } }
                        })
                        :withChildren({
                            Element.new("div")
                                :withStyle({
                                    padding = { top = 3, bottom = 3, left = 3, right = 3 },
                                    height = { rel = 0.7 },
                                    direction = "column",
                                })
                                :withChildren({
                                    Element.new("div")
                                        :withStyle({
                                            direction = "row",
                                            height = { rel = 0.5 },
                                            padding = { bottom = 1 }
                                        })
                                        :withChildren({
                                            Element.new("div")
                                                :withStyle({
                                                    width = { abs = 35 },
                                                    height = { abs = 35 },
                                                    bg = self.selectedTool == "brush" and { r = 0.7, g = 0.7, b = 1.0, a = 1.0 } or { r = 0.9, g = 0.9, b = 0.9, a = 1.0 },
                                                    bgImage = self.brushTexture,
                                                    margin = { right = 1 }
                                                })
                                                :onClick({ type = "ToolClicked", tool = "brush" }),
                                            Element.new("div")
                                                :withStyle({
                                                    width = { abs = 35 },
                                                    height = { abs = 35 },
                                                    bg = self.selectedTool == "eraser" and { r = 0.7, g = 0.7, b = 1.0, a = 1.0 } or { r = 0.9, g = 0.9, b = 0.9, a = 1.0 },
                                                    bgImage = self.eraserTexture,
                                                    margin = { right = 1 }
                                                })
                                                :onClick({ type = "ToolClicked", tool = "eraser" }),
                                            Element.new("div")
                                                :withStyle({
                                                    width = { abs = 35 },
                                                    height = { abs = 35 },
                                                    bg = self.selectedTool == "fill" and { r = 0.7, g = 0.7, b = 1.0, a = 1.0 } or { r = 0.9, g = 0.9, b = 0.9, a = 1.0 },
                                                    bgImage = self.bucketTexture,
                                                })
                                                :onClick({ type = "ToolClicked", tool = "fill" })
                                        }),
                                    Element.new("div")
                                        :withStyle({
                                            direction = "row",
                                            height = { rel = 0.5 },
                                            gap = 3
                                        })
                                        :withChildren({
                                            Element.new("div")
                                                :withStyle({
                                                    width = { abs = 35 },
                                                    height = { abs = 35 },
                                                    bg = self.selectedTool == "pencil" and { r = 0.7, g = 0.7, b = 1.0, a = 1.0 } or { r = 0.9, g = 0.9, b = 0.9, a = 1.0 },
                                                    bgImage = self.pencilTexture,
                                                })
                                                :onClick({ type = "ToolClicked", tool = "pencil" }),
                                            Element.new("div")
                                                :withStyle({
                                                    width = { abs = 35 },
                                                    height = { abs = 35 },
                                                    bg = self.selectedTool == "text" and { r = 0.7, g = 0.7, b = 1.0, a = 1.0 } or { r = 0.9, g = 0.9, b = 0.9, a = 1.0 },
                                                    bgImage = self.textTexture,
                                                })
                                                :onClick({ type = "ToolClicked", tool = "text" }),
                                            Element.new("div")
                                                :withStyle({
                                                    width = { abs = 35 },
                                                    height = { abs = 35 },
                                                    bg = self.selectedTool == "zoom" and { r = 0.7, g = 0.7, b = 1.0, a = 1.0 } or { r = 0.9, g = 0.9, b = 0.9, a = 1.0 },
                                                    bgImage = self.magnifierTexture
                                                })
                                                :onClick({ type = "ToolClicked", tool = "circle" })
                                        })
                                }),
                            Element.from("Tools")
                                :withStyle({
                                    align = "center",
                                    justify = "center",
                                    height = { rel = 0.3 },
                                })
                        }),
                    Element.new("div")
                        :withStyle({
                            direction = "column",
                            width = { abs = 100 },
                            height = { rel = 1.0 },
                            border = { right = { width = 1, color = borderColor } }
                        })
                        :withChildren({
                            Element.new("div")
                                :withStyle({
                                    align = "center",
                                    justify = "center",
                                    padding = { top = 3, bottom = 3, left = 3, right = 3 },
                                    height = { rel = 0.7 }
                                })
                                :withChildren({
                                    Element.new("div")
                                        :withStyle({
                                            width = { abs = 50 },
                                            height = { abs = 50 },
                                            bgImage = self.brushesTexture,
                                        })
                                }),
                            Element.from("Brushes")
                                :withStyle({
                                    align = "center",
                                    justify = "center",
                                    height = { rel = 0.3 },
                                })
                        }),

                    Element.new("div")
                        :withStyle({
                            direction = "column",
                            width = { abs = 300 },
                            height = { rel = 1.0 },
                            border = { right = { width = 1, color = borderColor } }
                        })
                        :withChildren({
                            Element.new("div")
                                :withStyle({
                                    padding = { top = 3, bottom = 3, left = 3, right = 3 },
                                    height = { rel = 0.7 },
                                    direction = "row",
                                    align = "center",
                                    gap = 5
                                })
                                :withChildren({
                                    Element.new("div")
                                        :withStyle({
                                            width = { abs = 40 },
                                            height = { abs = 40 },
                                            bg = self.currentColor,
                                            border = squareBorder,
                                            margin = { right = 5 }
                                        }),
                                    Element.new("div")
                                        :withStyle({
                                            direction = "column",
                                            width = { rel = 2/3 },
                                            justify = "center",
                                        })
                                        :withChildren({
                                            Element.new("div")
                                                :withStyle({
                                                    direction = "row",
                                                    height = { rel = 0.5 }
                                                })
                                                :withChildren({
                                                    Element.new("div")
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 0.0, g = 0.0, b = 0.0, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onClick({ type = "ColorClicked", r = 0.0, g = 0.0, b = 0.0 }),
                                                    Element.new("div")
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 1.0, g = 0.0, b = 0.0, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onClick({ type = "ColorClicked", r = 1.0, g = 0.0, b = 0.0 }),
                                                    Element.new("div")
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 0.0, g = 1.0, b = 0.0, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onClick({ type = "ColorClicked", r = 0.0, g = 1.0, b = 0.0 }),
                                                    Element.new("div")
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 0.0, g = 0.0, b = 1.0, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onClick({ type = "ColorClicked", r = 0.0, g = 0.0, b = 1.0 }),
                                                    Element.new("div")
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 1.0, g = 1.0, b = 0.0, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onClick({ type = "ColorClicked", r = 1.0, g = 1.0, b = 0.0 }),
                                                    Element.new("div")
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 1.0, g = 0.0, b = 1.0, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onClick({ type = "ColorClicked", r = 1.0, g = 0.0, b = 1.0 }),
                                                    Element.new("div")
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 0.0, g = 1.0, b = 1.0, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onClick({ type = "ColorClicked", r = 0.0, g = 1.0, b = 1.0 })
                                                }),
                                            Element.new("div")
                                                :withStyle({
                                                    direction = "row",
                                                    height = { rel = 0.5 }
                                                })
                                                :withChildren({
                                                    Element.new("div")
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 0.5, g = 0.5, b = 0.5, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onClick({ type = "ColorClicked", r = 0.5, g = 0.5, b = 0.5 }),
                                                    Element.new("div")
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 0.5, g = 0.0, b = 0.0, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onClick({ type = "ColorClicked", r = 0.5, g = 0.0, b = 0.0 }),
                                                    Element.new("div")
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 0.0, g = 0.5, b = 0.0, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onClick({ type = "ColorClicked", r = 0.0, g = 0.5, b = 0.0 }),
                                                    Element.new("div")
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 0.0, g = 0.0, b = 0.5, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onClick({ type = "ColorClicked", r = 0.0, g = 0.0, b = 0.5 }),
                                                    Element.new("div")
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 0.5, g = 0.5, b = 0.0, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onClick({ type = "ColorClicked", r = 0.5, g = 0.5, b = 0.0 }),
                                                    Element.new("div")
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 0.5, g = 0.0, b = 0.5, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onClick({ type = "ColorClicked", r = 0.5, g = 0.0, b = 0.5 }),
                                                    Element.new("div")
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 0.0, g = 0.5, b = 0.5, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onClick({ type = "ColorClicked", r = 0.0, g = 0.5, b = 0.5 })
                                                })
                                        })
                                }),
                            Element.from("Colors")
                                :withStyle({
                                    align = "center",
                                    justify = "center",
                                    height = { rel = 0.3 },
                                })
                        })
                }),
            -- Mid section (canvas)
            Element.new("div")
                :withStyle({
                    height = "auto",
                    align = "center",
                    justify = "center",
                    bg = { r = 0.7, g = 0.7, b = 0.8, a = 1.0 },
                })
                :withChildren({
                    Element.new("div")
                        :withStyle({
                            bg = { r = 1, g = 1, b = 1, a = 1 },
                            width = { rel = 0.95 },
                            height = { rel = 0.95 },
                        })
                        :withChildren({
                            Element.new("div")
                                :withStyle({
                                    bgImage = self.canvasTexture,
                                    width = { rel = 1.0 },
                                    height = { rel = 1.0 },
                                })
                                :onMouseDown(function(x, y, elementWidth, elementHeight)
                                    return { type = "StartDrawing", x = x, y = y, elementWidth = elementWidth, elementHeight = elementHeight }
                                end)
                                :onMouseUp({ type = "StopDrawing" })
                                :onMouseMove(function(x, y, elementWidth, elementHeight)
                                    return { type = "Hovered", x = x, y = y, elementWidth = elementWidth, elementHeight = elementHeight }
                                end)
                        })
                }),
            Element.new("div")
                :withStyle({
                    height = { abs = 30 },
                    width = "auto"
                })
                :withChildren({
                    Element.from(string.format("arisu v0.1", self.fps))
                        :withStyle({
                            align = "center",
                            padding = { left = 10 }
                        })
                })
        })
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
---@param window Window
function App:update(message, window)
    if message.type == "StartDrawing" then
        if self.selectedTool == "fill" then
            self.compute:fill(
                (message.x / message.elementWidth) * 800,
                (message.y / message.elementHeight) * 600,
                self.currentColor
            )
        elseif self.selectedTool == "brush" then
            self.compute:stamp(
                (message.x / message.elementWidth) * 800,
                (message.y / message.elementHeight) * 600,
                10,
                self.currentColor
            )

            self.isDrawing = true
        end

        return Task.redraw(window)
    elseif message.type == "StopDrawing" then
        self.isDrawing = false
    elseif message.type == "ColorClicked" then
        self.currentColor = { r = message.r, g = message.g, b = message.b, a = 1.0 }
        return Task.refreshView(window)
    elseif message.type == "ToolClicked" then
        self.selectedTool = message.tool
        return Task.refreshView(window)
    elseif message.type == "ClearClicked" then
        for i = 0, 800 * 600 * 4 - 1 do
            self.canvasBuffer[i] = 255
        end

        local canvasImage = Image.new(800, 600, 4, self.canvasBuffer, "")
        self.textureManager:update(self.canvasTexture, canvasImage)
        self.lastGPUUpdate = os.clock()
    elseif message.type == "FileClicked" then
        local builder = WindowBuilder.new()
            :withTitle("File Picker")
            :withSize(600, 400)

        return Task.openWindow(builder)
    elseif message.type == "Hovered" then
        if self.isDrawing then
            -- TODO: Un-hard code canvas size (800, 600)
            -- Currently it's fine since the canvas won't change size.
            -- Probably want to refactor textureManager to return the info struct instead of just the id.
            if self.selectedTool == "eraser" then
                self.compute:erase(
                    (message.x / message.elementWidth) * 800,
                    (message.y / message.elementHeight) * 600,
                    10
                )
            elseif self.selectedTool == "brush" then
                self.compute:stamp(
                    (message.x / message.elementWidth) * 800,
                    (message.y / message.elementHeight) * 600,
                    10,
                    self.currentColor
                )
            elseif self.selectedTool == "pencil" then
                self.compute:stamp(
                    (message.x / message.elementWidth) * 800,
                    (message.y / message.elementHeight) * 600,
                    1,
                    self.currentColor
                )
            end

            return Task.redraw(window)
        end
    end
end

Arisu.runApp(App.new)
