local span = require("arisu-slang.span")

local parser = {}

---@class slang.NumberNode: slang.Spanned
---@field variant "number"
---@field value number

---@class slang.StringNode: slang.Spanned
---@field variant "string"
---@field value string

---@class slang.BoolNode: slang.Spanned
---@field variant "bool"
---@field value boolean

---@class slang.IdentNode: slang.Spanned
---@field variant "ident"
---@field value string

---@class slang.DeclarationNode: slang.Spanned
---@field variant "let"
---@field annotation slang.TypeNode?
---@field name slang.IdentNode
---@field value slang.Node

---@class slang.UniformDefinitionNode: slang.Spanned
---@field variant "uniform"
---@field name slang.IdentNode
---@field binding number
---@field group number
---@field annotation slang.TypeNode

---@class slang.StorageBufferDefinitionNode: slang.Spanned
---@field variant "storage"
---@field name slang.IdentNode
---@field binding number
---@field group number
---@field annotation slang.TypeNode

---@class slang.TypeNode: slang.Spanned
---@field variant "type"
---@field parsed slang.ParsedType

---@class slang.AddNode: slang.Spanned
---@field variant "+"
---@field lhs slang.Node
---@field rhs slang.Node

---@class slang.SubNode: slang.Spanned
---@field variant "-"
---@field lhs slang.Node
---@field rhs slang.Node

---@class slang.MulNode: slang.Spanned
---@field variant "*"
---@field lhs slang.Node
---@field rhs slang.Node

---@class slang.DivNode: slang.Spanned
---@field variant "/"
---@field lhs slang.Node
---@field rhs slang.Node

---@class slang.IndexNode: slang.Spanned
---@field variant "index"
---@field object slang.Node
---@field index slang.Node

---@class slang.FunctionNode: slang.Spanned
---@field variant "function"
---@field name slang.IdentNode
---@field params { name: slang.IdentNode, type: slang.TypeNode, modifier: string }[]
---@field returnType slang.TypeNode?
---@field body slang.Node

---@class slang.NotNode: slang.Spanned
---@field variant "not"
---@field value slang.Node

---@class slang.IfNode: slang.Spanned
---@field variant "if"
---@field condition slang.Node
---@field body slang.Node[]
---@field elseStmt slang.Node|nil

---@class slang.ReturnNode: slang.Spanned
---@field variant "return"
---@field value slang.Node

---@class slang.BlockNode: slang.Spanned
---@field variant "block"
---@field statements slang.Node[]

---@class slang.CallNode: slang.Spanned
---@field variant "call"
---@field callee slang.Node
---@field arguments slang.Node[]

---@class slang.TestNode: slang.Spanned
---@field variant "test"
---@field name slang.StringNode
---@field body slang.Node

---@class slang.RecordInitNode: slang.Spanned
---@field variant "recordInit"
---@field fields { name: string, value: slang.Node }[]

---@class slang.TypeDefinitionNode: slang.Spanned
---@field variant "typedef"
---@field name slang.IdentNode
---@field type slang.TypeNode

---@class slang.ConstBlockNode: slang.Spanned
---@field variant "constBlock"
---@field body slang.Node

---@class slang.ConstDefinitionNode: slang.Spanned
---@field variant "const"
---@field name slang.IdentNode
---@field value slang.Node

---@alias slang.Node
--- | slang.NumberNode
--- | slang.StringNode
--- | slang.BoolNode
--- | slang.IdentNode
--- | slang.DeclarationNode
--- | slang.UniformDefinitionNode
--- | slang.StorageBufferDefinitionNode
--- | slang.TypeNode
--- | slang.AddNode
--- | slang.SubNode
--- | slang.MulNode
--- | slang.DivNode
--- | slang.IndexNode
--- | slang.FunctionNode
--- | slang.NotNode
--- | slang.IfNode
--- | slang.ReturnNode
--- | slang.BlockNode
--- | slang.CallNode
--- | slang.TestNode
--- | slang.RecordInitNode
--- | slang.TypeDefinitionNode
--- | slang.ConstBlockNode
--- | slang.ConstDefinitionNode

---@class slang.ParsedExternType # name
---@field variant "extern"
---@field name string

---@class slang.ParsedGenericDesc # name<inner>
---@field variant "generic"
---@field name string
---@field inner slang.ParsedType

---@class slang.ParsedArrayType # [inner; size]
---@field variant "array"
---@field inner slang.ParsedType
---@field size number

---@class slang.ParsedTupleType # (type, type, ...)
---@field variant "tuple"
---@field elements slang.ParsedType[]

---@class slang.ParsedRecordType # { field: type, ... }
---@field variant "record"
---@field format "packed" | "std140" | "std430"
---@field fields { name: string, fieldType: slang.ParsedType }[]

---@alias slang.ParsedType
--- | slang.ParsedExternType
--- | slang.ParsedGenericDesc
--- | slang.ParsedArrayType
--- | slang.ParsedTupleType
--- | slang.ParsedRecordType

---@param tokens slang.Token[]
---@param src string
function parser.parse(tokens, src)
	local idx, len = 1, #tokens

	local function peek()
		return tokens[idx]
	end

	local function prev()
		return tokens[idx - 1]
	end

	local function pop()
		idx = idx + 1
		return tokens[idx - 1]
	end

	---@param start slang.Spanned
	---@param finish slang.Spanned?
	local function spanned(start, finish) ---@return slang.Spanned
		finish = finish or prev()
		return { start = start.span.start, finish = finish.span.finish }
	end

	local function consume(ty) ---@return slang.Token?
		local token = tokens[idx]
		if token and token.variant == ty then
			idx = idx + 1
			return token
		end
	end

	local function ident()
		return consume("ident") --[[@as slang.IdentToken|nil]]
	end

	local function number()
		return consume("number") --[[@as slang.NumberToken|nil]]
	end

	local expression, statement, block

	local function atom()
		local token = pop()

		if token.variant == "(" then
			local expr = assert(expression(), "Expected expression after '('")
			assert(consume(")"), "Expected ')' after expression")
			return expr
		end

		if token.variant == "const" then
			local body = assert(block(), "Expected block after 'const'")
			return {
				variant = "constBlock",
				body = body,
				span = spanned(token, body),
			}
		end

		if token.variant == "{" then
			local fields = {}
			while not consume("}") do
				local fieldNameToken = assert(ident(), "Expected field name in record initialization")
				assert(consume(":"), "Expected ':' after field name in record initialization")
				local fieldValue = assert(expression(), "Expected expression for field value in record initialization")
				fields[#fields + 1] = { name = fieldNameToken.value, value = fieldValue }
				consume(",")
			end

			return {
				variant = "recordInit",
				fields = fields,
				span = spanned(token, prev()),
			}
		end

		local e ---@type slang.Node?
		if token.variant == "number" or token.variant == "string" or token.variant == "ident" then
			e = token --[[@as slang.Node]]
		end

		if token.variant == "true" or token.variant == "false" then
			e = {
				variant = "bool",
				value = (token.variant == "true"),
				span = token.span,
			}
		end

		if e.variant == "ident" then
			repeat
				local cont = false

				if consume(".") then
					local name = assert(ident(), "Expected identifier after '.'")
					e = {
						variant = "index",
						object = e,
						index = { variant = "string", value = name.value, span = name.span },
						span = spanned(e, name),
					}

					cont = true
				end

				if consume("[") then
					local indexExpr = assert(expression(), "Expected expression after '['")
					assert(consume("]"), "Expected ']' after index expression")

					e = {
						variant = "index",
						object = e,
						index = indexExpr,
						span = spanned(e, indexExpr),
					}

					cont = true
				end

				if consume("(") then
					local args = {}
					while not consume(")") do
						local argExpr = assert(expression(), "Expected expression in function call")
						args[#args + 1] = argExpr
						consume(",")
					end

					e = {
						variant = "call",
						callee = e,
						arguments = args,
						span = spanned(e, prev()),
					}

					cont = true
				end
			until not cont
		end

		if not e then -- Failed to match, rewind
			idx = idx - 1
		end

		return e
	end

	---@param inner fun(): slang.Node?
	---@param ops string[]
	local function foldLeft(inner, ops) ---@return slang.Node?
		local lhs = inner()
		if not lhs then
			return
		end

		while idx <= len do
			local op
			for _, opType in ipairs(ops) do
				local matched = consume(opType)
				if matched then
					op = matched
					break
				end
			end

			if not op then
				break
			end

			local rhs = assert(inner(), "Expected expression after '" .. op.variant .. "'")
			lhs = { variant = op.variant, lhs = lhs, rhs = rhs, span = spanned(lhs, rhs) }
		end

		return lhs
	end

	function expression()
		if consume("!") then
			return {
				variant = "not",
				value = assert(expression(), "Expected expression after '!'"),
				span = prev().span,
			}
		end

		return foldLeft(function()
			return foldLeft(function()
				return foldLeft(atom, { "*", "/" })
			end, { "+", "-" })
		end, { "<", ">", "<=", ">=", "==", "!=" })
	end

	local function type() ---@return slang.TypeNode?
		local token = pop()

		if not token then
			return
		end

		if token.variant == "ident" then
			if consume("<") then
				local inner = assert(type(), "Expected type inside generic type")
				assert(consume(">"), "Expected '>' after generic type")

				return {
					variant = "type",
					parsed = { variant = "generic", name = token.value, inner = inner },
					span = spanned(token),
				}
			end

			return { variant = "type", parsed = { variant = "extern", name = token.value }, span = spanned(token) }
		end

		-- Failed to match, rewind
		idx = idx - 1
	end

	function block() ---@return slang.Node?
		if not consume("{") then
			return
		end

		local stmts = {}
		while not consume("}") do
			local stmt = assert(statement(), "Expected statement in block")
			consume(";")
			stmts[#stmts + 1] = stmt
		end

		return { variant = "block", statements = stmts, span = spanned(prev()) }
	end

	function statement() ---@return slang.Node?
		local token = pop()

		if token.variant == "type" then
			local name = assert(ident(), "Expected identifier after 'type'")
			assert(consume("="), "Expected '=' after type name")
			local slangType = assert(type(), "Expected type after '=' in type definition")

			return {
				variant = "typedef",
				name = name,
				type = slangType,
				span = spanned(token, slangType),
			}
		end

		if token.variant == "let" or token.variant == "const" then
			local name = assert(ident(), "Expected identifier")

			local annotation
			if consume(":") then
				annotation = assert(type(), "Expected type after ':' in declaration")
			end

			assert(consume("="), "Expected '=' after identifier in declaration")
			local value = assert(expression(), "Expected expression after '=' in declaration")
			return { variant = token.variant, name = name, value = value, annotation = annotation, span = spanned(token) }
		end

		if token.variant == "fn" then
			local name = assert(ident(), "Expected identifier after 'fn'")
			assert(consume("("), "Expected '(' after function name")

			local params = {}
			while not consume(")") do
				local paramName = assert(ident(), "Expected parameter name")
				assert(consume(":"), "Expected ':' after parameter name")
				local paramType = assert(type(), "Expected parameter type")
				params[#params + 1] = { name = paramName, type = paramType }
				consume(",")
			end

			local body = assert(block(), "Expected function body")

			return {
				variant = "function",
				name = name,
				params = params,
				returnType = nil,
				body = body,
				span = spanned(token),
			}
		end

		if token.variant == "if" then
			local condition = assert(expression(), "Expected condition after 'if'")
			local body = assert(block(), "Expected block after 'if' condition")
			local elseStmt = consume("else") and assert(statement() or block(), "Expected 'else' block or statement")

			return {
				variant = "if",
				condition = condition,
				body = body,
				elseStmt = elseStmt,
				span = spanned(token),
			}
		end

		if token.variant == "return" then
			local value = assert(expression(), "Expected expression after 'return'")
			return {
				variant = "return",
				value = value,
				span = spanned(token),
			}
		end

		if token.variant == "test" then
			local nameToken = assert(consume("string"), "Expected string literal after 'test'")
			local body = assert(block(), "Expected block after test name")

			return {
				variant = "test",
				name = nameToken,
				body = body,
				span = spanned(token),
			}
		end

		local varVariant = token.variant
		if varVariant == "uniform" or varVariant == "storage" then
			local binding
			local group = 0

			assert(consume("("), "Expected '(' after " .. varVariant .. " declaration")
			binding = assert(number(), "Expected binding number").value
			if consume(",") then
				group = assert(number(), "Expected group number").value
			end
			assert(consume(")"), "Expected ')' after binding/group")

			local name = assert(ident(), "Expected identifier after " .. varVariant .. " declaration")
			assert(consume(":"), "Expected ':' after name")
			local slangType = assert(type(), "Expected type after ':' in " .. varVariant .. " declaration")

			return {
				variant = varVariant,
				name = name,
				binding = binding,
				group = group,
				type = slangType,
				span = spanned(token, slangType),
			}
		end

		-- Failed to match, rewind
		idx = idx - 1
	end

	local stmts = {}
	while idx <= len do
		local stmt = statement()
		if not stmt then
			local token = peek()
			local variant = token and token.variant or "EOF"
			local resolved = span.resolve(src, (token or prev()).span)

			error("Unexpected token: " .. variant .. " at line " .. resolved.start.line .. ", col " .. resolved.start.col)
		end

		consume(";")
		stmts[#stmts + 1] = stmt
	end

	return { variant = "block", statements = stmts, span = spanned(stmts[1]) }
end

return parser
