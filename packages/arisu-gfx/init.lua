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

return gfx
