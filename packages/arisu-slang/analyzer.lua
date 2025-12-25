local typing = require("arisu-slang.typing")
local span = require("arisu-slang.span")

local analyzer = {}

---@class slang.TypedNumberNode: slang.NumberNode
---@field variant "number"
---@field type slang.Type

---@class slang.TypedStringNode: slang.StringNode
---@field variant "string"
---@field type slang.Type

---@class slang.TypedIdentNode: slang.IdentNode
---@field variant "ident"
---@field type slang.Type

---@class slang.TypedDeclarationNode: slang.DeclarationNode
---@field variant "let"
---@field type slang.Type

---@class slang.TypedUniformDefinitionNode: slang.UniformDefinitionNode
---@field variant "uniform"
---@field type slang.Type

---@class slang.TypedStorageBufferDefinitionNode: slang.StorageBufferDefinitionNode
---@field variant "storage"
---@field type slang.Type

---@class slang.TypedAddNode: slang.AddNode
---@field variant "+"
---@field type slang.Type

---@class slang.TypedSubNode: slang.SubNode
---@field variant "-"
---@field type slang.Type

---@class slang.TypedMulNode: slang.MulNode
---@field variant "*"
---@field type slang.Type

---@class slang.TypedDivNode: slang.DivNode
---@field variant "/"
---@field type slang.Type

---@class slang.TypedIndexNode: slang.IndexNode
---@field variant "index"
---@field type slang.Type

---@class slang.TypedFunctionNode: slang.FunctionNode
---@field variant "fn"
---@field type slang.Type

---@class slang.TypedNotNode: slang.NotNode
---@field variant "!"
---@field type slang.Type

---@class slang.TypedIfNode: slang.IfNode
---@field variant "if"
---@field type slang.Type

---@class slang.TypedReturnNode: slang.ReturnNode
---@field variant "return"
---@field type slang.Type

---@class slang.TypedBlockNode: slang.BlockNode
---@field variant "block"
---@field type slang.Type

---@class slang.TypedCallNode: slang.CallNode
---@field variant "call"
---@field type slang.Type

---@class slang.TypedTestNode: slang.TestNode
---@field variant "test"
---@field type slang.Type

---@class slang.TypedRecordInitNode: slang.RecordInitNode
---@field variant "recordInit"
---@field type slang.Type

---@alias slang.TypedNode
--- | slang.TypedNumberNode
--- | slang.TypedStringNode
--- | slang.TypedIdentNode
--- | slang.TypedDeclarationNode
--- | slang.TypedUniformDefinitionNode
--- | slang.TypedStorageBufferDefinitionNode
--- | slang.TypedAddNode
--- | slang.TypedSubNode
--- | slang.TypedMulNode
--- | slang.TypedDivNode
--- | slang.TypedIndexNode
--- | slang.TypedFunctionNode
--- | slang.TypedNotNode
--- | slang.TypedIfNode
--- | slang.TypedReturnNode
--- | slang.TypedBlockNode
--- | slang.TypedCallNode
--- | slang.TypedTestNode
--- | slang.TypedRecordInitNode

---@class slang.AnalyzerScope
---@field vars table<string, { mut: boolean, type: slang.Type }>
---@field types table<string, slang.Type>

---@param ast slang.Node
---@param src string
---@return slang.TypedNode
function analyzer.analyze(ast, src)
	---@type slang.AnalyzerScope[]
	local scopes = {
		{
			vars = {
				vec4f = { mut = false, type = typing.fn({ typing.f32, typing.f32, typing.f32, typing.f32 }, typing.vec4f) },
				vec3f = { mut = false, type = typing.fn({ typing.f32, typing.f32, typing.f32 }, typing.vec3f) },
				vec2f = { mut = false, type = typing.fn({ typing.f32, typing.f32 }, typing.vec2f) },
			},
			types = {
				vec4f = typing.vec4f,
				vec3f = typing.vec3f,
				vec2f = typing.vec2f,
			},
		},
	}

	local function pushScope()
		local scope = { vars = {} }
		scopes[#scopes + 1] = scope
		return scope
	end

	local function popScope()
		scopes[#scopes] = nil
	end

	local function lookupVar(name)
		for i = #scopes, 1, -1 do
			local scope = scopes[i]
			if scope.vars[name] then
				return scope.vars[name]
			end
		end
		return nil
	end

	local function lookupType(name)
		for i = #scopes, 1, -1 do
			local scope = scopes[i]
			if scope.types and scope.types[name] then
				return scope.types[name]
			end
		end
		return nil
	end

	---@param n slang.TypeNode
	---@return slang.Type
	local function type(n)
		if n.parsed.variant == "extern" then
			local parsed = n.parsed ---@cast parsed slang.ParsedExternType
			local ty = lookupType(parsed.name)
			if not ty then
				error("Unknown type: " .. parsed.name)
			end

			return ty
		end

		error("Unimplemented type resolution for variant: " .. n.parsed.variant)
	end

	---@param s slang.Node
	---@return slang.TypedNode
	local function node(s)
		if s.variant == "number" then
			s.type = typing.f32
		elseif s.variant == "string" then
			s.type = typing.string
		elseif s.variant == "bool" then
			s.type = typing.bool
		elseif s.variant == "ident" then
			local var = lookupVar(s.value)
			if not var then
				local resolved = span.resolve(src, s.span)
				error("Undefined variable: " .. s.value .. " at line " .. resolved.start.line .. ", col " .. resolved.start.col)
			end

			s.type = var.type
		elseif s.variant == "let" then
			s.type = node(s.value).type
			scopes[#scopes].vars[s.name.value] = { mut = false, type = s.type }
		elseif s.variant == "uniform" then
			s.type = type(s.annotation)
			scopes[#scopes].vars[s.name.value] = { mut = false, type = s.type }
		elseif s.variant == "storage" then
			s.type = type(s.annotation)
			scopes[#scopes].vars[s.name.value] = { mut = false, type = s.type }
		elseif s.variant == "+" then
			local lhsType = node(s.lhs).type
			local rhsType = node(s.rhs).type

			if lhsType ~= rhsType then
				error("Type mismatch in addition: " .. lhsType.type .. " + " .. rhsType.type)
			end

			s.type = lhsType
		elseif s.variant == "-" then
			local lhsType = node(s.lhs).type
			local rhsType = node(s.rhs).type

			if lhsType ~= rhsType then
				error("Type mismatch in subtraction: " .. lhsType.type .. " - " .. rhsType.type)
			end

			s.type = lhsType
		elseif s.variant == "*" then
			local lhsType = node(s.lhs).type
			local rhsType = node(s.rhs).type

			if lhsType ~= rhsType then
				error("Type mismatch in multiplication: " .. lhsType.type .. " * " .. rhsType.type)
			end

			s.type = lhsType
		elseif s.variant == "/" then
			local lhsType = node(s.lhs).type
			local rhsType = node(s.rhs).type

			if lhsType ~= rhsType then
				error("Type mismatch in division: " .. lhsType.type .. " / " .. rhsType.type)
			end

			s.type = lhsType
		elseif s.variant == "index" then
			error("index unimplemented")
		elseif s.variant == "function" then
			local scope = pushScope()
			for _, param in ipairs(s.params) do
				scope.vars[param.name] = { type = type(param.type) }
			end

			node(s.body)
			popScope()
		elseif s.variant == "not" then ---@cast s slang.NotNode
			local operandType = node(s.value).type
			if operandType.type ~= "bool" then
				error("Operand of '!' must be of type bool, got " .. operandType.type)
			end

			s.type = typing.bool
		elseif s.variant == "if" then
			local condType = node(s.condition).type
			if condType.type ~= "bool" then
				error("Condition in if statement must be of type bool, got " .. condType.type)
			end

			pushScope()
			node(s.body)
			popScope()

			if s.elseStmt then
				pushScope()
				node(s.elseStmt)
				popScope()
			end
		elseif s.variant == "return" then
			node(s.value)
		elseif s.variant == "block" then
			for _, stmt in ipairs(s.statements) do
				node(stmt)
			end
		elseif s.variant == "call" then
			node(s.callee)
			for _, arg in ipairs(s.arguments) do
				node(arg)
			end
		elseif s.variant == "test" then
			pushScope()
			node(s.body)
			popScope()
		elseif s.variant == "type" then
			error("Type nodes should not be analyzed directly")
		elseif s.variant == "recordInit" then
			local fieldTypes = {}
			for _, field in ipairs(s.fields) do
				fieldTypes[field.name] = node(field.value).type
			end
			s.type = typing.record(fieldTypes)
		elseif s.variant == "typedef" then
			scopes[#scopes].types[s.name.value] = type(s.type)
			s.type = typing.void
		else
			error("Unimplemented analyzer for variant: " .. s.variant)
		end

		return s
	end

	return node(ast) ---@as slang.TypedNode
end

return analyzer
