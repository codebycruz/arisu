package.path = package.path .. ";./packages/?/init.lua;./packages/?.lua"

local util = require("arisu-util")

local lexer = require("arisu-slang.lexer")
local parser = require("arisu-slang.parser")

local tokens = lexer.lex([[
	uniform(1, 2) f: i32;
]])

local ast = parser.parse(tokens)

util.dbg(ast)
