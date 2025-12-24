package.path = package.path .. ";./packages/?/init.lua;./packages/?.lua"

local util = require("arisu-util")

local lexer = require("arisu-slang.lexer")
local parser = require("arisu-slang.parser")
local analyzer = require("arisu-slang.analyzer")

local src = [[
	type Test = vec4f;

	fn compute() {
		let x = vec4f(1, 0, 1, 0);
		let y = vec4f(0, 1, 0, 1);
		let z = x + ii;
		return z;
	}
]]

local tokens = lexer.lex(src)
local ast = parser.parse(tokens, src)
local tast = analyzer.analyze(ast, src)

-- util.dbg(tast)
