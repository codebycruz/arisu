local ffi = require("ffi")
local bit = require("bit")

ffi.cdef[[
    typedef struct {
        char magic[4];
        uint32_t width;
        uint32_t height;
        uint8_t channels;
        uint8_t colorspace;
    } qoi_header_t;
]]

local QOI = {}

local QOI_OP_RGB = 0b11111110
local QOI_OP_RGBA = 0b11111111

local QOI_OP_INDEX = 0b00
local QOI_OP_DIFF = 0b01
local QOI_OP_LUMA = 0b10
local QOI_OP_RUN = 0b11

local function hashPixel(r, g, b, a)
    return (r * 3 + g * 5 + b * 7 + a * 11) % 64
end

---@param value number
local function swapEndian(value)
    return bit.bor(
        bit.lshift(bit.band(value, 0xFF), 24),
        bit.lshift(bit.band(bit.rshift(value, 8), 0xFF), 16),
        bit.lshift(bit.band(bit.rshift(value, 16), 0xFF), 8),
        bit.band(bit.rshift(value, 24), 0xFF)
    )
end

function QOI.Decode(content)
    assert(QOI.isValid(content), "Invalid QOI file")

    local header = ffi.cast("const qoi_header_t*", content)

    local width = swapEndian(tonumber(header.width))
    local height = swapEndian(tonumber(header.height))
    local channels = tonumber(header.channels)
    local colorspace = tonumber(header.colorspace)

    local finalPixelCount = width * height
    local currentPixelCount = 0
    local pos = 14

    local index = ffi.new("uint8_t[64][4]")
    for i = 0, 63 do
        index[i][0] = 0
        index[i][1] = 0
        index[i][2] = 0
        index[i][3] = 255
    end

    local pixels = ffi.new("uint8_t[?]", width * height * channels)
    local pixelPos = 0

    local r, g, b, a = 0, 0, 0, 255

    while currentPixelCount < finalPixelCount do
        local op8 = string.byte(content, pos + 1)
        pos = pos + 1

        if op8 == QOI_OP_RGB then
            r = string.byte(content, pos + 1)
            g = string.byte(content, pos + 2)
            b = string.byte(content, pos + 3)
            pos = pos + 3
        elseif op8 == QOI_OP_RGBA then
            r = string.byte(content, pos + 1)
            g = string.byte(content, pos + 2)
            b = string.byte(content, pos + 3)
            a = string.byte(content, pos + 4)
            pos = pos + 4
        else
            local op2 = bit.rshift(op8, 6)
            if op2 == QOI_OP_INDEX then
                local idx = bit.band(op8, 0x3f)
                r = index[idx][0]
                g = index[idx][1]
                b = index[idx][2]
                a = index[idx][3]
            elseif op2 == QOI_OP_DIFF then
                local dr = bit.band(bit.rshift(op8, 4), 3) - 2
                local dg = bit.band(bit.rshift(op8, 2), 3) - 2
                local db = bit.band(op8, 3) - 2
                r = bit.band(r + dr, 0xff)
                g = bit.band(g + dg, 0xff)
                b = bit.band(b + db, 0xff)
            elseif op2 == QOI_OP_LUMA then
                local b2 = string.byte(content, pos + 1)
                pos = pos + 1
                local vg = bit.band(op8, 0x3f) - 32
                local vr = bit.band(bit.rshift(b2, 4), 0x0f) - 8 + vg
                local vb = bit.band(b2, 0x0f) - 8 + vg
                r = bit.band(r + vr, 0xff)
                g = bit.band(g + vg, 0xff)
                b = bit.band(b + vb, 0xff)
            elseif op2 == QOI_OP_RUN then
                local run = bit.band(op8, 0x3f)
                for i = 0, run do
                    pixels[pixelPos] = r
                    pixels[pixelPos + 1] = g
                    pixels[pixelPos + 2] = b
                    if channels == 4 then
                        pixels[pixelPos + 3] = a
                    end
                    pixelPos = pixelPos + channels
                    currentPixelCount = currentPixelCount + 1
                end
                goto continue
            end
        end

        local hashIdx = hashPixel(r, g, b, a)
        index[hashIdx][0] = r
        index[hashIdx][1] = g
        index[hashIdx][2] = b
        index[hashIdx][3] = a

        pixels[pixelPos] = r
        pixels[pixelPos + 1] = g
        pixels[pixelPos + 2] = b
        if channels == 4 then
            pixels[pixelPos + 3] = a
        end
        pixelPos = pixelPos + channels
        currentPixelCount = currentPixelCount + 1

        ::continue::
    end

    return width, height, channels, pixels
end

function QOI.isValid(content)
    if #content < 14 then return false end
    local header = ffi.cast("const qoi_header_t*", content)
    local magic = ffi.string(header.magic, 4)
    return magic == "qoif"
end

return QOI
