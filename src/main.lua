package.path = package.path .. ";./src/?.lua"

local Arisu = require("arisu")
local Element = require("ui.element")
local WindowPlugin = require("plugin.window")
local RenderPlugin = require("plugin.render")

---@alias Message
--- | { type: "onWindowCreate", window: Window }

---@class App
---@field windowPlugin WindowPlugin
---@field renderPlugin RenderPlugin
local App = {}
App.__index = App

function App.new()
	local self = setmetatable({}, App)
	self.windowPlugin = WindowPlugin.new({ type = "onWindowCreate" })
	self.renderPlugin = RenderPlugin.new(self.windowPlugin)

	return self
end

---@param window Window
function App:view(window)
	return Element.new("div")
		:withStyle({
			bg = { r = 1, g = 0, b = 0, a = 1 }
		})
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
end

---@param message Message
---@param window Window
function App:update(message, window)
	if message.type == "onWindowCreate" then
		-- Now we can initialize assets for a specific window
		self.renderPlugin:register(window)
	end
end

Arisu.run(App)
