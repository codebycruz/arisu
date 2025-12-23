---@class slang.F32Type
---@field type "f32"

---@class slang.I32Type
---@field type "i32"

---@class slang.SamplerType
---@field type "sampler"

---@class slang.VecType<T>: { type: "vec", elementType: T }
---@field type "vec4"
---@field len number
---@field elementType slang.Type

--- TODO: Probably want to make an unresolved and resolved type system separately.
---@alias slang.Type
--- | slang.F32Type
--- | slang.I32Type
--- | slang.SamplerType
--- | slang.VecType<slang.F32Type>
