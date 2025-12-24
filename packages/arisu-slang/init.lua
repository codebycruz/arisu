package.path = package.path .. ";./packages/?/init.lua;./packages/?.lua"

local util = require("arisu-util")

local lexer = require("arisu-slang.lexer")
local parser = require("arisu-slang.parser")
local analyzer = require("arisu-slang.analyzer")

local tokens = lexer.lex([[
	fn compute() {
		let x = vec4(1, 0, 1, 0);
		let y = vec4(0, 1, 0, 1);
		let z = x + y;
		return z;
	}

	test "foo" {
		let x = 2;
	}
]])

local ast = parser.parse(tokens)
local tast = analyzer.analyze(ast)

util.dbg(ast)
