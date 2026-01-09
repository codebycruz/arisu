---@class hood.BindGroup
---@field entries hood.BindGroupEntry[]
local BindGroup = {}
BindGroup.__index = BindGroup

---@alias hood.ShaderStage
--- | "VERTEX"
--- | "FRAGMENT"
--- | "COMPUTE"

---@alias hood.StorageAccess
--- | "READ_ONLY"
--- | "WRITE_ONLY"
--- | "READ_WRITE"

---@alias hood.BindGroupEntry
--- | { type: "buffer", binding: number, buffer: hood.Buffer, visibility: hood.ShaderStage[] }
--- | { type: "sampler", binding: number, sampler: hood.Sampler, visibility: hood.ShaderStage[] }
--- | { type: "texture", binding: number, texture: hood.Texture, visibility: hood.ShaderStage[] }
--- | { type: "storageTexture", binding: number, texture: hood.Texture, layer: number?, access: hood.StorageAccess, visibility: hood.ShaderStage[] }

---@param entries hood.BindGroupEntry[]
function BindGroup.new(entries)
	return setmetatable({ entries = entries }, BindGroup)
end

return BindGroup
