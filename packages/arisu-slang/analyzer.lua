---@class slang.F32Type
---@field type "f32"

---@class slang.I32Type
---@field type "i32"

---@class slang.SamplerType
---@field type "sampler"

---@class slang.VecType<T>: { type: "vec", len: number, elementType: T }
---@field type "vec"
---@field len number
---@field elementType slang.Type

---@alias slang.Type
--- | slang.F32Type
--- | slang.I32Type
--- | slang.SamplerType
--- | slang.VecType<slang.F32Type>
