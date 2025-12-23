local parser = {}

---@class slang.NumberNode: slang.Spanned
---@field type "number"
---@field value number

---@class slang.StringNode: slang.Spanned
---@field type "string"
---@field value string

---@class slang.IdentNode: slang.Spanned
---@field type "ident"
---@field name string

---@class slang.DeclarationNode: slang.Spanned
---@field type "let"
---@field annotation slang.TypeNode?
---@field name slang.IdentNode
---@field value slang.Node

---@class slang.UniformDefinitionNode: slang.Spanned
---@field type "uniform"
---@field name slang.IdentNode
---@field binding number
---@field group number
---@field slangType slang.TypeNode

---@class slang.StorageBufferDefinitionNode: slang.Spanned
---@field type "storage_buffer"
---@field name slang.IdentNode
---@field binding number
---@field group number
---@field slangType slang.TypeNode

---@class slang.TypeNode: slang.Spanned
---@field type "type"
---@field slangType slang.Type

---@class slang.AddNode: slang.Spanned
---@field type "add"
---@field lhs slang.Node
---@field rhs slang.Node

---@class slang.SubNode: slang.Spanned
---@field type "sub"
---@field lhs slang.Node
---@field rhs slang.Node

---@class slang.MulNode: slang.Spanned
---@field type "mul"
---@field lhs slang.Node
---@field rhs slang.Node

---@class slang.DivNode: slang.Spanned
---@field type "div"
---@field lhs slang.Node
---@field rhs slang.Node

---@class slang.IndexNode: slang.Spanned
---@field type "index"
---@field object slang.Node
---@field index slang.Node

---@class slang.FunctionNode: slang.Spanned
---@field type "function"
---@field name slang.IdentNode
---@field params { name: slang.IdentNode, type: slang.TypeNode, modifier: string }[]
---@field returnType slang.TypeNode?
---@field body slang.Node[]

---@class slang.NotNode: slang.Spanned
---@field type "not"
---@field value slang.Node

---@class slang.IfNode: slang.Spanned
---@field type "if"
---@field condition slang.Node
---@field body slang.Node[]
---@field elseStmt slang.Node|nil

---@class slang.ReturnNode: slang.Spanned
---@field type "return"
---@field value slang.Node

---@class slang.BlockNode: slang.Spanned
---@field type "block"
---@field statements slang.Node[]

---@alias slang.Node
--- | slang.NumberNode
--- | slang.StringNode
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

---@param tokens slang.Token[]
function parser.parse(tokens)
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

	---@param start slang.Token
	---@param finish slang.Token?
	local function spanned(start, finish) ---@return slang.Spanned
		finish = finish or prev()
		return { start = start.span.start, finish = finish.span.finish }
	end

	local function consume(ty) ---@return slang.Token?
		local token = tokens[idx]
		if token and token.type == ty then
			idx = idx + 1
			return token
		end
	end

	local function ident()
		return consume("ident") --[[@as slang.IdentNode|nil]]
	end

	local function number()
		return consume("number") --[[@as slang.NumberNode|nil]]
	end

	local function atom()
		local token = pop()

		if token.type == "number" or token.type == "string" or token.type == "ident" then
			return token
		end

		-- Failed to match, rewind
		idx = idx - 1
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

			local rhs = assert(inner(), "Expected expression after '" .. op.type .. "'")
			lhs = { type = op.type, lhs = lhs, rhs = rhs, span = spanned(lhs, rhs) }
		end

		return lhs
	end

	local function expression()
		if consume("!") then
			return {
				type = "not",
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

		if token.type == "ident" then
			if consume("<") then
				local inner = assert(type(), "Expected type inside generic type")
				assert(consume(">"), "Expected '>' after generic type")

				if token.value == "vec2" or token.value == "vec3" or token.value == "vec4" then
					return {
						type = "type",
						slangType = {
							type = "vec",
							len = tonumber(string.sub(token.value, 4)),
							elementType = inner.slangType,
						},
					}
				end
			end

			return { type = "type", name = token.value, span = token.span }
		end

		-- Failed to match, rewind
		idx = idx - 1
	end

	local statement
	local function block() ---@return slang.Node?
		if not consume("{") then
			return
		end

		local stmts = {}
		while not consume("}") do
			local stmt = assert(statement(), "Expected statement in block")
			consume(";")
			stmts[#stmts + 1] = stmt
		end

		return { type = "block", statements = stmts, span = spanned(prev()) }
	end

	function statement() ---@return slang.Node?
		local token = pop()

		if token.type == "let" then
			local name = assert(ident(), "Expected identifier after 'let'")

			local annotation
			if consume(":") then
				annotation = assert(type(), "Expected type after ':' in declaration")
			end

			assert(consume("="), "Expected '=' after identifier in declaration")
			local value = assert(expression(), "Expected expression after '=' in declaration")
			return { type = "let", name = name, value = value, annotation = annotation, span = spanned(token) }
		end

		if token.type == "fn" then
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
				type = "function",
				name = name,
				params = params,
				returnType = nil,
				body = body,
				span = spanned(token),
			}
		end

		if token.type == "if" then
			local condition = assert(expression(), "Expected condition after 'if'")
			local body = assert(block(), "Expected block after 'if' condition")
			local elseStmt = consume("else") and assert(statement() or block(), "Expected 'else' block or statement")

			return {
				type = "if",
				condition = condition,
				body = body,
				elseStmt = elseStmt,
				span = spanned(token),
			}
		end

		if token.type == "return" then
			local value = assert(expression(), "Expected expression after 'return'")
			return {
				type = "return",
				value = value,
				span = spanned(token),
			}
		end

		local varStorageType = token.type
		if varStorageType == "uniform" or varStorageType == "storage" then
			local binding
			local group = 0

			assert(consume("("), "Expected '(' after " .. varStorageType .. " declaration")
			binding = assert(number(), "Expected binding number").value
			if consume(",") then
				group = assert(number(), "Expected group number").value
			end
			assert(consume(")"), "Expected ')' after binding/group")

			local name = assert(ident(), "Expected identifier after " .. varStorageType .. " declaration")
			assert(consume(":"), "Expected ':' after name")
			local slangType = assert(type(), "Expected type after ':' in " .. varStorageType .. " declaration")

			return {
				type = varStorageType,
				name = name,
				binding = binding,
				group = group,
				slangType = slangType,
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
			error("Unexpected token: " .. tostring(peek() and peek().type or "EOF"))
		end

		consume(";")
		stmts[#stmts + 1] = stmt
	end

	return stmts
end

return parser
