---@class gfx.gl.Encoder
---@field commands gfx.EncoderCommand[]
local GLEncoder = {}
GLEncoder.__index = GLEncoder

function GLEncoder.new()
	return setmetatable({ commands = {} }, GLEncoder)
end

function GLEncoder:clear(color)
	self.commands[#self.commands + 1] = { type = "clear", color = color }
end

function GLEncoder:finish()
	return self.commands
end
