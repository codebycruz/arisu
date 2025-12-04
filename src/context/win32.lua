local user32 = require("bindings.user32")
local wgl = require("bindings.wgl")
local gdi = require("bindings.gdi")

---@class Win32Context: Context
---@field display user32.HDC
---@field ctx wgl.HGLRC
local Win32Context = {}
Win32Context.__index = Win32Context

---@param window Win32Window
---@param sharedCtx Win32Context?
function Win32Context.new(window, sharedCtx)
	local hdc = user32.getDC(window.id)
	local hglrc = wgl.createContext(hdc)
	return setmetatable({ display = hdc, ctx = hglrc }, Win32Context)
end

function Win32Context:makeCurrent()
	wgl.makeCurrent(self.display, self.ctx)
end

function Win32Context:swapBuffers()
	gdi.swapBuffers(self.display)
end

function Win32Context:destroy()
	wgl.deleteContext(self.ctx)
end

function Win32Context:setPresentMode(mode)
	print("Warning: Win32Context:setPresentMode is unimplemented")
end

return Win32Context
