local Arisu = require "src.arisu"
local Element = require "src.ui.element"
local Image = require "src.image"
local Task = require "src.task"
local Compute = require "src.tools.compute"
local FilePicker = require "src.tools.file_picker"
local WindowStateManager = require "src.tools.window_state"

local WindowBuilder = (require "src.window").WindowBuilder

local ffi = require("ffi")

---@alias Tool "brush" | "eraser" | "fill" | "pencil" | "text" | "select"

---@alias Message
--- | { type: "EraserClicked" }
--- | { type: "ColorClicked", r: number, g: number, b: number }
--- | { type: "ToolClicked", tool: Tool }
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
---@field currentColor {r: number, g: number, b: number, a: number}
---@field selectedTool string
---@field selectStart { x: number, y: number }|nil
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
    this.pendingFilePickerState = nil

    return this
end

---@param window Window
function App:view(window)
    if window ~= self.mainWindow then
        local state = WindowStateManager.getState(window)
        local windowType = WindowStateManager.getType(window)

        if windowType == "file_picker" and state then
            return FilePicker.view(state)
        else
            -- Default view for unknown window types
            return Element.new("div")
                :withStyle({
                    direction = "column",
                    bg = { r = 0.9, g = 0.9, b = 0.9, a = 1 },
                    padding = { top = 20, bottom = 20, left = 20, right = 20 }
                })
                :withChildren({
                    Element.from("Unknown window type")
                })
        end
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
                    Element.from("Open")
                        :withStyle({ width = { abs = 50 } })
                        :onClick({ type = "OpenClicked" }),
                    Element.from("Save")
                        :withStyle({ width = { abs = 50 } })
                        :onClick({ type = "SaveClicked" }),
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
                                                })
                                                :onClick({ type = "ToolClicked", tool = "select" }),
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
                                                            position = "relative",
                                                            left = 5,
                                                            zIndex = 2,
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
                                :onMouseUp(function(x, y, elementWidth, elementHeight)
                                    return { type = "StopDrawing", x = x, y = y, elementWidth = elementWidth, elementHeight = elementHeight }
                                end)
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
                    Element.from("arisu v0.1")
                        :withStyle({
                            align = "center",
                            padding = { left = 10 }
                        })
                })
        })
end

---@param event Event
function App:event(event)
    if event.name == "map" and self.pendingFilePickerState then
        WindowStateManager.setState(event.window, "file_picker", self.pendingFilePickerState)
        self.pendingFilePickerState = nil
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
        elseif self.selectedTool == "select" then
            local x = (message.x / message.elementWidth) * 800
            local y = (message.y / message.elementHeight) * 600

            self.selectStart = { x = x, y = y }
        end

        return Task.redraw(window)
    elseif message.type == "StopDrawing" then
        if self.selectedTool == "select" and self.selectStart then
            local x = (message.x / message.elementWidth) * 800
            local y = (message.y / message.elementHeight) * 600

            if self.selectStart.x == x and self.selectStart.y == y then
                -- Click without drag, clear selection
                self.compute:resetSelection()
            else
                self.compute:setSelection(
                    math.min(self.selectStart.x, x),
                    math.min(self.selectStart.y, y),
                    math.max(self.selectStart.x, x),
                    math.max(self.selectStart.y, y)
                )
            end

            self.selectStart = nil
        end

        self.isDrawing = false
    elseif message.type == "ColorClicked" then
        self.currentColor = { r = message.r, g = message.g, b = message.b, a = 1.0 }
        return Task.refreshView(window)
    elseif message.type == "ToolClicked" then
        if message.tool == "select" then
            self.compute:resetSelection()
        end

        self.selectedTool = message.tool
        return Task.refreshView(window)
    elseif message.type == "ClearClicked" then
        for i = 0, 800 * 600 * 4 - 1 do
            self.canvasBuffer[i] = 255
        end

        local canvasImage = Image.new(800, 600, 4, self.canvasBuffer, "")
        self.textureManager:update(self.canvasTexture, canvasImage)
        return Task.redraw(self.mainWindow)
    elseif message.type == "OpenClicked" then
        local builder = WindowBuilder.new()
            :withTitle("Open File")
            :withSize(600, 400)

        self.pendingFilePickerState = FilePicker.new("open", ".", function(filePath)
            local image, err = Image.fromPath(filePath)
            if image then
                if image.width == 800 and image.height == 600 and image.channels == 4 then
                    -- Direct copy if dimensions match
                    ffi.copy(self.canvasBuffer, image.pixels, 800 * 600 * 4)
                else
                    -- Clear canvas first
                    for i = 0, 800 * 600 * 4 - 1 do
                        self.canvasBuffer[i] = 255
                    end
                    -- Simple center placement for different sized images
                    local startX = math.max(0, math.floor((800 - image.width) / 2))
                    local startY = math.max(0, math.floor((600 - image.height) / 2))
                    local endX = math.min(800, startX + image.width)
                    local endY = math.min(600, startY + image.height)

                    for y = startY, endY - 1 do
                        for x = startX, endX - 1 do
                            local srcIndex = ((y - startY) * image.width + (x - startX)) * image.channels
                            local dstIndex = (y * 800 + x) * 4

                            if image.channels == 4 then
                                self.canvasBuffer[dstIndex] = image.pixels[srcIndex]
                                self.canvasBuffer[dstIndex + 1] = image.pixels[srcIndex + 1]
                                self.canvasBuffer[dstIndex + 2] = image.pixels[srcIndex + 2]
                                self.canvasBuffer[dstIndex + 3] = image.pixels[srcIndex + 3]
                            elseif image.channels == 3 then
                                self.canvasBuffer[dstIndex] = image.pixels[srcIndex]
                                self.canvasBuffer[dstIndex + 1] = image.pixels[srcIndex + 1]
                                self.canvasBuffer[dstIndex + 2] = image.pixels[srcIndex + 2]
                                self.canvasBuffer[dstIndex + 3] = 255
                            end
                        end
                    end
                end

                local canvasImage = Image.new(800, 600, 4, self.canvasBuffer, "")
                self.textureManager:update(self.canvasTexture, canvasImage)

                return Task.redraw(self.mainWindow)
            else
                print("Failed to load image: " .. (err or "unknown error"))
            end
        end, function()
            print("Open cancelled")
        end)

        return Task.openWindow(builder)
    elseif message.type == "SaveClicked" then
        local builder = WindowBuilder.new()
            :withTitle("Save File")
            :withSize(600, 400)

        self.pendingFilePickerState = FilePicker.new("save", ".", function(filePath)
            -- Ensure file has .qoi extension
            local saveFilePath = filePath
            if not saveFilePath:match("%.qoi$") then
                saveFilePath = saveFilePath .. ".qoi"
            end

            -- Create image from canvas buffer
            local canvasImage = Image.new(800, 600, 4, self.canvasBuffer, "")

            -- Save the image
            local success, err = pcall(function()
                local file = assert(io.open(saveFilePath, "wb"))
                file:write(canvasImage:toQOI())
                file:close()
            end)

            if success then
                print("Saved canvas to: " .. saveFilePath)
            else
                print("Failed to save canvas: " .. tostring(err))
            end
        end, function()
            print("Save cancelled")
        end)

        return Task.openWindow(builder)
    elseif WindowStateManager.hasState(window) then
        local state = WindowStateManager.getState(window)
        local windowType = WindowStateManager.getType(window)

        if windowType == "file_picker" then
            local result = FilePicker.update(state, message, window)
            if result and result.variant == "closeWindow" then
                WindowStateManager.removeState(window)
            end
            return result
        end
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
