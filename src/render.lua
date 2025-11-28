local glx = require "src.bindings.glx"
local x11 = require "src.bindings.x11"
local gl = require "src.bindings.gl"

--- @class Context
--- @field display XDisplay
--- @field window Window
--- @field ctx userdata
--- @field fence Fence?
local Context = {}
Context.__index = Context

---@param display XDisplay
---@param window Window
---@param sharedCtx Context|nil
function Context.new(display, window, sharedCtx)
  local screen = x11.defaultScreen(display)

  local fbConfig = glx.chooseFBConfig(display, screen, {
    glx.RENDER_TYPE,
    glx.RGBA_BIT,
    glx.DRAWABLE_TYPE,
    glx.WINDOW_BIT,
    glx.DOUBLEBUFFER,
    1,
    glx.DEPTH_SIZE,
    24,
  })
  if not fbConfig then
    error "Failed to choose FBConfig"
  end

  local ctx = glx.createContextAttribsARB(display, fbConfig, sharedCtx and sharedCtx.ctx, 1, {
    glx.CONTEXT_MAJOR_VERSION_ARB,
    3,
    glx.CONTEXT_MINOR_VERSION_ARB,
    3,
  })
  if not ctx then
    error "Failed to create GLX context with attributes"
  end

  return setmetatable({ ctx = ctx, display = display, window = window }, Context)
end

---@return boolean # true on success, false on failure
function Context:makeCurrent()
  return glx.makeCurrent(self.display, self.window.id, self.ctx) ~= 0
end

---@param mode "immediate" | "vsync"
function Context:setPresentMode(mode)
  local intMode = ({
    ["immediate"] = 0,
    ["vsync"] = 1,
  })[mode]

  glx.swapIntervalEXT(self.display, self.window.id, intMode)
end

function Context:swapBuffers()
  glx.swapBuffers(self.display, self.window.id)
end

function Context:present()
  self:swapBuffers()
end

function Context:destroy()
  glx.destroyContext(self.display, self.ctx)
end

return {
  Context = Context,
}
