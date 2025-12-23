local util = require("arisu-util")

---@alias slang.Span { start: number, finish: number }

---@class slang.Spanned
---@field span slang.Span

---@class slang.IdentToken: slang.Spanned
---@field type "ident"
---@field value string

---@class slang.NumberToken: slang.Spanned
---@field type "number"
---@field value number

---@class slang.StringToken: slang.Spanned
---@field type "string"
---@field value string

---@class slang.FnToken: slang.Spanned
---@field type "fn"

---@class slang.LeftCurlyToken: slang.Spanned
---@field type "{"

---@class slang.RightCurlyToken: slang.Spanned
---@field type "}"

---@class slang.LeftParenToken: slang.Spanned
---@field type "("

---@class slang.RightParenToken: slang.Spanned
---@field type ")"

---@class slang.CommaToken: slang.Spanned
---@field type ","

---@class slang.ColonToken: slang.Spanned
---@field type ":"

---@class slang.SemicolonToken: slang.Spanned
---@field type ";"

---@class slang.EqualToken: slang.Spanned
---@field type "="

---@class slang.AddToken: slang.Spanned
---@field type "+"

---@class slang.SubToken: slang.Spanned
---@field type "-"

---@class slang.MulToken: slang.Spanned
---@field type "*"

---@class slang.DivToken: slang.Spanned
---@field type "/"

---@class slang.DotToken: slang.Spanned
---@field type "."

---@class slang.NotToken: slang.Spanned
---@field type "!"

---@class slang.EqualsToken: slang.Spanned
---@field type "=="

---@class slang.NotEqualsToken: slang.Spanned
---@field type "!="

---@class slang.LessThanToken: slang.Spanned
---@field type "<"

---@class slang.GreaterThanToken: slang.Spanned
---@field type ">"

---@class slang.LessThanOrEqualToken: slang.Spanned
---@field type "<="

---@class slang.GreaterThanOrEqualToken: slang.Spanned
---@field type ">="

---@class slang.UniformToken: slang.Spanned
---@field type "uniform"

---@class slang.StorageToken: slang.Spanned
---@field type "storage"

---@class slang.LetToken: slang.Spanned
---@field type "let"

---@class slang.ReturnToken: slang.Spanned
---@field type "return"

---@class slang.IfToken: slang.Spanned
---@field type "if"

---@class slang.ElseToken: slang.Spanned
---@field type "else"

---@class slang.WhileToken: slang.Spanned
---@field type "while"

---@class slang.ForToken: slang.Spanned
---@field type "for"

---@class slang.TestToken: slang.Spanned
---@field type "test"

---@alias slang.Token
--- | slang.IdentToken
--- | slang.NumberToken
--- | slang.StringToken
--- | slang.FnToken
--- | slang.LeftCurlyToken
--- | slang.RightCurlyToken
--- | slang.LeftParenToken
--- | slang.RightParenToken
--- | slang.CommaToken
--- | slang.ColonToken
--- | slang.SemicolonToken
--- | slang.EqualToken
--- | slang.AddToken
--- | slang.SubToken
--- | slang.MulToken
--- | slang.DivToken
--- | slang.DotToken
--- | slang.NotToken
--- | slang.EqualsToken
--- | slang.NotEqualsToken
--- | slang.LessThanToken
--- | slang.GreaterThanToken
--- | slang.LessThanOrEqualToken
--- | slang.GreaterThanOrEqualToken
--- | slang.UniformToken
--- | slang.StorageToken
--- | slang.LetToken
--- | slang.ReturnToken
--- | slang.IfToken
--- | slang.ElseToken
--- | slang.WhileToken
--- | slang.ForToken
--- | slang.TestToken

local lexer = {}

local keywords = util.toLookupTable({
	"fn",
	"uniform",
	"storage",
	"let",
	"return",
	"if",
	"else",
	"while",
	"for",
	"test",
})

local operators = util.toLookupTable({
	"+",
	"-",
	"*",
	"/",
	"=",
	"==",
	"!=",
	"<",
	">",
	"<=",
	">=",
	".",
	",",
	";",
	":",
	"{",
	"}",
	"(",
	")",
	"!",
})

---@param src string
function lexer.lex(src)
	local ptr, len = 1, #src
	local tokens = {}

	---@param pattern string
	---@return string?
	local function consume(pattern)
		local s, e, match = string.find(src, pattern, ptr)
		if s == ptr then
			ptr = e + 1
			return match
		end

		return nil
	end

	---@param startPtr number
	local function span(startPtr)
		return { start = startPtr, finish = ptr - 1 }
	end

	---@return slang.Token?
	local function token()
		local startPtr = ptr

		local float = consume("^([0-9]+%.[0-9]+)")
		if float then
			return { type = "number", value = tonumber(float), span = span(startPtr) }
		end

		local int = consume("^([0-9]+)")
		if int then
			return { type = "number", value = tonumber(int), span = span(startPtr) }
		end

		-- TODO: replace this with an actual string parser
		local str = consume('^"([^"]*)"')
		if str then
			return { type = "string", value = str, span = span(startPtr) }
		end

		local ident = consume("^([a-zA-Z_][a-zA-Z0-9_]*)")
		if ident then
			if keywords[ident] then
				return { type = ident, span = span(startPtr) }
			else
				return { type = "ident", value = ident, span = span(startPtr) }
			end
		end

		if ptr + 2 <= len then
			local op3 = string.sub(src, ptr, ptr + 2)
			if operators[op3] then
				ptr = ptr + 3
				return { type = op3, span = span(startPtr) }
			end
		end

		if ptr + 1 <= len then
			local op2 = string.sub(src, ptr, ptr + 1)
			if operators[op2] then
				ptr = ptr + 2
				return { type = op2, span = span(startPtr) }
			end
		end

		local op1 = string.sub(src, ptr, ptr)
		if operators[op1] then
			ptr = ptr + 1
			return { type = op1, span = span(startPtr) }
		end

		error("Lexer: unrecognized token at position " .. ptr)
	end

	while true do
		while consume("^%s+") or consume("^//[^\n]*\n") do
		end

		if ptr > len then
			break
		end

		tokens[#tokens + 1] = token()
	end

	return tokens
end

return lexer
