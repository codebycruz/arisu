package.path = package.path .. ";./src/?.lua"

local Arisu = require("arisu")
local Element = require("ui.element")
local Image = require("image")
local Task = require("task")
local Audio = require("audio")
-- local SoundManager = require("sound_manager")

local WindowBuilder = (require("window")).WindowBuilder

local ffi = require("ffi")

---@alias Tool "brush" | "eraser" | "fill" | "pencil" | "text" | "select" | "square" | "circle" | "line" | "curve"

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

---@alias Action
--- | { tool: "select", start: { x: number, y: number }?, finish: { x: number, y: number }? }
--- | { tool: "line", start: { x: number, y: number }?, finish: { x: number, y: number }? }
--- | { tool: Tool }

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
---@field squareTexture Texture
---@field circleTexture Texture
---@field lineTexture Texture
---@field curveTexture Texture
---@field popAudio Audio
---@field textureManager TextureManager
---@field fontManager FontManager
---@field soundManager SoundManager
---@field compute Compute
---@field mainWindow Window
---@field canvasBuffer userdata
---@field isDrawing boolean
---@field currentColor {r: number, g: number, b: number, a: number}
---@field currentAction Action
local App = {}
App.__index = App

---@param window Window
---@param textureManager TextureManager
---@param fontManager FontManager
function App.new(window, textureManager, fontManager)
	local Compute = require("tools.compute")
	window:setTitle("Arisu")

	local arisuImage = assert(Image.fromPath("assets/icons/brushes.qoi"), "Failed to load window icon")
	window:setIcon(arisuImage)

	local this = setmetatable({}, App)
	this.isDrawing = false
	this.textureManager = textureManager
	this.fontManager = fontManager
	this.currentColor = { r = 0.0, g = 0.0, b = 0.0, a = 1.0 }
	this.currentAction = { tool = "brush" }

	local brushImage = assert(Image.fromPath("assets/icons/paintbrush.qoi"), "Failed to load brush image")
	this.brushTexture = textureManager:upload(brushImage)

	local bucketImage = assert(Image.fromPath("assets/icons/paintcan.qoi"), "Failed to load bucket image")
	this.bucketTexture = textureManager:upload(bucketImage)

	local paletteImage = assert(Image.fromPath("assets/icons/palette.qoi"), "Failed to load palette image")
	this.paletteTexture = textureManager:upload(paletteImage)

	local pencilImage = assert(Image.fromPath("assets/icons/pencil.qoi"), "Failed to load pencil image")
	this.pencilTexture = textureManager:upload(pencilImage)

	local textImage = assert(Image.fromPath("assets/icons/text.qoi"), "Failed to load text image")
	this.textTexture = textureManager:upload(textImage)

	local eraserImage = assert(Image.fromPath("assets/icons/david/eraser.qoi"), "Failed to load eraser image")
	this.eraserTexture = textureManager:upload(eraserImage)

	local magnifierImage = assert(Image.fromPath("assets/icons/magnifier.qoi"), "Failed to load magnifier image")
	this.magnifierTexture = textureManager:upload(magnifierImage)

	local pasteImage = assert(Image.fromPath("assets/icons/paste.qoi"), "Failed to load paste image")
	this.pasteTexture = textureManager:upload(pasteImage)

	local selectImage = assert(Image.fromPath("assets/icons/select.qoi"), "Failed to load select image")
	this.selectTexture = textureManager:upload(selectImage)

	local soundImage = assert(Image.fromPath("assets/icons/sound.qoi"), "Failed to load sound image")
	this.soundTexture = textureManager:upload(soundImage)

	local soundMuteImage = assert(Image.fromPath("assets/icons/sound_mute.qoi"), "Failed to load sound mute image")
	this.soundMuteTexture = textureManager:upload(soundMuteImage)

	local copyImage = assert(Image.fromPath("assets/icons/copy.qoi"), "Failed to load copy image")
	this.copyTexture = textureManager:upload(copyImage)

	local cutImage = assert(Image.fromPath("assets/icons/cut.qoi"), "Failed to load cut image")
	this.cutTexture = textureManager:upload(cutImage)

	local cropImage = assert(Image.fromPath("assets/icons/crop.qoi"), "Failed to load crop image")
	this.cropTexture = textureManager:upload(cropImage)

	local resizeImage = assert(Image.fromPath("assets/icons/resize.qoi"), "Failed to load resize image")
	this.resizeTexture = textureManager:upload(resizeImage)

	local rotateImage = assert(Image.fromPath("assets/icons/rotate.qoi"), "Failed to load rotate image")
	this.rotateTexture = textureManager:upload(rotateImage)

	local brushesImage = assert(Image.fromPath("assets/icons/brushes.qoi"), "Failed to load brushes image")
	this.brushesTexture = textureManager:upload(brushesImage)

	local squareImage = assert(Image.fromPath("assets/icons/david/square.qoi"), "Failed to load square image")
	this.squareTexture = textureManager:upload(squareImage)

	local circleImage = assert(Image.fromPath("assets/icons/david/circle.qoi"), "Failed to load circle image")
	this.circleTexture = textureManager:upload(circleImage)

	local lineImage = assert(Image.fromPath("assets/icons/david/line.qoi"), "Failed to load line image")
	this.lineTexture = textureManager:upload(lineImage)

	local curveImage = assert(Image.fromPath("assets/icons/david/curve.qoi"), "Failed to load curve image")
	this.curveTexture = textureManager:upload(curveImage)

	this.canvasBuffer = ffi.new("uint8_t[?]", 800 * 600 * 4)
	for i = 0, 800 * 600 * 4 - 1 do
		this.canvasBuffer[i] = 255
	end

	local canvasImage = Image.new(800, 600, 4, this.canvasBuffer, "")
	this.canvasTexture = textureManager:upload(canvasImage)

	local compute = Compute.new(textureManager, this.canvasTexture)
	this.compute = compute

	this.mainWindow = window

	-- this.soundManager = SoundManager.new()
	this.popAudio = assert(Audio.fromPath("assets/sounds/pop.wav"), "Failed to load sound")

	return this
end

---@param window Window
function App:view(window)
	local disabledColor = { r = 0.7, g = 0.7, b = 0.7, a = 1.0 }
	local selectedColor = { r = 0.7, g = 0.7, b = 1.0, a = 1.0 }
	local borderColor = { r = 0.8, g = 0.8, b = 0.8, a = 1 }
	local squareBorder = {
		top = { width = 1, color = borderColor },
		bottom = { width = 1, color = borderColor },
		left = { width = 1, color = borderColor },
		right = { width = 1, color = borderColor },
	}

	local function toolBg(tool)
		if tool == "zoom" or tool == "text" then
			return disabledColor
		end

		if self.currentAction.tool == tool then
			return selectedColor
		else
			return { r = 0.9, g = 0.9, b = 0.9, a = 1.0 }
		end
	end

	return Element.new("div")
		:withStyle({
			direction = "column",
			bg = { r = 0.95, g = 0.95, b = 0.95, a = 1.0 },
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
						bottom = { width = 1, color = borderColor },
					},
				})
				:withChildren({
					Element.from("Open"):withStyle({ width = { abs = 50 } }):onClick({ type = "OpenClicked" }),
					Element.from("Save"):withStyle({ width = { abs = 50 } }):onClick({ type = "SaveClicked" }),
					Element.from("Edit"):withStyle({ fg = disabledColor, width = { abs = 50 } }),
					Element.from("View"):withStyle({ fg = disabledColor, width = { abs = 50 } }),
					Element.from("Clear"):withStyle({ width = { abs = 50 } }):onClick({ type = "ClearClicked" }),
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
							border = { right = { width = 1, color = borderColor } },
						})
						:withChildren({
							Element.new("div")
								:withStyle({
									padding = { top = 6, bottom = 6, left = 6, right = 6 },
									height = { rel = 0.7 },
									gap = 16,
									direction = "row",
								})
								:withChildren({
									Element.new("div")
										:withStyle({
											direction = "column",
											width = { rel = 1 / 3 },
											height = { rel = 1.0 },
											gap = 8,
										})
										:withChildren({
											Element.new("div"):withStyle({
												bgImage = self.pasteTexture,
												height = { rel = 2 / 3 },
											}),
											Element.from("Paste"):withStyle({ fg = disabledColor, height = { rel = 1 / 3 } }),
										}),
									Element.new("div")
										:withStyle({
											direction = "column",
											width = { rel = 1 / 2 },
											height = { rel = 1 },
											gap = 2,
										})
										:withChildren({
											Element.new("div")
												:withStyle({
													direction = "row",
													gap = 5,
													width = { rel = 1 / 2 },
													height = { rel = 1 / 3 },
												})
												:withChildren({
													Element.new("div"):withStyle({
														bgImage = self.cutTexture,
														width = { abs = 15 },
														height = { abs = 15 },
														margin = { right = 2 },
													}),
													Element.from("Cut")
														:withStyle({ fg = disabledColor, height = { rel = 1.0 } }),
												}),
											Element.new("div")
												:withStyle({
													direction = "row",
													gap = 5,
													width = { rel = 1 / 2 },
													height = { rel = 1 / 3 },
												})
												:withChildren({
													Element.new("div"):withStyle({
														bgImage = self.copyTexture,
														width = { abs = 15 },
														height = { abs = 15 },
														margin = { right = 2 },
													}),
													Element.from("Copy")
														:withStyle({ fg = disabledColor, height = { rel = 1.0 } }),
												}),
										}),
								}),
							Element.from("Clipboard"):withStyle({
								align = "center",
								justify = "center",
								fg = disabledColor,
								height = { rel = 0.3 },
							}),
						}),
					Element.new("div")
						:withStyle({
							direction = "column",
							width = { abs = 180 },
							height = { rel = 1.0 },
							border = { right = { width = 1, color = borderColor } },
						})
						:withChildren({
							Element.new("div")
								:withStyle({
									padding = { top = 3, bottom = 3, left = 3, right = 3 },
									height = { rel = 0.7 },
									gap = 16,
									direction = "row",
								})
								:withChildren({
									Element.new("div")
										:withStyle({
											direction = "column",
											width = { rel = 1 / 3 },
											height = { rel = 1.0 },
											gap = 8,
										})
										:withChildren({
											Element.new("div")
												:withStyle({
													border = squareBorder,
													bgImage = self.selectTexture,
													height = { rel = 2 / 3 },
												})
												:onClick({ type = "ToolClicked", tool = "select" }),
											Element.from("Select"):withStyle({ height = { rel = 1 / 3 } }),
										}),
									Element.new("div")
										:withStyle({
											direction = "column",
											width = { rel = 1 / 2 },
											height = { rel = 1.0 },
											gap = 2,
										})
										:withChildren({
											Element.new("div")
												:withStyle({
													direction = "row",
													gap = 5,
													width = { rel = 1 / 2 },
													height = { rel = 1 / 3 },
												})
												:withChildren({
													Element.new("div"):withStyle({
														bgImage = self.cropTexture,
														width = { abs = 15 },
														height = { abs = 15 },
														margin = { right = 2 },
													}),
													Element.from("Crop")
														:withStyle({ fg = disabledColor, height = { rel = 1.0 } }),
												}),
											Element.new("div")
												:withStyle({
													direction = "row",
													gap = 5,
													width = { rel = 1 / 2 },
													height = { rel = 1 / 3 },
												})
												:withChildren({
													Element.new("div"):withStyle({
														bgImage = self.resizeTexture,
														width = { abs = 15 },
														height = { abs = 15 },
														margin = { right = 2 },
													}),
													Element.from("Resize")
														:withStyle({ fg = disabledColor, height = { rel = 1.0 } }),
												}),
											Element.new("div")
												:withStyle({
													direction = "row",
													gap = 5,
													width = { rel = 1 / 2 },
													height = { rel = 1 / 3 },
												})
												:withChildren({
													Element.new("div"):withStyle({
														bgImage = self.rotateTexture,
														width = { abs = 15 },
														height = { abs = 15 },
														margin = { right = 2 },
													}),
													Element.from("Rotate")
														:withStyle({ fg = disabledColor, height = { rel = 1.0 } }),
												}),
										}),
								}),
							Element.from("Image"):withStyle({
								align = "center",
								justify = "center",
								height = { rel = 0.3 },
							}),
						}),
					Element.new("div")
						:withStyle({
							direction = "column",
							width = { abs = 120 },
							height = { rel = 1.0 },
							border = { right = { width = 1, color = borderColor } },
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
											padding = { bottom = 1 },
										})
										:withChildren({
											Element.new("div")
												:withStyle({
													width = { abs = 35 },
													height = { abs = 35 },
													bg = toolBg("brush"),
													bgImage = self.brushTexture,
													margin = { right = 1 },
												})
												:onClick({ type = "ToolClicked", tool = "brush" }),
											Element.new("div")
												:withStyle({
													width = { abs = 35 },
													height = { abs = 35 },
													bg = toolBg("eraser"),
													bgImage = self.eraserTexture,
													margin = { right = 1 },
												})
												:onClick({ type = "ToolClicked", tool = "eraser" }),
											Element.new("div")
												:withStyle({
													width = { abs = 35 },
													height = { abs = 35 },
													bg = toolBg("fill"),
													bgImage = self.bucketTexture,
												})
												:onClick({ type = "ToolClicked", tool = "fill" }),
										}),
									Element.new("div")
										:withStyle({
											direction = "row",
											height = { rel = 0.5 },
											gap = 3,
										})
										:withChildren({
											Element.new("div")
												:withStyle({
													width = { abs = 35 },
													height = { abs = 35 },
													bg = toolBg("pencil"),
													bgImage = self.pencilTexture,
												})
												:onClick({ type = "ToolClicked", tool = "pencil" }),
											Element.new("div"):withStyle({
												width = { abs = 35 },
												height = { abs = 35 },
												bg = toolBg("text"),
												bgImage = self.textTexture,
											}),
											-- :onClick({ type = "ToolClicked", tool = "text" }),
											Element.new("div"):withStyle({
												width = { abs = 35 },
												height = { abs = 35 },
												bg = toolBg("zoom"),
												bgImage = self.magnifierTexture,
											}),
											-- :onClick({ type = "ToolClicked", tool = "zoom" })
										}),
								}),
							Element.from("Tools"):withStyle({
								align = "center",
								justify = "center",
								height = { rel = 0.3 },
							}),
						}),

					-- Brushes section
					Element.new("div")
						:withStyle({
							direction = "column",
							width = { abs = 100 },
							height = { rel = 1.0 },
							border = { right = { width = 1, color = borderColor } },
						})
						:withChildren({
							Element.new("div")
								:withStyle({
									align = "center",
									justify = "center",
									padding = { top = 3, bottom = 3, left = 3, right = 3 },
									height = { rel = 0.7 },
								})
								:withChildren({
									Element.new("div"):withStyle({
										width = { abs = 50 },
										height = { abs = 50 },
										bgImage = self.brushesTexture,
									}),
								}),
							Element.from("Brushes"):withStyle({
								align = "center",
								justify = "center",
								fg = disabledColor,
								height = { rel = 0.3 },
							}),
						}),

					-- Shapes section
					Element.new("div")
						:withStyle({
							direction = "column",
							width = { abs = 230 },
							height = { rel = 1.0 },
							border = { right = { width = 1, color = borderColor } },
						})
						:withChildren({
							Element.new("div")
								:withStyle({
									direction = "column",
									margin = { top = 3, bottom = 3, left = 3, right = 3 },
									border = squareBorder,
									height = { rel = 0.7 },
								})
								:withChildren({
									Element.new("div")
										:withStyle({
											direction = "row",
											height = { abs = 28 },
										})
										:withChildren({
											Element.new("div"):withStyle({
												width = { abs = 28 },
												height = { abs = 28 },
												bgImage = self.lineTexture,
												bg = toolBg("line"),
											}):onClick({ type = "ToolClicked", tool = "line" }),
											Element.new("div"):withStyle({
												width = { abs = 28 },
												height = { abs = 28 },
												bgImage = self.curveTexture,
												bg = toolBg("curve"),
											}):onClick({ type = "ToolClicked", tool = "curve" }),
										}),
									Element.new("div")
										:withStyle({
											direction = "row",
											height = { abs = 28 },
										})
										:withChildren({
											Element.new("div"):withStyle({
												width = { abs = 28 },
												height = { abs = 28 },
												bgImage = self.squareTexture,
												bg = toolBg("square"),
											}):onClick({ type = "ToolClicked", tool = "square" }),
											Element.new("div"):withStyle({
												width = { abs = 28 },
												height = { abs = 28 },
												bgImage = self.circleTexture,
												bg = toolBg("circle"),
											}):onClick({ type = "ToolClicked", tool = "circle" }),
										})
								}),
							Element.from("Shapes"):withStyle({
								align = "center",
								justify = "center",
								height = { rel = 0.3 },
							}),
						}),

					Element.new("div")
						:withStyle({
							direction = "column",
							width = { abs = 300 },
							height = { rel = 1.0 },
							border = { right = { width = 1, color = borderColor } },
						})
						:withChildren({
							Element.new("div")
								:withStyle({
									padding = { top = 3, bottom = 3, left = 3, right = 3 },
									height = { rel = 0.7 },
									direction = "row",
									align = "center",
									gap = 5,
								})
								:withChildren({
									Element.new("div"):withStyle({
										width = { abs = 40 },
										height = { abs = 40 },
										bg = self.currentColor,
										border = squareBorder,
										margin = { right = 5 },
									}),
									Element.new("div")
										:withStyle({
											direction = "column",
											justify = "center",
										})
										:withChildren({
											Element.new("div")
												:withStyle({
													direction = "row",
													height = { rel = 0.5 },
												})
												:withChildren({
													Element.new("div")
														:withStyle({
															width = { abs = 30 },
															height = { abs = 30 },
															bg = { r = 0.0, g = 0.0, b = 0.0, a = 1.0 },
															border = squareBorder,
															margin = { all = 1 },
														})
														:onClick({ type = "ColorClicked", r = 0.0, g = 0.0, b = 0.0 }),
													Element.new("div")
														:withStyle({
															width = { abs = 30 },
															height = { abs = 30 },
															bg = { r = 1.0, g = 0.0, b = 0.0, a = 1.0 },
															border = squareBorder,
															margin = { all = 1 },
														})
														:onClick({ type = "ColorClicked", r = 1.0, g = 0.0, b = 0.0 }),
													Element.new("div")
														:withStyle({
															width = { abs = 30 },
															height = { abs = 30 },
															bg = { r = 0.0, g = 1.0, b = 0.0, a = 1.0 },
															border = squareBorder,
															margin = { all = 1 },
														})
														:onClick({ type = "ColorClicked", r = 0.0, g = 1.0, b = 0.0 }),
													Element.new("div")
														:withStyle({
															width = { abs = 30 },
															height = { abs = 30 },
															bg = { r = 0.0, g = 0.0, b = 1.0, a = 1.0 },
															border = squareBorder,
															margin = { all = 1 },
														})
														:onClick({ type = "ColorClicked", r = 0.0, g = 0.0, b = 1.0 }),
													Element.new("div")
														:withStyle({
															width = { abs = 30 },
															height = { abs = 30 },
															bg = { r = 1.0, g = 1.0, b = 0.0, a = 1.0 },
															border = squareBorder,
															margin = { all = 1 },
														})
														:onClick({ type = "ColorClicked", r = 1.0, g = 1.0, b = 0.0 }),
													Element.new("div")
														:withStyle({
															width = { abs = 30 },
															height = { abs = 30 },
															bg = { r = 1.0, g = 0.0, b = 1.0, a = 1.0 },
															border = squareBorder,
															margin = { all = 1 },
														})
														:onClick({ type = "ColorClicked", r = 1.0, g = 0.0, b = 1.0 }),
													Element.new("div")
														:withStyle({
															width = { abs = 30 },
															height = { abs = 30 },
															bg = { r = 0.0, g = 1.0, b = 1.0, a = 1.0 },
															border = squareBorder,
															margin = { all = 1 },
														})
														:onClick({ type = "ColorClicked", r = 0.0, g = 1.0, b = 1.0 }),
												}),
											Element.new("div")
												:withStyle({
													direction = "row",
													height = { rel = 0.5 },
												})
												:withChildren({
													Element.new("div")
														:withStyle({
															width = { abs = 30 },
															height = { abs = 30 },
															bg = { r = 0.5, g = 0.5, b = 0.5, a = 1.0 },
															border = squareBorder,
															margin = { all = 1 },
														})
														:onClick({ type = "ColorClicked", r = 0.5, g = 0.5, b = 0.5 }),
													Element.new("div")
														:withStyle({
															width = { abs = 30 },
															height = { abs = 30 },
															bg = { r = 0.5, g = 0.0, b = 0.0, a = 1.0 },
															border = squareBorder,
															margin = { all = 1 },
														})
														:onClick({ type = "ColorClicked", r = 0.5, g = 0.0, b = 0.0 }),
													Element.new("div")
														:withStyle({
															width = { abs = 30 },
															height = { abs = 30 },
															bg = { r = 0.0, g = 0.5, b = 0.0, a = 1.0 },
															border = squareBorder,
															margin = { all = 1 },
														})
														:onClick({ type = "ColorClicked", r = 0.0, g = 0.5, b = 0.0 }),
													Element.new("div")
														:withStyle({
															width = { abs = 30 },
															height = { abs = 30 },
															bg = { r = 0.0, g = 0.0, b = 0.5, a = 1.0 },
															border = squareBorder,
															margin = { all = 1 },
														})
														:onClick({ type = "ColorClicked", r = 0.0, g = 0.0, b = 0.5 }),
													Element.new("div")
														:withStyle({
															width = { abs = 30 },
															height = { abs = 30 },
															bg = { r = 0.5, g = 0.5, b = 0.0, a = 1.0 },
															border = squareBorder,
															margin = { all = 1 },
														})
														:onClick({ type = "ColorClicked", r = 0.5, g = 0.5, b = 0.0 }),
													Element.new("div")
														:withStyle({
															width = { abs = 30 },
															height = { abs = 30 },
															bg = { r = 0.5, g = 0.0, b = 0.5, a = 1.0 },
															zIndex = 2,
															border = squareBorder,
															margin = { all = 1 },
														})
														:onClick({ type = "ColorClicked", r = 0.5, g = 0.0, b = 0.5 }),
													Element.new("div")
														:withStyle({
															width = { abs = 30 },
															height = { abs = 30 },
															bg = { r = 0.0, g = 0.5, b = 0.5, a = 1.0 },
															border = squareBorder,
															margin = { all = 1 },
														})
														:onClick({ type = "ColorClicked", r = 0.0, g = 0.5, b = 0.5 }),
												}),
										}),
								}),
							Element.from("Colors"):withStyle({
								align = "center",
								justify = "center",
								height = { rel = 0.3 },
							}),
						}),
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
					-- Main canvas
					Element.new("div")
						:withStyle({
							bgImage = self.canvasTexture,
							width = { rel = 1 },
							height = { rel = 1 },
							margin = { right = 20, left = 20, top = 20, bottom = 20 },
						})
						:onMouseDown(function(x, y, elementWidth, elementHeight)
							return {
								type = "StartDrawing",
								x = x,
								y = y,
								elementWidth = elementWidth,
								elementHeight = elementHeight,
							}
						end)
						:onMouseUp(function(x, y, elementWidth, elementHeight)
							return {
								type = "StopDrawing",
								x = x,
								y = y,
								elementWidth = elementWidth,
								elementHeight = elementHeight,
							}
						end)
						:onMouseMove(function(x, y, elementWidth, elementHeight)
							return {
								type = "Hovered",
								x = x,
								y = y,
								elementWidth = elementWidth,
								elementHeight = elementHeight,
							}
						end),
					Element.new("div")
						:withStyle({
							position = "relative",
							-- bg = { r = 1, g = 1, b = 1, a = 1 },
							-- bgImage = self.bucketTexture,
							top = 0,
							left = 0
						})
				}),
			Element.new("div")
				:withStyle({
					height = { abs = 30 },
					width = "auto",
				})
				:withChildren({
					Element.from("arisu v0.3.0"):withStyle({
						align = "center",
						padding = { left = 10 },
					}),
				}),
		})
end

---@param event Event
function App:event(event) end

---@param message Message
---@param window Window
function App:update(message, window)
	if message.type == "StartDrawing" then
		if self.currentAction.tool == "fill" then
			self.compute:fill(
				(message.x / message.elementWidth) * 800,
				(message.y / message.elementHeight) * 600,
				self.currentColor
			)
		elseif self.currentAction.tool == "brush" then
			self.compute:stamp(
				(message.x / message.elementWidth) * 800,
				(message.y / message.elementHeight) * 600,
				10,
				self.currentColor
			)

			self.isDrawing = true
		elseif self.currentAction.tool == "select" then
			local x = (message.x / message.elementWidth) * 800
			local y = (message.y / message.elementHeight) * 600

			self.currentAction.start = { x = x, y = y }
		elseif self.currentAction.tool == "pencil" then
			self.compute:stamp(
				(message.x / message.elementWidth) * 800,
				(message.y / message.elementHeight) * 600,
				1,
				self.currentColor
			)

			self.isDrawing = true
		elseif self.currentAction.tool == "eraser" then
			self.compute:erase((message.x / message.elementWidth) * 800, (message.y / message.elementHeight) * 600, 10)

			self.isDrawing = true
		end

		return Task.redraw(window)
	elseif message.type == "StopDrawing" then
		if self.currentAction.tool == "select" and self.currentAction.start then
			local x = (message.x / message.elementWidth) * 800
			local y = (message.y / message.elementHeight) * 600

			local start = self.currentAction.start
			if start.x == x and start.y == y then
				-- Click without drag, clear selection
				self.compute:resetSelection()

				self.currentAction.start = nil
				self.currentAction.finish = nil
			else
				local start = { x = math.min(start.x, x), y = math.min(start.y, y) }
				local finish = { x = math.max(start.x, x), y = math.max(start.y, y) }

				self.compute:setSelection(start.x, start.y, finish.x, finish.y)
			end
		end

		self.isDrawing = false
	elseif message.type == "ColorClicked" then
		self.currentColor = { r = message.r, g = message.g, b = message.b, a = 1.0 }
		return Task.refreshView(window)
	elseif message.type == "ToolClicked" then
		if message.tool == "select" then
			self.compute:resetSelection()
		end

		self.currentAction.tool = message.tool
		-- self.soundManager:play(self.popAudio, 1.0)

		return Task.refreshView(window)
	elseif message.type == "ClearClicked" then
		for i = 0, 800 * 600 * 4 - 1 do
			self.canvasBuffer[i] = 255
		end

		local canvasImage = Image.new(800, 600, 4, self.canvasBuffer, "")
		self.textureManager:update(self.canvasTexture, canvasImage)
		return Task.redraw(self.mainWindow)
	elseif message.type == "OpenClicked" then
		local builder = WindowBuilder.new():withTitle("Open File"):withSize(600, 400)

		return Task.openWindow(builder)
	elseif message.type == "SaveClicked" then
		local builder = WindowBuilder.new():withTitle("Save File"):withSize(600, 400)

		return Task.openWindow(builder)
	elseif message.type == "Hovered" then
		if self.isDrawing then
			-- TODO: Un-hard code canvas size (800, 600)
			-- Currently it's fine since the canvas won't change size.
			-- Probably want to refactor textureManager to return the info struct instead of just the id.
			if self.currentAction.tool == "eraser" then
				self.compute:erase((message.x / message.elementWidth) * 800, (message.y / message.elementHeight) * 600,
					10)
			elseif self.currentAction.tool == "brush" then
				self.compute:stamp(
					(message.x / message.elementWidth) * 800,
					(message.y / message.elementHeight) * 600,
					10,
					self.currentColor
				)
			elseif self.currentAction.tool == "pencil" then
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
