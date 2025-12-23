package.path = package.path .. ";./packages/?/init.lua;./packages/?.lua"

local util = require("arisu-util")

local lexer = require("arisu-slang.lexer")
local parser = require("arisu-slang.parser")

local tokens = lexer.lex([[
	fn compute() {
		let x = vec4(1, 0, 1, 0);
	}
]])

local ast = parser.parse(tokens)

util.dbg(ast)
