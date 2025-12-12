local Context = require("arisu-app.context")

---@class plugin.Window.Context
---@field window Window
---@field renderCtx Context

---@class plugin.Window<Message>: { onWindowCreate: Message }
---@field mainCtx plugin.Window.Context?
---@field contexts table<Window, plugin.Window.Context>
---@field onWindowCreate unknown
local WindowPlugin = {}
WindowPlugin.__index = WindowPlugin

---@param onWindowCreate unknown
function WindowPlugin.new(onWindowCreate)
	return setmetatable({ contexts = {}, onWindowCreate = onWindowCreate }, WindowPlugin)
end

---@param window Window
function WindowPlugin:register(window)
	local renderCtx = Context.new(window, self.mainCtx and self.mainCtx.renderCtx)

	local windowCtx = {
		window = window,
		renderCtx = renderCtx
	}

	if not self.mainCtx then
		self.mainCtx = windowCtx
	end

	self.contexts[window] = windowCtx
end

function WindowPlugin:getContext(window) ---@return plugin.Window.Context?
	return self.contexts[window]
end

---@param event Event
---@param handler EventHandler
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
