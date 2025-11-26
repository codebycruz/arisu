local gl = require "src.bindings.gl"
local ffi = require("ffi")

local Image = require "src.image"

local maxWidth = 1024
local maxHeight = 1024
local maxLayers = 256

---@alias Texture number
---@alias TextureMetadata { width: number, height: number, image?: Image }

---@class TextureManager
---@field textures TextureMetadata[]
---@field textureCount number
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

    local this = setmetatable({ textureCount = 0, textureDims = {}, textureDimsUniform = textureDims, textureHandle = textureHandle, textureUnit = textureUnit, sampler2DArray = sampler2DArray, textures = {} }, TextureManager)
    this.whiteTexture = this:upload(Image.new(1, 1, 3, ffi.new("uint8_t[?]", 3, {255, 255, 255}), ""))
    this.errorTexture = this:upload(
        Image.new(2, 2, 4, ffi.new("uint8_t[?]", 12, {
        255, 0, 255, 255,   0, 0, 0, 255,
        0, 0, 0, 255,       255, 0, 255, 255
    }), ""))

    return this
end

function TextureManager:destroy()
    gl.deleteTextures(1, ffi.new("GLuint[1]", self.sampler2DArray.id))
end

---@param width number
---@param height number
---@return Texture
function TextureManager:allocate(width, height)
    local layer = self.textureCount
    if layer >= maxLayers then
        error("Maximum number of texture layers reached")
    end

    self.textures[layer] = { width = width, height = height }

    self.textureDims[layer * 4 + 1] = width
    self.textureDims[layer * 4 + 2] = height
    self.textureDims[layer * 4 + 3] = 0 -- padding
    self.textureDims[layer * 4 + 4] = 0 -- padding
    self.textureDimsUniform:set("u32", self.textureDims)

    self.textureCount = self.textureCount + 1

    return layer
end

---@param source Texture
---@param destination Texture
function TextureManager:copy(source, destination)
    assert(self.textures[source], "Source texture does not exist")
    assert(self.textures[destination], "Destination texture does not exist")

    local width = math.min(self.textures[source].width, self.textures[destination].width)
    local height = math.min(self.textures[source].height, self.textures[destination].height)

    gl.copyImageSubData(
        self.textureHandle,
        gl.TEXTURE_2D_ARRAY,
        0,
        0,
        0,
        source,
        self.textureHandle,
        gl.TEXTURE_2D_ARRAY,
        0,
        0,
        0,
        destination,
        width,
        height,
        1
    )
end

---@param image Image
function TextureManager:update(texture, image)
    assert(self.textures[texture], "Texture does not exist")

    local format = ({
        [2] = gl.RG,
        [3] = gl.RGB,
        [4] = gl.RGBA,
    })[image.channels]

    assert(format, "Unsupported number of channels: " .. tostring(image.channels))

    self.textureDims[texture * 4 + 1] = image.width
    self.textureDims[texture * 4 + 2] = image.height
    self.textureDimsUniform:set("u32", self.textureDims)

    gl.textureSubImage3D(
        self.textureHandle,
        0,
        0,
        0,
        texture,
        image.width,
        image.height,
        1,
        format,
        gl.UNSIGNED_BYTE,
        image.pixels
    )
end

---@param image Image
function TextureManager:upload(image)
    local texture = self:allocate(image.width, image.height)
    self:update(texture, image)
    return texture
end

function TextureManager:bind()
    gl.bindTextureUnit(self.textureUnit, self.textureHandle)
    self.sampler2DArray:set(self.textureUnit)
end

function TextureManager:unbind()
    gl.bindTextureUnit(self.textureUnit, 0)
end

return TextureManager
