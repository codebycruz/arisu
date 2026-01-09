local glslcg = require("arisu-slang.codegen.glsl")
local cppcg = require("arisu-slang.codegen.cpp")
local spirvcg = require("arisu-slang.codegen.spirv")

---@alias slang.codegen.Entrypoint "vertex" | "fragment" | "compute"

local codegen = {}

---@alias slang.codegen.Config
--- | slang.codegen.glsl.Config
--- | slang.codegen.cpp.Config
--- | slang.codegen.spirv.Config

---@param config slang.codegen.Config
---@param tast slang.TypedNode
---@param src string
function codegen.generate(config, tast, src)
	if config.target == "glsl" then
		return glslcg.generate(config, tast, src)
	elseif config.target == "cpp" then
		return cppcg.generate(config, tast, src)
	elseif config.target == "spirv" then
		return spirvcg.generate(config, tast, src)
	else
		error("Unsupported codegen target: " .. tostring(config.target))
	end
end

return codegen
