local gl = require "src.bindings.gl"
local ffi = require("ffi")

local Image = require "src.image"

local maxWidth = 1024
local maxHeight = 1024
local maxLayers = 256

---@alias Texture number

---@class TextureManager
---@field textures Texture[]
---@field textureDims number[]
---@field textureDimsUniform UniformBlock
---@field sampler2DArray Uniform
---@field textureUnit number
---@field textureHandle number
---@field whiteTexture Texture
---@field errorTexture Texture
local TextureManager = {}
TextureManager.__index = TextureManager

---@param sampler2DArray Uniform
---@param textureDims UniformBlock
---@param textureUnit number
function TextureManager.new(sampler2DArray, textureDims, textureUnit)
    assert(sampler2DArray.type == "sampler2DArray", "sampler2DArray must be of type sampler2DArray")
    assert(textureUnit, "textureUnit is required")

    local textureId = ffi.new("GLuint[1]")
    gl.createTextures(gl.TEXTURE_2D_ARRAY, 1, textureId)
    local textureHandle = textureId[0]

    gl.textureStorage3D(textureHandle, 1, gl.RGBA8, maxWidth, maxHeight, maxLayers)
    gl.textureParameteri(textureHandle, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
    gl.textureParameteri(textureHandle, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
    gl.textureParameteri(textureHandle, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
    gl.textureParameteri(textureHandle, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)

    local this = setmetatable({ textureDims = {}, textureDimsUniform = textureDims, textureHandle = textureHandle, textureUnit = textureUnit, sampler2DArray = sampler2DArray, textures = {} }, TextureManager)
    this.whiteTexture = this:upload(Image.new(1, 1, 3, ffi.new("uint8_t[?]", 3, {255, 255, 255}), ""))
    this.errorTexture = this:upload(
        Image.new(2, 2, 3, ffi.new("uint8_t[?]", 12, {
        255, 0, 255,   0, 0, 0,
        0, 0, 0,       255, 0, 255
    }), ""))

    return this
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
        self.textureHandle,
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

    table.insert(self.textures, {
        image = image,
    })

    -- Yeah this is gonna break as soon as we start deallocating textures :)
    table.insert(self.textureDims, image.width)
    table.insert(self.textureDims, image.height)
    table.insert(self.textureDims, 0)
    table.insert(self.textureDims, 0)
    self.textureDimsUniform:set("u32", self.textureDims)

    return layer
end

function TextureManager:bind()
    gl.bindTextureUnit(self.textureUnit, self.textureHandle)
    self.sampler2DArray:set(self.textureUnit)
end

function TextureManager:unbind()
    gl.bindTextureUnit(self.textureUnit, 0)
end

return TextureManager
