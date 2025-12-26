package.path = package.path .. ";./packages/?/init.lua;./packages/?.lua"

local util = require("arisu-util")

local lexer = require("arisu-slang.lexer")
local parser = require("arisu-slang.parser")
local analyzer = require("arisu-slang.analyzer")
local codegen = require("arisu-slang.codegen")

local src = [[
	type Test = vec4f;

	fn ttt(t: vec4f) {

	}

	fn compute() {
		const z = 22 + 44 + 213 * 231;
		const foo = { bar: 321 };
		const arr = foo.bar;
		const qux = "whatever";
		const eq = qux == "whatever";

		let x = vec4f(1, 0, 1, eq);
		let y = vec4f(0, 1, 0, 1);

		return z;
	}
]]

local tokens = lexer.lex(src)
local ast = parser.parse(tokens, src)
local tast = analyzer.analyze(ast, src)
local output = codegen.generate({ target = "glsl" }, tast, src)
print(output)

-- util.dbg(tast)
