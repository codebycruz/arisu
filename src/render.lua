local glx = require "src.bindings.glx"
local x11 = require "src.bindings.x11"

--- @class Context
--- @field display XDisplay
--- @field window Window
--- @field ctx userdata
local Context = {}
Context.__index = Context

function Context.new(display --[[@param display XDisplay]], window --[[@param window Window]])
    local screen = x11.defaultScreen(display)

    local fbConfig = glx.chooseFBConfig(display, screen, {
        glx.RENDER_TYPE, glx.RGBA_BIT,
        glx.DRAWABLE_TYPE, glx.WINDOW_BIT,
        glx.DOUBLEBUFFER, 1,
    })
    if not fbConfig then
        error("Failed to choose FBConfig")
    end

    local ctx = glx.createContextAttribsARB(display, fbConfig, nil, 1, {
        glx.CONTEXT_MAJOR_VERSION_ARB, 3,
        glx.CONTEXT_MINOR_VERSION_ARB, 3
    })
    if not ctx then
        error("Failed to create GLX context with attributes")
    end

    local self = setmetatable({ ctx = ctx, display = display, window = window }, Context)

    -- Store previous context so as to ensure this function doesn't cause side effects
    local prevDisplay = glx.getCurrentDisplay()
    local prevContext = glx.getCurrentContext()

    self:makeCurrent()
    glx.swapIntervalEXT(display, window.id, 1)  -- Enable V-Sync? doesn't seem to do anything.

    if prevContext and prevDisplay then
        glx.makeCurrent(prevDisplay, window.id, prevContext)
    end

    return self
end

---@return boolean # true on success, false on failure
function Context:makeCurrent()
    return glx.makeCurrent(self.display, self.window.id, self.ctx) ~= 0
end

function Context:swapBuffers()
    glx.swapBuffers(self.display, self.window.id)
end

function Context:destroy()
    glx.destroyContext(self.display, self.ctx)
end

return {
    Context = Context,
}
