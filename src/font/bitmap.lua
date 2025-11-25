local Image = require "src.image"
local ffi = require("ffi")

---@class BitmapConfig
---@field characters string
---@field gridWidth number
---@field gridHeight number
---@field perRow number

---@class Bitmap
---@field config BitmapConfig
---@field image Image
local Bitmap = {}
Bitmap.__index = Bitmap

---@alias BitmapQuad { x: number, y: number, u0: number, v0: number, u1: number, v1: number, width: number, height: number }

---@param char string
---@param x number
---@param y number
---@return BitmapQuad
function Bitmap:getCharQuad(char, x, y)
    local charIdx = assert(self.config.characters:find(char, 1, true), "Character '" .. char .. "' not found in bitmap characters.") - 1
    local row = math.floor(charIdx / self.config.perRow)
    local col = charIdx % self.config.perRow

    local u0 = col * self.config.gridWidth / self.image.width
    local v0 = row * self.config.gridHeight / self.image.height
    local u1 = (col + 1) * self.config.gridWidth / self.image.width
    local v1 = (row + 1) * self.config.gridHeight / self

    return {
        x = x,
        y = y,
        u0 = u0,
        v0 = v0,
        u1 = u1,
        v1 = v1,
        width = self.config.gridWidth,
        height = self.config.gridHeight,
    }
end

---@param string string
---@param x number
---@param y number
---@return BitmapQuad[]
function Bitmap:getStringQuads(string, x, y)
    local quads = {}
    for i = 1, #string do
        local char = string:sub(i, i)
        local quad = self:getCharQuad(char, x + (i - 1) * self.config.gridWidth, y)

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

    return setmetatable({ config = bitmapConfig, image = img}, Bitmap)
end

---@param bitmapConfig BitmapConfig
---@param path string
function Bitmap.fromPath(bitmapConfig, path)
    local img, err = Image.fromPath(path)
    if not img then
        return nil, "Failed to load bitmap image from path: " .. err
    end

    return setmetatable({ config = bitmapConfig, image = img}, Bitmap)
end

function Bitmap.isValid(content --[[@param content string]])
    return Image.isValid(content)
end

return Bitmap
