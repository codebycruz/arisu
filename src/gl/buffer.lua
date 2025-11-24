local gl = require "src.bindings.gl"
local ffi = require("ffi")

---@class Buffer
---@field id number
local Buffer = {}
Buffer.__index = Buffer

function Buffer.new()
    local handle = ffi.new("GLuint[1]")
    gl.createBuffers(1, handle)
    return setmetatable({ id = handle[0] }, Buffer)
end

---@alias BufferDataType "u32" | "f32"

local typeSizes = {
    u32 = ffi.sizeof("uint32_t"),
    f32 = ffi.sizeof("float"),
}

local typeConstructors = {
    u32 = function(data)
        return ffi.new("uint32_t[?]", #data, data)
    end,
    f32 = function(data)
        return ffi.new("float[?]", #data, data)
    end,
}

---@param type BufferDataType
---@param data table?
function Buffer:setData(type, data)
    local constructor = assert(typeConstructors[type], "Invalid buffer data type: " .. tostring(type))
    gl.namedBufferData(self.id, #data * typeSizes[type], constructor(data), 0x88E4)
end

---@param type BufferDataType
---@param offset number
---@param data table
function Buffer:setSlice(type, offset, data)
    local constructor = assert(typeConstructors[type], "Invalid buffer data type: " .. tostring(type))
    gl.namedBufferSubData(self.id, offset, #data * typeSizes[type], constructor(data))
end

return Buffer
