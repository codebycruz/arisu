local Arisu = require "src.arisu"
local Element = require "src.ui.element"
local Image = require "src.image"
local Bitmap = require "src.font.bitmap"
local Task = require "src.task"
local window = require "src.window"
local ffi = require("ffi")

---@alias Message
--- | { type: "BrushClicked" }
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
---@field jbmFont Bitmap
---@field canvasBuffer userdata
---@field isDrawing boolean
---@field lastGPUUpdate number
---@field gpuUpdateInterval number
---@field fps number
---@field lastFrameTime number
---@field currentColor {r: number, g: number, b: number}
---@field selectedTool string
local App = {}
App.__index = App

---@param windowId number
function App:view(windowId)
    local borderColor = { r = 0.8, g = 0.8, b = 0.8, a = 1 }
    local squareBorder = {
        top = { width = 1, color = borderColor },
        bottom = { width = 1, color = borderColor },
        left = { width = 1, color = borderColor },
        right = { width = 1, color = borderColor }
    }

    return Element.Div.new()
        :withStyle({
            direction = "column",
            bg = { r = 0.95, g = 0.95, b = 0.95, a = 1.0 }
        })
        :withChildren(
            -- Menu bar
            Element.Div.new()
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
                :withChildren(
                    Element.Text.from("File", self.jbmFont)
                        :withStyle({ width = { abs = 50 } })
                        :onMouseDown({ type = "FileClicked" }),
                    Element.Text.from("Edit", self.jbmFont)
                        :withStyle({ width = { abs = 50 } }),
                    Element.Text.from("View", self.jbmFont)
                        :withStyle({ width = { abs = 50 } }),
                    Element.Text.from("Clear", self.jbmFont)
                        :withStyle({ width = { abs = 50 } })
                        :onMouseDown({ type = "ClearClicked" })
                ),
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
                            Element.Div.new()
                                :withStyle({
                                    padding = { top = 6, bottom = 6, left = 6, right = 6 },
                                    height = { rel = 0.7 },
                                    gap = 16,
                                    direction = "row"
                                })
                                :withChildren(
                                    Element.Div.new()
                                        :withStyle({
                                            direction = "column",
                                            width = { rel = 1/3 },
                                            height = { rel = 1.0 },
                                            gap = 8,
                                        })
                                        :withChildren(
                                            Element.Div.new()
                                                :withStyle({
                                                    bgImage = self.pasteTexture,
                                                    height = { rel = 2/3 }
                                                }),
                                            Element.Text.from("Paste", self.jbmFont)
                                                :withStyle({ height = { rel = 1/3 } })
                                        ),
                                    Element.Div.new()
                                        :withStyle({
                                            direction = "column",
                                            width = { rel = 1/2 },
                                            height = { rel = 1 },
                                            gap = 2
                                        })
                                        :withChildren(
                                            Element.Div.new()
                                                :withStyle({
                                                    direction = "row",
                                                    gap = 5,
                                                    width = { rel = 1/2 },
                                                    height = { rel = 1/3 }
                                                })
                                                :withChildren(
                                                    Element.Div.new()
                                                        :withStyle({
                                                            bgImage = self.cutTexture,
                                                            width = { abs = 15 },
                                                            height = { abs = 15 },
                                                            margin = { right = 2 }
                                                        }),
                                                    Element.Text.from("Cut", self.jbmFont)
                                                        :withStyle({ height = { rel = 1.0 } })
                                                ),
                                            Element.Div.new()
                                                :withStyle({
                                                    direction = "row",
                                                    gap = 5,
                                                    width = { rel = 1/2 },
                                                    height = { rel = 1/3 }
                                                })
                                                :withChildren(
                                                    Element.Div.new()
                                                        :withStyle({
                                                            bgImage = self.copyTexture,
                                                            width = { abs = 15 },
                                                            height = { abs = 15 },
                                                            margin = { right = 2 }
                                                        }),
                                                    Element.Text.from("Copy", self.jbmFont)
                                                        :withStyle({ height = { rel = 1.0 } })
                                                )
                                        )
                                ),
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
                            Element.Div.new()
                                :withStyle({
                                    padding = { top = 3, bottom = 3, left = 3, right = 3 },
                                    height = { rel = 0.7 },
                                    gap = 16,
                                    direction = "row"
                                })
                                :withChildren(
                                    Element.Div.new()
                                        :withStyle({
                                            direction = "column",
                                            width = { rel = 1/3 },
                                            height = { rel = 1.0 },
                                            gap = 8,
                                        })
                                        :withChildren(
                                            Element.Div.new()
                                                :withStyle({
                                                    border = squareBorder,
                                                    bgImage = self.selectTexture,
                                                    height = { rel = 2/3 }
                                                }),
                                            Element.Text.from("Select", self.jbmFont)
                                                :withStyle({ height = { rel = 1/3 } })
                                        ),
                                    Element.Div.new()
                                        :withStyle({
                                            direction = "column",
                                            width = { rel = 1/2 },
                                            height = { rel = 1.0 },
                                            gap = 2
                                        })
                                        :withChildren(
                                            Element.Div.new()
                                                :withStyle({
                                                    direction = "row",
                                                    gap = 5,
                                                    width = { rel = 1/2 },
                                                    height = { rel = 1/3 }
                                                })
                                                :withChildren(
                                                    Element.Div.new()
                                                        :withStyle({
                                                            bgImage = self.cropTexture,
                                                            width = { abs = 15 },
                                                            height = { abs = 15 },
                                                            margin = { right = 2 }
                                                        }),
                                                    Element.Text.from("Crop", self.jbmFont)
                                                        :withStyle({ height = { rel = 1.0 } })
                                                ),
                                            Element.Div.new()
                                                :withStyle({
                                                    direction = "row",
                                                    gap = 5,
                                                    width = { rel = 1/2 },
                                                    height = { rel = 1/3 }
                                                })
                                                :withChildren(
                                                    Element.Div.new()
                                                        :withStyle({
                                                            bgImage = self.resizeTexture,
                                                            width = { abs = 15 },
                                                            height = { abs = 15 },
                                                            margin = { right = 2 }
                                                        }),
                                                    Element.Text.from("Resize", self.jbmFont)
                                                        :withStyle({ height = { rel = 1.0 } })
                                                ),
                                            Element.Div.new()
                                                :withStyle({
                                                    direction = "row",
                                                    gap = 5,
                                                    width = { rel = 1/2 },
                                                    height = { rel = 1/3 }
                                                })
                                                :withChildren(
                                                    Element.Div.new()
                                                        :withStyle({
                                                            bgImage = self.rotateTexture,
                                                            width = { abs = 15 },
                                                            height = { abs = 15 },
                                                            margin = { right = 2 }
                                                        }),
                                                    Element.Text.from("Rotate", self.jbmFont)
                                                        :withStyle({ height = { rel = 1.0 } })
                                                )
                                        )
                                ),
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
                            width = { abs = 120 },
                            height = { rel = 1.0 },
                            border = { right = { width = 1, color = borderColor } }
                        })
                        :withChildren(
                            Element.Div.new()
                                :withStyle({
                                    padding = { top = 3, bottom = 3, left = 3, right = 3 },
                                    height = { rel = 0.7 },
                                    direction = "column",
                                })
                                :withChildren(
                                    Element.Div.new()
                                        :withStyle({
                                            direction = "row",
                                            height = { rel = 0.5 },
                                            padding = { bottom = 1 }
                                        })
                                        :withChildren(
                                            Element.Div.new()
                                                :withStyle({
                                                    width = { abs = 35 },
                                                    height = { abs = 35 },
                                                    bg = self.selectedTool == "brush" and { r = 0.7, g = 0.7, b = 1.0, a = 1.0 } or { r = 0.9, g = 0.9, b = 0.9, a = 1.0 },
                                                    bgImage = self.brushTexture,
                                                    margin = { right = 1 }
                                                })
                                                :onMouseDown({ type = "ToolClicked", tool = "brush" }),
                                            Element.Div.new()
                                                :withStyle({
                                                    width = { abs = 35 },
                                                    height = { abs = 35 },
                                                    bg = self.selectedTool == "eraser" and { r = 0.7, g = 0.7, b = 1.0, a = 1.0 } or { r = 0.9, g = 0.9, b = 0.9, a = 1.0 },
                                                    bgImage = self.eraserTexture,
                                                    margin = { right = 1 }
                                                })
                                                :onMouseDown({ type = "ToolClicked", tool = "eraser" }),
                                            Element.Div.new()
                                                :withStyle({
                                                    width = { abs = 35 },
                                                    height = { abs = 35 },
                                                    bg = self.selectedTool == "fill" and { r = 0.7, g = 0.7, b = 1.0, a = 1.0 } or { r = 0.9, g = 0.9, b = 0.9, a = 1.0 },
                                                    bgImage = self.bucketTexture,
                                                })
                                                :onMouseDown({ type = "ToolClicked", tool = "fill" })
                                        ),
                                    Element.Div.new()
                                        :withStyle({
                                            direction = "row",
                                            height = { rel = 0.5 },
                                            gap = 3
                                        })
                                        :withChildren(
                                            Element.Div.new()
                                                :withStyle({
                                                    width = { abs = 35 },
                                                    height = { abs = 35 },
                                                    bg = self.selectedTool == "pencil" and { r = 0.7, g = 0.7, b = 1.0, a = 1.0 } or { r = 0.9, g = 0.9, b = 0.9, a = 1.0 },
                                                    bgImage = self.pencilTexture,
                                                })
                                                :onMouseDown({ type = "ToolClicked", tool = "pencil" }),
                                            Element.Div.new()
                                                :withStyle({
                                                    width = { abs = 35 },
                                                    height = { abs = 35 },
                                                    bg = self.selectedTool == "text" and { r = 0.7, g = 0.7, b = 1.0, a = 1.0 } or { r = 0.9, g = 0.9, b = 0.9, a = 1.0 },
                                                    bgImage = self.textTexture,
                                                })
                                                :onMouseDown({ type = "ToolClicked", tool = "text" }),
                                            Element.Div.new()
                                                :withStyle({
                                                    width = { abs = 35 },
                                                    height = { abs = 35 },
                                                    bg = self.selectedTool == "zoom" and { r = 0.7, g = 0.7, b = 1.0, a = 1.0 } or { r = 0.9, g = 0.9, b = 0.9, a = 1.0 },
                                                    bgImage = self.magnifierTexture
                                                })
                                                :onMouseDown({ type = "ToolClicked", tool = "circle" })
                                        )
                                ),
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
                            Element.Div.new()
                                :withStyle({
                                    align = "center",
                                    justify = "center",
                                    padding = { top = 3, bottom = 3, left = 3, right = 3 },
                                    height = { rel = 0.7 }
                                })
                                :withChildren(
                                    Element.Div.new()
                                        :withStyle({
                                            width = { abs = 50 },
                                            height = { abs = 50 },
                                            bgImage = self.brushesTexture,
                                        })
                                ),
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
                            Element.Div.new()
                                :withStyle({
                                    padding = { top = 3, bottom = 3, left = 3, right = 3 },
                                    height = { rel = 0.7 },
                                    bg = { r = 0.9, g = 0.9, b = 0.9, a = 1.0 },
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
                            width = { abs = 300 },
                            height = { rel = 1.0 },
                            border = { right = { width = 1, color = borderColor } }
                        })
                        :withChildren(
                            Element.Div.new()
                                :withStyle({
                                    padding = { top = 3, bottom = 3, left = 3, right = 3 },
                                    height = { rel = 0.7 },
                                    direction = "row",
                                    align = "center",
                                    gap = 5
                                })
                                :withChildren(
                                    Element.Div.new()
                                        :withStyle({
                                            width = { abs = 40 },
                                            height = { abs = 40 },
                                            bg = self.currentColor,
                                            border = squareBorder,
                                            margin = { right = 5 }
                                        }),
                                    Element.Div.new()
                                        :withStyle({
                                            direction = "column",
                                            width = { rel = 2/3 },
                                            justify = "center",
                                        })
                                        :withChildren(
                                            Element.Div.new()
                                                :withStyle({
                                                    direction = "row",
                                                    height = { rel = 0.5 }
                                                })
                                                :withChildren(
                                                    Element.Div.new()
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 0.0, g = 0.0, b = 0.0, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onMouseDown({ type = "ColorClicked", r = 0.0, g = 0.0, b = 0.0 }),
                                                    Element.Div.new()
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 1.0, g = 0.0, b = 0.0, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onMouseDown({ type = "ColorClicked", r = 1.0, g = 0.0, b = 0.0 }),
                                                    Element.Div.new()
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 0.0, g = 1.0, b = 0.0, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onMouseDown({ type = "ColorClicked", r = 0.0, g = 1.0, b = 0.0 }),
                                                    Element.Div.new()
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 0.0, g = 0.0, b = 1.0, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onMouseDown({ type = "ColorClicked", r = 0.0, g = 0.0, b = 1.0 }),
                                                    Element.Div.new()
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 1.0, g = 1.0, b = 0.0, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onMouseDown({ type = "ColorClicked", r = 1.0, g = 1.0, b = 0.0 }),
                                                    Element.Div.new()
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 1.0, g = 0.0, b = 1.0, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onMouseDown({ type = "ColorClicked", r = 1.0, g = 0.0, b = 1.0 }),
                                                    Element.Div.new()
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 0.0, g = 1.0, b = 1.0, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onMouseDown({ type = "ColorClicked", r = 0.0, g = 1.0, b = 1.0 })
                                                ),
                                            Element.Div.new()
                                                :withStyle({
                                                    direction = "row",
                                                    height = { rel = 0.5 }
                                                })
                                                :withChildren(
                                                    Element.Div.new()
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 0.5, g = 0.5, b = 0.5, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onMouseDown({ type = "ColorClicked", r = 0.5, g = 0.5, b = 0.5 }),
                                                    Element.Div.new()
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 0.5, g = 0.0, b = 0.0, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onMouseDown({ type = "ColorClicked", r = 0.5, g = 0.0, b = 0.0 }),
                                                    Element.Div.new()
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 0.0, g = 0.5, b = 0.0, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onMouseDown({ type = "ColorClicked", r = 0.0, g = 0.5, b = 0.0 }),
                                                    Element.Div.new()
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 0.0, g = 0.0, b = 0.5, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onMouseDown({ type = "ColorClicked", r = 0.0, g = 0.0, b = 0.5 }),
                                                    Element.Div.new()
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 0.5, g = 0.5, b = 0.0, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onMouseDown({ type = "ColorClicked", r = 0.5, g = 0.5, b = 0.0 }),
                                                    Element.Div.new()
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 0.5, g = 0.0, b = 0.5, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onMouseDown({ type = "ColorClicked", r = 0.5, g = 0.0, b = 0.5 }),
                                                    Element.Div.new()
                                                        :withStyle({
                                                            width = { abs = 30 },
                                                            height = { abs = 30 },
                                                            bg = { r = 0.0, g = 0.5, b = 0.5, a = 1.0 },
                                                            border = squareBorder,
                                                            margin = { all = 1 }
                                                        })
                                                        :onMouseDown({ type = "ColorClicked", r = 0.0, g = 0.5, b = 0.5 })
                                                )
                                        )
                                ),
                            Element.Text.from("Colors", self.jbmFont)
                                :withStyle({
                                    align = "center",
                                    justify = "center",
                                    height = { rel = 0.3 },
                                })
                        )
                ),
            -- Mid section (canvas)
            Element.Div.new()
                :withStyle({
                    height = "auto",
                    align = "center",
                    justify = "center",
                    bg = { r = 0.7, g = 0.7, b = 0.8, a = 1.0 },
                })
                :withChildren(
                    Element.Div.new()
                        :withStyle({
                            bg = { r = 1, g = 1, b = 1, a = 1 },
                            width = { rel = 0.95 },
                            height = { rel = 0.95 },
                        })
                        :withChildren(
                            Element.Div.new()
                                :withStyle({
                                    bgImage = self.canvasTexture,
                                    width = { rel = 1.0 },
                                    height = { rel = 1.0 },
                                })
                                :onMouseDown({ type = "StartDrawing" })
                                :onMouseUp({ type = "StopDrawing" })
                                :onMouseMove(function(x, y, elementWidth, elementHeight)
                                    return { type = "Hovered", x = x, y = y, elementWidth = elementWidth, elementHeight = elementHeight }
                                end)
                        )
                ),
            Element.Div.new()
                :withStyle({
                    height = { abs = 30 },
                    width = "auto"
                })
                :withChildren(
                    Element.Text.from(string.format("arisu v0.1", self.fps), self.jbmFont)
                        :withStyle({
                            align = "center",
                            padding = { left = 10 }
                        })
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
---@param windowId number
function App:update(message, windowId)
    if message.type == "BrushClicked" then
    elseif message.type == "StartDrawing" then
        self.isDrawing = true
    elseif message.type == "StopDrawing" then
        self.isDrawing = false
        local canvasImage = Image.new(800, 600, 4, self.canvasBuffer, "")
        self.textureManager:update(self.canvasTexture, canvasImage)
        self.lastGPUUpdate = os.clock()
    elseif message.type == "ColorClicked" then
        self.currentColor = { r = message.r, g = message.g, b = message.b, a = 1.0 }
        return Task.refreshView()
    elseif message.type == "ToolClicked" then
        self.selectedTool = message.tool
        return Task.refreshView()
    elseif message.type == "ClearClicked" then
        for i = 0, 800 * 600 * 4 - 1 do
            self.canvasBuffer[i] = 255
        end

        local canvasImage = Image.new(800, 600, 4, self.canvasBuffer, "")
        self.textureManager:update(self.canvasTexture, canvasImage)
        self.lastGPUUpdate = os.clock()
    elseif message.type == "FileClicked" then
        local builder = window.WindowBuilder.new()
            :withTitle("Hi")
            :withSize(600, 400)

        return Task.openWindow(builder)
    elseif message.type == "Hovered" then
        if self.isDrawing then
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
                                if self.selectedTool == "eraser" then
                                    self.canvasBuffer[index + 3] = 0
                                else
                                    self.canvasBuffer[index + 0] = math.floor(self.currentColor.r * 255)
                                    self.canvasBuffer[index + 1] = math.floor(self.currentColor.g * 255)
                                    self.canvasBuffer[index + 2] = math.floor(self.currentColor.b * 255)
                                    self.canvasBuffer[index + 3] = 255
                                end
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
end

Arisu.runApp(function(textureManager)
    local this = setmetatable({}, App)
    this.isDrawing = false
    this.textureManager = textureManager
    this.lastGPUUpdate = 0
    this.gpuUpdateInterval = 1.0 / 30
    this.fps = 60
    this.lastFrameTime = 0
    this.currentColor = { r = 0.0, g = 0.0, b = 0.0, a = 1.0 }
    this.selectedTool = "brush"

    local patternImage = assert(Image.fromPath("assets/gradient.qoi"), "Failed to load pattern image")
    this.patternTexture = textureManager:upload(patternImage)

    local qoiImage = assert(Image.fromPath("assets/airman.qoi"), "Failed to load QOI image")
    this.qoiTexture = textureManager:upload(qoiImage)

    local characters = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
    local jbmFont = assert(Bitmap.fromPath({ ymargin = 2, xmargin = 4, gridWidth = 18, gridHeight = 18, characters = characters, perRow = 19 }, "assets/JetBrainsMono.qoi"), "Failed to load bitmap font")
    textureManager:upload(jbmFont.image)
    this.jbmFont = jbmFont

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

    return this
end)
