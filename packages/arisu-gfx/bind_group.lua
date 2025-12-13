---@class gfx.BindGroup
---@field entries gfx.BindGroupEntry[]
local BindGroup = {}
BindGroup.__index = BindGroup

---@alias gfx.ShaderStage
--- | "VERTEX"
--- | "FRAGMENT"
--- | "COMPUTE"

---@alias gfx.BindGroupEntry
--- | { binding: number, buffer: gfx.Buffer, visibility: gfx.ShaderStage[] }

---@param entries gfx.BindGroupEntry[]
function BindGroup.new(entries)
	return setmetatable({ entries = entries }, BindGroup)
end

return BindGroup
