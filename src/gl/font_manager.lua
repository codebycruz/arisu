---@alias Font number

---@class FontManager
---@field textureManager TextureManager
---@field bitmaps table<Font, Bitmap>
local FontManager = {}
FontManager.__index = FontManager

---@param textureManager TextureManager
function FontManager.new(textureManager)
    return setmetatable({ textureManager = textureManager, bitmaps = {} }, FontManager)
end

---@param bitmap Bitmap
---@return Font
function FontManager:upload(bitmap)
    local id = self.textureManager:upload(bitmap.image)
    self.bitmaps[id] = bitmap
    return id
end

return FontManager
