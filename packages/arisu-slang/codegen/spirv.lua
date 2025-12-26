local spirvcg = {}

---@class slang.codegen.spirv.Config
---@field target "spirv"
---@field entry slang.codegen.Entrypoint

---@param config slang.codegen.spirv.Config
---@param tast slang.TypedNode
---@param src string
---@return string
function spirvcg.generate(config, tast, src) end

return spirvcg
