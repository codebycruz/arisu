local util = require("arisu-util")

---@class slang.IdentToken: slang.Spanned
---@field variant "ident"
---@field value string

---@class slang.NumberToken: slang.Spanned
---@field variant "number"
---@field value number

---@class slang.StringToken: slang.Spanned
---@field variant "string"
---@field value string

---@class slang.FnToken: slang.Spanned
---@field variant "fn"

---@class slang.LeftCurlyToken: slang.Spanned
---@field variant "{"

---@class slang.RightCurlyToken: slang.Spanned
---@field variant "}"

---@class slang.LeftParenToken: slang.Spanned
---@field variant "("

---@class slang.RightParenToken: slang.Spanned
---@field variant ")"

---@class slang.LeftSquareToken: slang.Spanned
---@field variant "["

---@class slang.RightSquareToken: slang.Spanned
---@field variant "]"

---@class slang.CommaToken: slang.Spanned
---@field variant ","

---@class slang.ColonToken: slang.Spanned
---@field variant ":"

---@class slang.SemicolonToken: slang.Spanned
---@field variant ";"

---@class slang.EqualToken: slang.Spanned
---@field variant "="

---@class slang.AddToken: slang.Spanned
---@field variant "+"

---@class slang.SubToken: slang.Spanned
---@field variant "-"

---@class slang.MulToken: slang.Spanned
---@field variant "*"

---@class slang.DivToken: slang.Spanned
---@field variant "/"

---@class slang.DotToken: slang.Spanned
---@field variant "."

---@class slang.NotToken: slang.Spanned
---@field variant "!"

---@class slang.EqualsToken: slang.Spanned
---@field variant "=="

---@class slang.NotEqualsToken: slang.Spanned
---@field variant "!="

---@class slang.LessThanToken: slang.Spanned
---@field variant "<"

---@class slang.GreaterThanToken: slang.Spanned
---@field variant ">"

---@class slang.LessThanOrEqualToken: slang.Spanned
---@field variant "<="

---@class slang.GreaterThanOrEqualToken: slang.Spanned
---@field variant ">="

---@class slang.UniformToken: slang.Spanned
---@field variant "uniform"

---@class slang.StorageToken: slang.Spanned
---@field variant "storage"

---@class slang.LetToken: slang.Spanned
---@field variant "let"

---@class slang.ReturnToken: slang.Spanned
---@field variant "return"

---@class slang.IfToken: slang.Spanned
---@field variant "if"

---@class slang.ElseToken: slang.Spanned
---@field variant "else"

---@class slang.WhileToken: slang.Spanned
---@field variant "while"

---@class slang.ForToken: slang.Spanned
---@field variant "for"

---@class slang.TestToken: slang.Spanned
---@field variant "test"

---@class slang.TypeToken: slang.Spanned
---@field variant "type"

---@class slang.ConstToken: slang.Spanned
---@field variant "const"

---@class slang.TrueToken: slang.Spanned
---@field variant "true"

---@class slang.FalseToken: slang.Spanned
---@field variant "false"

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
--- | slang.TypeToken
--- | slang.ConstToken
--- | slang.TrueToken
--- | slang.FalseToken

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
	"type",
	"const",
	"true",
	"false",
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
	"[",
	"]",
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
			return { variant = "number", value = tonumber(float), span = span(startPtr) }
		end

		local int = consume("^([0-9]+)")
		if int then
			return { variant = "number", value = tonumber(int), span = span(startPtr) }
		end

		-- TODO: replace this with an actual string parser
		local str = consume('^"([^"]*)"')
		if str then
			return { variant = "string", value = str, span = span(startPtr) }
		end

		local ident = consume("^([a-zA-Z_][a-zA-Z0-9_]*)")
		if ident then
			if keywords[ident] then
				return { variant = ident, span = span(startPtr) }
			else
				return { variant = "ident", value = ident, span = span(startPtr) }
			end
		end

		if ptr + 2 <= len then
			local op3 = string.sub(src, ptr, ptr + 2)
			if operators[op3] then
				ptr = ptr + 3
				return { variant = op3, span = span(startPtr) }
			end
		end

		if ptr + 1 <= len then
			local op2 = string.sub(src, ptr, ptr + 1)
			if operators[op2] then
				ptr = ptr + 2
				return { variant = op2, span = span(startPtr) }
			end
		end

		local op1 = string.sub(src, ptr, ptr)
		if operators[op1] then
			ptr = ptr + 1
			return { variant = op1, span = span(startPtr) }
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
