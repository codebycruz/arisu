local ffi = require("ffi")

---@enum ImageChannels
local ImageChannels = {
    RGB = 3,
    RGBA = 4,
}

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

local function PPMP6Reader(content --[[@param content string]])
    local width, height, body = string.match(content, "^P6%s+(%d+)%s+(%d+)%s+%d+%s(.*)$")
    assert(width, "Invalid PPM file")

    local pixels = ffi.cast("const uint8_t*", body)
    return Image.new(tonumber(width), tonumber(height), ImageChannels.RGB, pixels, content)
end

---@param content string
---@return Image?
function Image.fromData(content)
    if string.sub(content, 1, 2) == "P6" then
        return PPMP6Reader(content)
    end

    return nil, "Unsupported image format"
end

---@param path string
---@return Image?
function Image.fromPath(path)
    local file, err = io.open(path, "rb")
    if not file then
        return nil, "Failed to open image file: " .. err
    end

    local content = file:read("*all")
    return Image.fromData(content)
end

return Image
