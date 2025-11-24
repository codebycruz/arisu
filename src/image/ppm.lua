local ffi = require("ffi")

local PPM = {}

function PPM.Decode(content --[[@param content string]])
    local width, height, body = string.match(content, "^P6%s+(%d+)%s+(%d+)%s+%d+%s(.*)$")
    assert(width, "Invalid PPM file")

    local pixels = ffi.cast("const uint8_t*", body)
    return tonumber(width), tonumber(height), 3, pixels
end

function PPM.IsValid(content --[[@param content string]])
    return string.sub(content, 1, 2) == "P6"
end

return PPM
