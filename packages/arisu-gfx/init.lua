---@alias gfx.Color { r: number, g: number, b: number, a: number }

local gfx = {}

--- No. You aren't getting a full implementation of this anytime soon.
---@enum gfx.BlendState
gfx.BlendState = {
	ALPHA_BLENDING = 1,
}

---@enum gfx.ColorWrites
gfx.ColorWrites = {
	RED = 0b1,
	GREEN = 0b10,
	BLUE = 0b100,
	ALPHA = 0b1000,
	COLOR = 0b0111,
	ALL = 0b1111,
}

---@enum gfx.TextureFormat
gfx.TextureFormat = {
	RGBA8_UNORM = 1,
}

---@enum gfx.AddressMode
gfx.AddressMode = {
	CLAMP_TO_EDGE = 1,
	REPEAT = 2,
	MIRRORED_REPEAT = 3,
}

---@enum gfx.FilterMode
gfx.FilterMode = {
	NEAREST = 1,
	LINEAR = 2,
}

---@enum gfx.CompareFunction
gfx.CompareFunction = {
	NEVER = 1,
	LESS = 2,
	EQUAL = 3,
	LESS_EQUAL = 4,
	GREATER = 5,
	NOT_EQUAL = 6,
	GREATER_EQUAL = 7,
	ALWAYS = 8,
}

return gfx
