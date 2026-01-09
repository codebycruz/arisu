---@alias hood.Color { r: number, g: number, b: number, a: number }

local hood = {}

--- No. You aren't getting a full implementation of this anytime soon.
---@enum hood.BlendState
hood.BlendState = {
	ALPHA_BLENDING = 1,
}

---@enum hood.ColorWrites
hood.ColorWrites = {
	RED = 0b1,
	GREEN = 0b10,
	BLUE = 0b100,
	ALPHA = 0b1000,
	COLOR = 0b0111,
	ALL = 0b1111,
}

---@enum hood.TextureFormat
hood.TextureFormat = {
	-- Equates to OpenGL's gl.RGBA + gl.UNSIGNED_BYTE
	Rgba8UNorm = 1,
	Rgba8Uint = 2,

	Depth16Unorm = 3,
	Depth24Plus = 4,
	Depth32Float = 5,
}

---@enum hood.AddressMode
hood.AddressMode = {
	CLAMP_TO_EDGE = 1,
	REPEAT = 2,
	MIRRORED_REPEAT = 3,
}

---@enum hood.FilterMode
hood.FilterMode = {
	NEAREST = 1,
	LINEAR = 2,
}

---@enum hood.CompareFunction
hood.CompareFunction = {
	NEVER = 1,
	LESS = 2,
	EQUAL = 3,
	LESS_EQUAL = 4,
	GREATER = 5,
	NOT_EQUAL = 6,
	GREATER_EQUAL = 7,
	ALWAYS = 8,
}

---@enum hood.IndexFormat
hood.IndexType = {
	u16 = 1,
	u32 = 2,
}

---@alias hood.ShaderModule
---| { type: "glsl", source: string }
---| { type: "spirv", source: string }

return hood
