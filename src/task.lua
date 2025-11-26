---@alias Task
--- | { variant: "windowOpen", builder: WindowBuilder }
--- | { variant: "refreshView", window: Window }
--- | { variant: "setTitle", to: string }
--- | { variant: "waitOnGPU", window: Window }
--- | { variant: "chain", tasks: Task[] }

local Task = {}
Task.__index = Task

---@param builder WindowBuilder
function Task.openWindow(builder) ---@return Task
    return { variant = "windowOpen", builder = builder }
end

---@param window Window
function Task.refreshView(window) ---@return Task
    return { variant = "refreshView", window = window }
end

---@param title string
function Task.setMainWindowTitle(title) ---@return Task
    return { variant = "setTitle", to = title }
end

function Task.waitOnGPU(window) ---@return Task
    return { variant = "waitOnGPU", window = window }
end

---@param tasks Task[]
function Task.chain(tasks) ---@return Task
    return { variant = "chain", tasks = tasks }
end

return Task
