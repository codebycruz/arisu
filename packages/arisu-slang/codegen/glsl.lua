local typing = require("arisu-slang.typing")
local intrinsics = require("arisu-slang.stdlib.intrinsics")

local glslcg = {}

---@class slang.codegen.glsl.Config
---@field target "glsl"

local fmt = string.format

local function warn(msg)
	io.stderr:write("Warning: " .. msg .. "\n")
end

---@param config slang.codegen.glsl.Config
---@param tast slang.TypedNode
---@param src string
---@return string
function glslcg.generate(config, tast, src)
	---@param t slang.Type
	local function type(t)
		if t.type == "f32" then
			return "float"
		elseif t.type == "i32" then
			return "int"
		elseif t.type == "vec" then
			local elemType = type(t.elementType)
			return fmt("%svec%d", elemType == "float" and "" or "i", t.len)
		elseif t.type == "void" then
			return "void"
		else
			error("Unsupported type in GLSL codegen: " .. t.type)
		end
	end

	---@param n slang.TypedNode
	---@return string
	local function node(n)
		if n.variant == "uniform" then
			if n.group ~= 0 then
				warn("GLSL codegen does not support uniform groups")
			end

			return fmt("layout(binding = %d) uniform %s %s;", n.binding, type(n.type), n.name.value)
		elseif n.variant == "block" then
			local stmts = {} ---@type string[]
			for _, stmt in ipairs(n.statements) do
				stmts[#stmts + 1] = node(stmt)
			end

			return table.concat(stmts, "\n")
		elseif n.variant == "typedef" then
		elseif n.variant == "function" then
			local params = {} ---@type string[]
			for _, param in ipairs(n.params) do
				params[#params + 1] = fmt("%s %s", node(param.type), param.name.value)
			end

			local body = node(n.body)

			return fmt(
				"void %s(%s) {\n\t%s\n}",
				-- type(n.retType),
				n.name.value,
				table.concat(params, ", "),
				body:gsub("\n", "\n\t")
			)
		elseif n.variant == "let" then
			return fmt("%s %s = %s;", type(n.type), n.name.value, node(n.value))
		elseif n.variant == "call" then
			local args = {} ---@type string[]
			for _, arg in ipairs(n.arguments) do
				args[#args + 1] = node(arg)
			end

			-- Intrinsics, todo: convert into lookup
			if n.callee.type == intrinsics.vars.vec4f then
				return fmt("vec4(%s)", table.concat(args, ", "))
			end

			return fmt("%s(%s)", node(n.callee), table.concat(args, ", "))
		elseif n.variant == "number" then
			return tostring(n.value)
		elseif n.variant == "ident" then
			return n.value
		elseif n.variant == "+" then
			return fmt("(%s + %s)", node(n.lhs), node(n.rhs))
		elseif n.variant == "-" then
			return fmt("(%s - %s)", node(n.lhs), node(n.rhs))
		elseif n.variant == "*" then
			return fmt("(%s * %s)", node(n.lhs), node(n.rhs))
		elseif n.variant == "/" then
			return fmt("(%s / %s)", node(n.lhs), node(n.rhs))
		elseif n.variant == "return" then -- of course this is gonna have to turn into something else.
			return fmt("return %s;", node(n.value))
		else
			error("Unsupported node variant in GLSL codegen: " .. n.variant)
		end
	end

	return node(tast)
end

return glslcg
