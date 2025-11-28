local PPM = require "src.image.ppm"
local QOI = require "src.image.qoi"

---@class Image
---@field buffer string
---@field pixels userdata # RGBA or RGB pixel data
---@field width number
---@field height number
---@field channels number
local Image = {}
Image.__index = Image

---@param width number
---@param height number
---@param channels number
---@param pixels userdata
---@param buffer string
---@return Image
function Image.new(width, height, channels, pixels, buffer)
	return setmetatable({ width = width, height = height, channels = channels, pixels = pixels, buffer = buffer }, Image)
end

---@param x number
---@param y number
---@return number[] # Array of channel values
function Image:getPixel(x, y)
	assert(x >= 0 and x < self.width, "X coordinate out of bounds")
	assert(y >= 0 and y < self.height, "Y coordinate out of bounds")

	local index = (y * self.width + x) * self.channels

	local pixel = {}
	for c = 0, self.channels - 1 do
		pixel[c + 1] = self.pixels[index + c]
	end

	return pixel
end

---@param content string
---@return Image?
function Image.fromData(content)
	if PPM.isValid(content) then
		local width, height, channels, pixels = PPM.Decode(content)
		return Image.new(width, height, channels, pixels, content)
	end

	if QOI.isValid(content) then
		local width, height, channels, pixels = QOI.Decode(content)
		return Image.new(width, height, channels, pixels, content)
	end

	return nil, "Unsupported image format"
end

function Image.isValid(content)
	return PPM.isValid(content) or QOI.isValid(content)
end

---@param path string
---@return Image?
function Image.fromPath(path)
	local file, err = io.open(path, "rb")
	if not file then
		return nil, "Failed to open image file: " .. err
	end

	local content = file:read "*all"
	return Image.fromData(content)
end

return Image
