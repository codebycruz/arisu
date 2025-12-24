---@class slang.F32Type
---@field type "f32"

---@class slang.I32Type
---@field type "i32"

---@class slang.SamplerType
---@field type "sampler"

---@class slang.StringType
---@field type "string"

---@class slang.BoolType
---@field type "bool"

---@class slang.VecType<T>: { type: "vec", len: number, elementType: T }
---@field type "vec"
---@field len number
---@field elementType slang.Type

---@class slang.FnType
---@field type "function"
---@field params slang.Type[]
---@field ret slang.Type

---@class slang.VoidType
---@field type "void"

---@alias slang.Type<T>
--- | slang.F32Type
--- | slang.I32Type
--- | slang.StringType
--- | slang.BoolType
--- | slang.SamplerType
--- | slang.FnType
--- | slang.VecType<T>
--- | slang.VoidType

local typing = {}

typing.f32 = { type = "f32" }
typing.i32 = { type = "i32" }
typing.sampler = { type = "sampler" }

typing.vec4f = { type = "vec", len = 4, elementType = typing.f32 }
typing.vec3f = { type = "vec", len = 3, elementType = typing.f32 }
typing.vec2f = { type = "vec", len = 2, elementType = typing.f32 }

typing.vec4i = { type = "vec", len = 4, elementType = typing.i32 }
typing.vec3i = { type = "vec", len = 3, elementType = typing.i32 }
typing.vec2i = { type = "vec", len = 2, elementType = typing.i32 }

typing.string = { type = "string" }
typing.bool = { type = "bool" }
typing.void = { type = "void" }

---@param params slang.Type[]
---@param ret slang.Type
function typing.fn(params, ret)
	return { type = "fn", params = params, ret = ret }
end

return typing
