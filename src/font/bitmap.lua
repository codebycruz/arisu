local Image = require("image")
local ffi = require("ffi")

---@class BitmapConfig
---@field characters string
---@field gridWidth number
---@field gridHeight number
---@field perRow number
---@field xmargin number?
---@field ymargin number?

---@class Bitmap
---@field config BitmapConfig
---@field image Image
local Bitmap = {}
Bitmap.__index = Bitmap

---@alias BitmapQuad { x: number, y: number, u0: number, v0: number, u1: number, v1: number, width: number, height: number }

---@param char string
---@return BitmapQuad
function Bitmap:getCharUVs(char)
	local charIdx = assert(
		self.config.characters:find(char, 1, true),
		"Character '" .. char .. "' not found in bitmap characters."
	) - 1
	local row = math.floor(charIdx / self.config.perRow)
	local col = charIdx % self.config.perRow

	local xmargin = self.config.xmargin or 0
	local ymargin = self.config.ymargin or 0

	local u0 = (col * self.config.gridWidth + xmargin) / self.image.width
	local v0 = (row * self.config.gridHeight + ymargin) / self.image.height
	local u1 = ((col + 1) * self.config.gridWidth - xmargin) / self.image.width
	local v1 = ((row + 1) * self.config.gridHeight - ymargin) / self.image.height

	return {
		u0 = u0,
		v0 = v0,
		u1 = u1,
		v1 = v1,
		width = self.config.gridWidth - (xmargin * 2),
		height = self.config.gridHeight - (ymargin * 2),
	}
end

---@param string string
---@return BitmapQuad[]
function Bitmap:getStringUVs(string)
	local quads = {}
	for i = 1, #string do
		local char = string:sub(i, i)
		local quad = self:getCharUVs(char)

		table.insert(quads, quad)
	end

	return quads
end

---@param bitmapConfig BitmapConfig
---@param content string
function Bitmap.fromData(bitmapConfig, content)
	local img, err = Image.fromData(content)
	if not img then
		return nil, "Failed to decode bitmap image: " .. err
	end

	return setmetatable({ config = bitmapConfig, image = img }, Bitmap)
end

---@param bitmapConfig BitmapConfig
---@param path string
function Bitmap.fromPath(bitmapConfig, path)
	local img, err = Image.fromPath(path)
	if not img then
		return nil, "Failed to load bitmap image from path: " .. err
	end

	return setmetatable({ config = bitmapConfig, image = img }, Bitmap)
end

function Bitmap.isValid(
	content --[[@param content string]]
)
	return Image.isValid(content)
end

return Bitmap
