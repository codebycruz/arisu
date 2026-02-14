local Instance = require("hood.instance")

---@class arisu.plugin.Window.Context
---@field window winit.Window
---@field surface hood.Surface

---@class arisu.plugin.Window<Message>: { onWindowCreate: Message }
---@field mainCtx arisu.plugin.Window.Context?
---@field contexts table<winit.Window, arisu.plugin.Window.Context>
---@field onWindowCreate unknown
---@field instance hood.Instance
local WindowPlugin = {}
WindowPlugin.__index = WindowPlugin

---@param onWindowCreate unknown
function WindowPlugin.new(onWindowCreate)
	local instance = Instance.new({ backend = os.getenv("VULKAN") and "vulkan" or "opengl", flags = { "validate" } })
	return setmetatable({ contexts = {}, instance = instance, onWindowCreate = onWindowCreate }, WindowPlugin)
end

---@param window winit.Window
function WindowPlugin:register(window)
	local surface = self.instance:createSurface(window)

	local windowCtx = {
		window = window,
		surface = surface,
	}

	self.mainCtx = self.mainCtx or windowCtx
	self.contexts[window] = windowCtx
end

function WindowPlugin:getContext(window) ---@return arisu.plugin.Window.Context?
	return self.contexts[window]
end

---@param event winit.Event
---@param handler winit.EventManager
function WindowPlugin:event(event, handler)
	-- onWindowCreate is not passed the window as the update will be triggered
	-- with the new window anyway.
	if event.name == "map" and not self:getContext(event.window) then
		self:register(event.window)
		return self.onWindowCreate
	elseif event.name == "create" then
		self:register(event.window)
		return self.onWindowCreate
	elseif event.name == "windowClose" then
		local ctx = self:getContext(event.window)
		if ctx == self.mainCtx then
			handler:exit()
		else
			self.contexts[event.window] = nil
			handler:close(event.window)
		end
	end
end

return WindowPlugin
