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
    local visual = glx.chooseVisual(display, screen, { glx.RGBA, glx.DEPTH_SIZE, 16, glx.DOUBLEBUFFER })
    if visual == nil then
        return nil, "Failed to choose visual"
    end

    local ctx = glx.createContext(display, visual, nil, 1)
    if ctx == nil then
        return nil, "Failed to create GLX context"
    end

    return setmetatable({ ctx = ctx, display = display, window = window }, Context)
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
