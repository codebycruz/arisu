---@class WindowStateManager
local WindowStateManager = {}
WindowStateManager.__index = WindowStateManager

---@type table<Window, table>
local windowStates = {}

---@type table<Window, string>
local windowTypes = {}

---@param window Window
---@param stateType string
---@param initialState table
function WindowStateManager.setState(window, stateType, initialState)
    windowStates[window] = initialState
    windowTypes[window] = stateType
end

---@param window Window
---@return table?
function WindowStateManager.getState(window)
    return windowStates[window]
end

---@param window Window
---@return string?
function WindowStateManager.getType(window)
    return windowTypes[window]
end

---@param window Window
function WindowStateManager.removeState(window)
    windowStates[window] = nil
    windowTypes[window] = nil
end

---@param window Window
---@return boolean
function WindowStateManager.hasState(window)
    return windowStates[window] ~= nil
end

---@return table<Window, table>
function WindowStateManager.getAllStates()
    return windowStates
end

---@return table<Window, string>
function WindowStateManager.getAllTypes()
    return windowTypes
end

function WindowStateManager.clear()
    windowStates = {}
    windowTypes = {}
end

return WindowStateManager