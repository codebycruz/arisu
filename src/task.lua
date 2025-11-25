---@alias TaskVariant
--- | "windowOpen"
--- | "refreshView"

---@class Task
local Task = {}
Task.__index = Task

---@param builder WindowBuilder
function Task.openWindow(builder)
    return setmetatable({ variant = "windowOpen", builder = builder }, Task)
end

function Task.refreshView()
    return setmetatable({ variant = "refreshView" }, Task)
end

return Task
