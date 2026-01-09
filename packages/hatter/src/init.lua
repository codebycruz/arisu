package.path = package.path .. ";./packages/?/init.lua;./packages/?.lua"

local util = require("arisu-util")

local lexer = require("hatter.lexer")
local parser = require("hatter.parser")
local analyzer = require("hatter.analyzer")
local codegen = require("hatter.codegen")

local src = [[
	const std = require("stdlib");

	type vec4 = vec4f;
	type vec3 = vec3f;
	type vec2 = vec2f;

	uniform(0) foo: vec4;
	const bar = "qux";

	pub fn fragment(
		vertexColor: vec4,
		texCoord: vec2,
		texIndex: i32
	) {
	}

	pub fn compute() {
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
local tast, globalScope = analyzer.analyze(ast, src)
local output = codegen.generate({ target = "glsl", entry = "fragment" }, tast, src)

print(output)

-- util.dbg(tast)
