local Bitmap = require("arisu-text.font.bitmap")

---@alias Font number

---@class FontManager
---@field textureManager TextureManager
---@field bitmaps table<Font, Bitmap>
---@field defaultFont Font
local FontManager = {}
FontManager.__index = FontManager

local dirName = debug.getinfo(1, "S").source:sub(2):match("(.*/)")

---@param textureManager TextureManager
function FontManager.new(textureManager)
	local self = setmetatable({ textureManager = textureManager, bitmaps = {} }, FontManager)

	local characters = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"

	print("..!", dirName)
	local defaultBitmap = assert(
		Bitmap.fromPath(
			{ ymargin = 2, xmargin = 4, gridWidth = 18, gridHeight = 18, characters = characters, perRow = 19 },
			dirName .. "../assets/fonts/JetBrainsMono.qoi"
		),
		"Failed to load bitmap font"
	)
	self.defaultFont = self:upload(defaultBitmap)

	return self
end

---@param bitmap Bitmap
---@return Font
function FontManager:upload(bitmap)
	local id = self.textureManager:upload(bitmap.image)
	self.bitmaps[id] = bitmap
	return id
end

function FontManager:getDefault()
	return self.defaultFont
end

---@param font Font
---@return Bitmap
function FontManager:getBitmap(font)
	return self.bitmaps[font]
end

return FontManager
