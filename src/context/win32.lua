local user32 = require("bindings.user32")
local kernel32 = require("bindings.kernel32")
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

	local pfDescriptor = gdi.newPFD()
	local pf = gdi.choosePixelFormat(hdc, pfDescriptor)
	if pf == 0 then
		error("Failed to choose pixel format: " .. tostring(kernel32.getLastErrorMessage()))
	end

	if gdi.setPixelFormat(hdc, pf, pfDescriptor) == 0 then
		error("Failed to set pixel format: " .. tostring(kernel32.getLastErrorMessage()))
	end

	local hglrc = wgl.createContext(hdc)
	if not hglrc then
		error("Failed to create OpenGL context: " .. tostring(kernel32.getLastErrorMessage()))
	end

	return setmetatable({ display = hdc, ctx = hglrc }, Win32Context)
end

function Win32Context:makeCurrent()
	if wgl.makeCurrent(self.display, self.ctx) == 0 then
		error("Failed to make OpenGL context current: " .. tostring(kernel32.getLastErrorMessage()))
	end
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
