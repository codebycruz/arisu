local cppcg = {}

---@class slang.codegen.cpp.Config
---@field target "cpp"
---@field entry slang.codegen.Entrypoint

---@param config slang.codegen.cpp.Config
---@param tast slang.TypedNode
---@param src string
---@return string
function cppcg.generate(config, tast, src) end

return cppcg
