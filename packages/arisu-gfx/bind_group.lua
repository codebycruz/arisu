---@class gfx.BindGroup
---@field entries gfx.BindGroupEntry[]
local BindGroup = {}
BindGroup.__index = BindGroup

---@alias gfx.ShaderStage
--- | "VERTEX"
--- | "FRAGMENT"
--- | "COMPUTE"

---@alias gfx.StorageAccess
--- | "READ_ONLY"
--- | "WRITE_ONLY"
--- | "READ_WRITE"

---@alias gfx.BindGroupEntry
--- | { type: "buffer", binding: number, buffer: gfx.Buffer, visibility: gfx.ShaderStage[] }
--- | { type: "sampler", binding: number, sampler: gfx.Sampler, visibility: gfx.ShaderStage[] }
--- | { type: "texture", binding: number, texture: gfx.Texture, visibility: gfx.ShaderStage[] }
--- | { type: "storageTexture", binding: number, texture: gfx.Texture, layer: number?, access: gfx.StorageAccess, visibility: gfx.ShaderStage[] }

---@param entries gfx.BindGroupEntry[]
function BindGroup.new(entries)
	return setmetatable({ entries = entries }, BindGroup)
end

return BindGroup
