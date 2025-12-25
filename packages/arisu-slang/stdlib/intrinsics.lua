local typing = require("arisu-slang.typing")

local intrinsics = {}

intrinsics.vars = {
	vec4f = typing.fn({ typing.f32, typing.f32, typing.f32, typing.f32 }, typing.vec4f),
	vec3f = typing.fn({ typing.f32, typing.f32, typing.f32 }, typing.vec3f),
	vec2f = typing.fn({ typing.f32, typing.f32 }, typing.vec2f),
}

intrinsics.types = {
	vec4f = typing.vec4f,
	vec3f = typing.vec3f,
	vec2f = typing.vec2f,
}

function intrinsics.asAnalyzerVars()
	local vars = {} ---@type table<string, slang.analyzer.VarInfo>

	for name, ty in pairs(intrinsics.vars) do
		vars[name] = { mut = false, type = ty }
	end

	return vars
end

function intrinsics.asAnalyzerTypes()
	local types = {} ---@type table<string, slang.Type>

	for name, ty in pairs(intrinsics.types) do
		types[name] = ty
	end

	return types
end

return intrinsics
