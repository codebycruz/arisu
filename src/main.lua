package.path = package.path .. ";./src/?.lua"

local Arisu = require("arisu")
local Element = require("ui.element")
local Compute = require("tools.compute")
local Image = require("image")

local WindowPlugin = require("plugin.window")
local RenderPlugin = require("plugin.render")
local LayoutPlugin = require("plugin.layout")
local TextPlugin = require("plugin.text")
local UIPlugin = require("plugin.ui")

---@alias Message
--- | { type: "onWindowCreate", window: Window }
--- | { type: "StartDrawing" }
--- | { type: "StopDrawing" }
--- | { type: "Hovered", x: number, y: number, elementWidth: number, elementHeight: number }
--- | { type: "ColorSelected", color: { r: number, g: number, b: number, a: number } }
--- | { type: "clicked" }

---@class App.Resources.Icons
---@field brush Texture
---@field eraser Texture
---@field pencil Texture
---@field bucket Texture
---@field text Texture
---@field palette Texture
---@field select Texture
---@field paste Texture
---@field magnifier Texture
---@field sound Texture
---@field soundMute Texture
---@field vector Texture
---@field copy Texture
---@field cut Texture
---@field crop Texture
---@field resize Texture
---@field rotate Texture
---@field brushes Texture
---@field square Texture
---@field circle Texture
---@field line Texture
---@field curve Texture

---@class App.Resources.Textures
---@field canvas Texture

---@class App.Resources
---@field textures App.Resources.Textures
---@field icons App.Resources.Icons
---@field compute Compute

---@class App.Plugins
---@field window plugin.Window
---@field render plugin.Render
---@field text plugin.Text
---@field ui plugin.UI
---@field layout plugin.Layout

---@alias App.Tool "brush" | "eraser" | "fill" | "pencil" | "text" | "select" | "square" | "circle" | "line" | "curve"

---@alias App.Action
--- | { tool: "select", start: { x: number, y: number }?, finish: { x: number, y: number }? }
--- | { tool: "line", start: { x: number, y: number }?, finish: { x: number, y: number }? }
--- | { tool: App.Tool }

---@class App
---@field plugins App.Plugins
---@field resources App.Resources
---@field isDrawing boolean
---@field currentColor { r: number, g: number, b: number, a: number }
local App = {}
App.__index = App

function App.new()
	local self = setmetatable({ plugins = {} }, App)
	self.plugins.window = WindowPlugin.new({ type = "onWindowCreate" })
	self.plugins.render = RenderPlugin.new(self.plugins.window)
	self.plugins.text = TextPlugin.new(self.plugins.render)
	self.plugins.layout = LayoutPlugin.new(function(w) return self:view(w) end, self.plugins.text)
	self.plugins.ui = UIPlugin.new(self.plugins.layout, self.plugins.render)

	self.isDrawing = false
	self.currentColor = { r = 1, g = 0, b = 0, a = 1 }

	return self
end

function App:makeResources() ---@return App.Resources
	local textureManager = self.plugins.render.sharedResources.textureManager
	local canvas = textureManager:allocate(800, 600)

	return {
		---@type App.Resources.Icons
		icons = {
			brush = textureManager:upload(assert(Image.fromPath("assets/icons/brush.qoi"), "Brush icon not found")),
			eraser = textureManager:upload(assert(Image.fromPath("assets/icons/david/eraser.qoi"),
				"Eraser icon not found")),
			pencil = textureManager:upload(assert(Image.fromPath("assets/icons/pencil.qoi"), "Pencil icon not found")),
			bucket = textureManager:upload(assert(Image.fromPath("assets/icons/bucket.qoi"), "Bucket icon not found")),
			text = textureManager:upload(assert(Image.fromPath("assets/icons/text.qoi"), "Text icon not found")),
			palette = textureManager:upload(assert(Image.fromPath("assets/icons/palette.qoi"), "Palette icon not found")),
			select = textureManager:upload(assert(Image.fromPath("assets/icons/select.qoi"), "Select icon not found")),
			paste = textureManager:upload(assert(Image.fromPath("assets/icons/paste.qoi"), "Paste icon not found")),
			magnifier = textureManager:upload(assert(Image.fromPath("assets/icons/magnifier.qoi"),
				"Magnifier icon not found")),
			sound = textureManager:upload(assert(Image.fromPath("assets/icons/sound.qoi"), "Sound icon not found")),
			soundMute = textureManager:upload(assert(Image.fromPath("assets/icons/sound_mute.qoi"),
				"Sound mute icon not found")),
			vector = textureManager:upload(assert(Image.fromPath("assets/icons/vector.qoi"), "Vector icon not found")),
			copy = textureManager:upload(assert(Image.fromPath("assets/icons/copy.qoi"), "Copy icon not found")),
			cut = textureManager:upload(assert(Image.fromPath("assets/icons/cut.qoi"), "Cut icon not found")),
			crop = textureManager:upload(assert(Image.fromPath("assets/icons/crop.qoi"), "Crop icon not found")),
			resize = textureManager:upload(assert(Image.fromPath("assets/icons/resize.qoi"), "Resize icon not found")),
			rotate = textureManager:upload(assert(Image.fromPath("assets/icons/rotate.qoi"), "Rotate icon not found")),
			brushes = textureManager:upload(assert(Image.fromPath("assets/icons/brushes.qoi"), "Brushes icon not found")),
			square = textureManager:upload(assert(Image.fromPath("assets/icons/david/square.qoi"),
				"Square icon not found")),
			circle = textureManager:upload(assert(Image.fromPath("assets/icons/david/circle.qoi"),
				"Circle icon not found")),
			line = textureManager:upload(assert(Image.fromPath("assets/icons/david/line.qoi"), "Line icon not found")),
			curve = textureManager:upload(assert(Image.fromPath("assets/icons/david/curve.qoi"), "Curve icon not found")),
		},

		---@type App.Resources.Textures
		textures = {
			canvas = canvas
		},

		compute = Compute.new(textureManager, canvas)
	}
end

---@generic T, V
---@param list T[]
---@param fn fun(item: T): V
---@return V[]
local function map(list, fn)
	local result = {}
	for i, item in ipairs(list) do
		result[i] = fn(item)
	end
	return result
end

---@generic T
---@param list T[]
---@param size number
---@return T[][]
local function chunks(list, size)
	local result = {}

	for i = 1, #list, size do
		local chunk = {}
		for j = i, math.min(i + size - 1, #list) do
			chunk[#chunk + 1] = list[j]
		end

		result[#result + 1] = chunk
	end

	return result
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

	local colorGridValues = {
		{ r = 1, g = 0, b = 0, a = 1 }, { r = 0, g = 1, b = 0, a = 1 }, { r = 0, g = 0, b = 1, a = 1 },
		{ r = 1, g = 1, b = 0, a = 1 }, { r = 1, g = 0, b = 1, a = 1 }, { r = 0, g = 1, b = 1, a = 1 },
	}

	local colorGrid = Element.new("div")
		:withStyle({
			left = 0,
			top = 0,
			position = "relative",
			direction = "column",
			border = squareBorder,
			height = { abs = 50 * 2 },
			width = { abs = 50 * 3 }
		})
		:withChildren(map(chunks(colorGridValues, 3), function(row)
			return Element.new("div")
				:withStyle({
					direction = "row",
					height = { abs = 50 }
				})
				:withChildren(map(row, function(color)
					return Element.new("div")
						:withStyle({
							bg = color,
							width = { abs = 50 },
							height = { abs = 50 },
						})
						:onClick({ type = "ColorSelected", color = color })
				end))
		end))

	local canvasElement = Element.new("div")
		:withStyle({
			bgImage = self.resources.textures.canvas,
			margin = { top = 5, right = 5, bottom = 5, left = 5 },
			direction = "column",
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
		end)

	return Element.new("div")
		:withStyle({
			direction = "column",
			width = { rel = 1 },
			height = { rel = 1 },
		})
		:withChildren({ colorGrid, canvasElement })
end

---@param event Event
---@param handler EventHandler
function App:event(event, handler)
	local windowUpdate = self.plugins.window:event(event, handler)
	if windowUpdate then
		return windowUpdate
	end

	local renderUpdate = self.plugins.render:event(event, handler)
	if renderUpdate then
		return renderUpdate
	end

	local layoutUpdate = self.plugins.layout:event(event, handler)
	if layoutUpdate then
		return layoutUpdate
	end
end

---@param message Message
---@param window Window
function App:update(message, window)
	if message.type == "onWindowCreate" then
		-- Now we can initialize assets for a specific window
		self.plugins.render:register(window)

		if window == self.plugins.window.mainCtx.window then
			self.resources = self:makeResources()
		end

		self.plugins.layout:register(window)
		self.plugins.ui:refreshView(window)
	elseif message.type == "StartDrawing" then
		self.isDrawing = true
	elseif message.type == "StopDrawing" then
		self.isDrawing = false
	elseif message.type == "Hovered" then
		if self.isDrawing then
			self.resources.compute:stamp(
				(message.x / message.elementWidth) * 800,
				(message.y / message.elementHeight) * 600,
				10,
				self.currentColor
			)

			self.plugins.ui:refreshView(window)
		end
	elseif message.type == "ColorSelected" then
		self.currentColor = message.color
	else
		print("??", message.type)
	end
end

Arisu.run(App)
