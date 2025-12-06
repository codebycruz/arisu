package.path = package.path .. ";./src/?.lua"

local Arisu = require("arisu")
local Element = require("ui.element")

local WindowPlugin = require("plugin.window")
local RenderPlugin = require("plugin.render")
local LayoutPlugin = require("plugin.layout")
local TextPlugin = require("plugin.text")
local UIPlugin = require("plugin.ui")

---@alias Message
--- | { type: "onWindowCreate", window: Window }
--- | { type: "clicked" }

---@class App
---@field windowPlugin plugin.Window
---@field renderPlugin plugin.Render
---@field textPlugin plugin.Text
---@field uiPlugin plugin.UI
---@field layoutPlugin plugin.Layout
local App = {}
App.__index = App

function App.new()
	local self = setmetatable({}, App)
	self.windowPlugin = WindowPlugin.new({ type = "onWindowCreate" })
	self.renderPlugin = RenderPlugin.new(self.windowPlugin)
	self.textPlugin = TextPlugin.new(self.renderPlugin)
	self.layoutPlugin = LayoutPlugin.new(function(w) return self:view(w) end, self.textPlugin)
	self.uiPlugin = UIPlugin.new(self.layoutPlugin, self.renderPlugin)

	return self
end

---@param window Window
function App:view(window)
	return Element.new("div")
		:withStyle({
			bg = { r = 1, g = 1, b = 0, a = 1 },
			direction = "column",
		})
		:withChildren(
			Element.new("div")
			:withStyle({
				bg = { r = 0, g = 1, b = 0, a = 1 },
				width = { abs = 200 },
				height = { abs = 200 },
			})
			:withChildren(
				Element.new("text")
				:withStyle({
					fg = { r = 1, g = 1, b = 1, a = 1 },
				})
			)
		)
		:onClick({ type = "clicked" })
end

---@param event Event
---@param handler EventHandler
function App:event(event, handler)
	local windowUpdate = self.windowPlugin:event(event, handler)
	if windowUpdate then
		return windowUpdate
	end

	local renderUpdate = self.renderPlugin:event(event, handler)
	if renderUpdate then
		return renderUpdate
	end

	local layoutUpdate = self.layoutPlugin:event(event, handler)
	if layoutUpdate then
		return layoutUpdate
	end
end

---@param message Message
---@param window Window
function App:update(message, window)
	if message.type == "onWindowCreate" then
		-- Now we can initialize assets for a specific window
		self.renderPlugin:register(window)
		self.layoutPlugin:register(window)
		self.uiPlugin:refreshView(window)
	else
		print("??", message.type)
	end
end

Arisu.run(App)
