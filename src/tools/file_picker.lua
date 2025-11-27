local Element = require "src.ui.element"
local Task = require "src.task"

---@class FilePickerState
---@field currentPath string
---@field directoryContents table<string, table>
---@field expandedDirectories table<string, boolean>
---@field mode "open" | "save"
---@field selectedFile string?
---@field fileName string?
---@field onConfirm (fun(filePath: string): Task?)?
---@field onCancel (fun(): Task?)?

---@class FilePicker
local FilePicker = {}
FilePicker.__index = FilePicker

-- File system utility functions
local function sanitizeText(text)
    local sanitized = ""
    for i = 1, #text do
        local byte = text:byte(i)
        if byte >= 32 and byte <= 126 then
            sanitized = sanitized .. text:sub(i, i)
        else
            sanitized = sanitized .. "?"
        end
    end
    return sanitized
end

local function scanDirectory(path)
    local items = {}
    
    local handle = io.popen('ls -1 "' .. path .. '" 2>/dev/null')
    if not handle then
        return items
    end
    
    for name in handle:lines() do
        if name and name ~= "" and name ~= "." and name ~= ".." then
            local fullPath = path .. "/" .. name
            
            local testHandle = io.popen('test -d "' .. fullPath .. '" && echo "dir" || echo "file"')
            local itemType = testHandle and testHandle:read("*l") or "file"
            if testHandle then testHandle:close() end
            
            local isDirectory = itemType == "dir"
            
            -- Filter files to only show supported formats
            if not isDirectory then
                local extension = name:match("%.([^%.]+)$")
                if not extension or (extension:lower() ~= "qoi" and extension:lower() ~= "ppm") then
                    goto continue
                end
            end
            
            table.insert(items, {
                name = sanitizeText(name),
                isDirectory = isDirectory,
                path = sanitizeText(fullPath)
            })
            
            ::continue::
        end
    end
    handle:close()

    table.sort(items, function(a, b)
        if a.isDirectory and not b.isDirectory then
            return true
        elseif not a.isDirectory and b.isDirectory then
            return false
        else
            return a.name:lower() < b.name:lower()
        end
    end)

    return items
end

---@param mode "open" | "save"
---@param initialPath string?
---@param onConfirm (fun(filePath: string): Task?)?
---@param onCancel (fun(): Task?)?
---@return FilePickerState
function FilePicker.new(mode, initialPath, onConfirm, onCancel)
    return {
        currentPath = initialPath or ".",
        directoryContents = {},
        expandedDirectories = {},
        mode = mode or "open",
        selectedFile = nil,
        fileName = "",
        onConfirm = onConfirm,
        onCancel = onCancel
    }
end

---@param state FilePickerState
function FilePicker.view(state)
    if not state.directoryContents[state.currentPath] then
        state.directoryContents[state.currentPath] = scanDirectory(state.currentPath)
    end

    local function createFileTreeElements(items, depth)
        local elements = {}
        depth = depth or 0

        for _, item in ipairs(items) do
            local indent = depth * 20
            local displayName

            if item.isDirectory then
                local expandIcon = state.expandedDirectories[item.path] and "[-]" or "[+]"
                displayName = expandIcon .. " " .. sanitizeText(item.name)
            else
                displayName = "    " .. sanitizeText(item.name)
            end

            local isSelected = state.selectedFile == item.path
            local bgColor = isSelected and { r = 0.7, g = 0.8, b = 1.0, a = 1 } or { r = 0.95, g = 0.95, b = 0.95, a = 1 }

            local element = Element.from(displayName)
                :withStyle({
                    height = { abs = 25 },
                    padding = { left = 10 + indent, top = 2, bottom = 2, right = 0 },
                    bg = bgColor,
                    fg = { r = 0, g = 0, b = 0, a = 1 }
                })

            if item.isDirectory then
                element = element:onClick({
                    type = "FilePickerDirectoryClicked",
                    path = item.path,
                    name = item.name
                })
            else
                element = element:onClick({
                    type = "FilePickerFileSelected",
                    path = item.path,
                    name = item.name
                })
            end

            table.insert(elements, element)

            if item.isDirectory and state.expandedDirectories[item.path] then
                if not state.directoryContents[item.path] then
                    state.directoryContents[item.path] = scanDirectory(item.path)
                end

                local subElements = createFileTreeElements(state.directoryContents[item.path], depth + 1)
                for _, subElement in ipairs(subElements) do
                    table.insert(elements, subElement)
                end
            end
        end

        return elements
    end

    local fileTreeElements = createFileTreeElements(state.directoryContents[state.currentPath])

    local titleText = state.mode == "save" and "Save File" or "Open File"
    local confirmText = state.mode == "save" and "Save" or "Open"

    local bottomSectionHeight = state.mode == "save" and 80 or 50
    
    local bottomSection = Element.new("div")
        :withStyle({
            height = { abs = bottomSectionHeight },
            direction = "column",
            bg = { r = 0.95, g = 0.95, b = 0.95, a = 1 },
            border = { top = { width = 1, color = { r = 0.7, g = 0.7, b = 0.7, a = 1 } } }
        })
        :withChildren(state.mode == "save" and {
            Element.new("div")
                :withStyle({
                    height = { abs = 30 },
                    direction = "row",
                    align = "center",
                    padding = { top = 5, bottom = 0, left = 5, right = 5 },
                    gap = 10
                })
                :withChildren({
                    Element.from("Filename:")
                        :withStyle({ width = { abs = 80 } }),
                    Element.from(state.fileName or "")
                        :withStyle({ 
                            width = { rel = 1.0 },
                            bg = { r = 1, g = 1, b = 1, a = 1 },
                            padding = { top = 3, bottom = 3, left = 5, right = 5 },
                            border = { top = { width = 1, color = { r = 0.5, g = 0.5, b = 0.5, a = 1 } },
                                     bottom = { width = 1, color = { r = 0.5, g = 0.5, b = 0.5, a = 1 } },
                                     left = { width = 1, color = { r = 0.5, g = 0.5, b = 0.5, a = 1 } },
                                     right = { width = 1, color = { r = 0.5, g = 0.5, b = 0.5, a = 1 } } }
                        })
                        :onClick({ type = "FilePickerFileNameClick" })
                }),
            Element.new("div")
                :withStyle({
                    height = { abs = 50 },
                    direction = "row",
                    align = "center",
                    justify = "end",
                    padding = { top = 5, bottom = 5, left = 5, right = 5 },
                    gap = 10
                })
                :withChildren({
                    Element.from("Cancel")
                        :withStyle({ 
                            width = { abs = 80 },
                            height = { abs = 30 },
                            bg = { r = 0.8, g = 0.8, b = 0.8, a = 1 },
                            padding = { top = 5, bottom = 5, left = 10, right = 10 }
                        })
                        :onClick({ type = "FilePickerCancel" }),
                    Element.from(confirmText)
                        :withStyle({ 
                            width = { abs = 80 },
                            height = { abs = 30 },
                            bg = (state.selectedFile or (state.mode == "save" and state.fileName and state.fileName ~= "")) 
                                and { r = 0.2, g = 0.7, b = 0.2, a = 1 } 
                                or { r = 0.6, g = 0.6, b = 0.6, a = 1 },
                            padding = { top = 5, bottom = 5, left = 10, right = 10 }
                        })
                        :onClick({ type = "FilePickerConfirm" })
                })
        } or {
            Element.new("div")
                :withStyle({
                    height = { abs = 50 },
                    direction = "row",
                    align = "center",
                    justify = "end",
                    padding = { top = 5, bottom = 5, left = 5, right = 5 },
                    gap = 10
                })
                :withChildren({
                    Element.from("Cancel")
                        :withStyle({ 
                            width = { abs = 80 },
                            height = { abs = 30 },
                            bg = { r = 0.8, g = 0.8, b = 0.8, a = 1 },
                            padding = { top = 5, bottom = 5, left = 10, right = 10 }
                        })
                        :onClick({ type = "FilePickerCancel" }),
                    Element.from(confirmText)
                        :withStyle({ 
                            width = { abs = 80 },
                            height = { abs = 30 },
                            bg = (state.selectedFile or (state.mode == "save" and state.fileName and state.fileName ~= "")) 
                                and { r = 0.2, g = 0.7, b = 0.2, a = 1 } 
                                or { r = 0.6, g = 0.6, b = 0.6, a = 1 },
                            padding = { top = 5, bottom = 5, left = 10, right = 10 }
                        })
                        :onClick({ type = "FilePickerConfirm" })
                })
        })

    return Element.new("div")
        :withStyle({
            direction = "column",
            bg = { r = 0.98, g = 0.98, b = 0.98, a = 1 },
            padding = { top = 5, bottom = 5, left = 5, right = 5 }
        })
        :withChildren({
            Element.new("div")
                :withStyle({
                    height = { abs = 30 },
                    direction = "row",
                    align = "center",
                    padding = { top = 5, bottom = 5, left = 5, right = 5 },
                    bg = { r = 0.9, g = 0.9, b = 0.9, a = 1 },
                    border = { bottom = { width = 1, color = { r = 0.7, g = 0.7, b = 0.7, a = 1 } } }
                })
                :withChildren({
                    Element.from(titleText .. " - " .. sanitizeText(state.currentPath))
                        :withStyle({ width = { rel = 0.8 } }),
                    Element.from("^ Up")
                        :withStyle({
                            width = { abs = 60 },
                            bg = { r = 0.8, g = 0.8, b = 0.8, a = 1 },
                            padding = { top = 3, bottom = 3, left = 3, right = 3 }
                        })
                        :onClick({ type = "FilePickerNavigateUp" })
                }),
            Element.new("div")
                :withStyle({
                    direction = "column",
                    height = "auto",
                    gap = 2,
                    padding = { top = 5, bottom = 5, left = 0, right = 0 }
                })
                :withChildren(fileTreeElements),
            bottomSection
        })
end

---@param state FilePickerState
---@param message { type: string, [string]: any }
---@param window Window
---@return Task?
function FilePicker.update(state, message, window)
    if message.type == "FilePickerDirectoryClicked" then
        if state.expandedDirectories[message.path] then
            state.expandedDirectories[message.path] = nil
        else
            state.expandedDirectories[message.path] = true
        end
        return Task.refreshView(window)

    elseif message.type == "FilePickerNavigateUp" then
        local parentPath = state.currentPath:match("^(.+)/[^/]*$")
        if parentPath and parentPath ~= "" then
            state.currentPath = parentPath
        else
            state.currentPath = "."
        end
        state.directoryContents[state.currentPath] = nil
        return Task.refreshView(window)

    elseif message.type == "FilePickerFileSelected" then
        if state.mode == "open" then
            state.selectedFile = message.path
        else -- save mode
            state.fileName = message.name
            state.selectedFile = nil
        end
        return Task.refreshView(window)

    elseif message.type == "FilePickerFileNameClick" then
        -- TODO: Implement text input for filename
        return Task.refreshView(window)

    elseif message.type == "FilePickerConfirm" then
        local filePath
        if state.mode == "open" and state.selectedFile then
            filePath = state.selectedFile
        elseif state.mode == "save" and state.fileName and state.fileName ~= "" then
            filePath = state.currentPath .. "/" .. state.fileName
        end
        
        if filePath and state.onConfirm then
            local task = state.onConfirm(filePath)
            if task then
                return Task.chain({ task, Task.closeWindow(window) })
            else
                return Task.closeWindow(window)
            end
        end
        return Task.closeWindow(window)
    elseif message.type == "FilePickerCancel" then
        if state.onCancel then
            local task = state.onCancel()
            if task then
                return Task.chain({ task, Task.closeWindow(window) })
            else
                return Task.closeWindow(window)
            end
        end
        return Task.closeWindow(window)
    end

    return nil
end

return FilePicker
