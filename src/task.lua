---@alias Task
--- | { variant: "windowOpen", builder: WindowBuilder }
--- | { variant: "refreshView" }
--- | { variant: "setTitle", to: string }

local Task = {}

---@param builder WindowBuilder
function Task.openWindow(builder) ---@return Task
    return { variant = "windowOpen", builder = builder }
end

function Task.refreshView() ---@return Task
    return { variant = "refreshView" }
end

--- Sets the title of the main window to the given string
function Task.setMainWindowTitle(title)
    return { variant = "setTitle", to = title }
end

return Task
