---@alias Task<Message>
--- | { variant: "createWindow", message: Message }
--- | { variant: "refreshView", window: Window }
--- | { variant: "redraw", window: Window }
--- | { variant: "chain", tasks: Task<Message>[] }
--- | { variant: "done", message: Message }
--- | { variant: "none" }

local Task = {}
Task.__index = Task

function Task.done(message) ---@return Task
	return { variant = "done", message = message }
end

function Task.none() ---@return Task
	return { variant = "none" }
end

function Task.createWindow(message) ---@return Task
	return { variant = "createWindow", message = message }
end

---@param window Window
function Task.redraw(window) ---@return Task
	return { variant = "redraw", window = window }
end

---@param window Window
function Task.refreshView(window) ---@return Task
	return { variant = "refreshView", window = window }
end

---@param tasks Task[]
function Task.chain(tasks) ---@return Task
	return { variant = "chain", tasks = tasks }
end

return Task
