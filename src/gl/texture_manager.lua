local gl = require "src.bindings.gl"
local ffi = require("ffi")

local maxWidth = 1024
local maxHeight = 1024
local maxLayers = 256

---@alias Texture number

---@class TextureManager
---@field textures Texture[]
---@field sampler2DArray Uniform
local TextureManager = {}
TextureManager.__index = TextureManager

---@param sampler2DArray Uniform
function TextureManager.new(sampler2DArray)
    gl.createTextures(gl.TEXTURE_2D_ARRAY, 1, ffi.new("GLuint[1]", sampler2DArray.id))
    gl.textureStorage3D(sampler2DArray.id, 1, gl.RGBA8, maxWidth, maxHeight, maxLayers)

    return setmetatable({ sampler2DArray = sampler2DArray, textures = {} }, TextureManager)
end

function TextureManager:destroy()
    gl.deleteTextures(1, ffi.new("GLuint[1]", self.sampler2DArray.id))
end

---@param image Image
---@return Texture
function TextureManager:upload(image)
    local layer = #self.textures
    if layer >= maxLayers then
        error("Maximum number of texture layers reached")
    end

    local format = ({
        [2] = gl.RG,
        [3] = gl.RGB,
        [4] = gl.RGBA,
    })[image.channels]

    assert(format, "Unsupported number of channels: " .. tostring(image.channels))

    gl.textureSubImage3D(
        self.sampler2DArray.id,
        0,
        0,
        0,
        layer,
        image.width,
        image.height,
        1,
        format,
        gl.UNSIGNED_BYTE,
        image.pixels
    )

    table.insert(self.textures, layer)
    return layer
end

return TextureManager
