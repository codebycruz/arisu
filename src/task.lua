---@alias Task
--- | { variant: "windowOpen", builder: WindowBuilder }
--- | { variant: "refreshView" }

local Task = {}

---@param builder WindowBuilder
function Task.openWindow(builder) ---@return Task
    return { variant = "windowOpen", builder = builder }
end

function Task.refreshView() ---@return Task
    return { variant = "refreshView" }
end

return Task
