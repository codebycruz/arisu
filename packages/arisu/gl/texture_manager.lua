local ffi = require("ffi")

local util = require("arisu-util")
local gl = require("arisu-opengl")
local gfx = require("arisu-gfx")

local Image = require("arisu-image")

local maxWidth = 1024
local maxHeight = 1024
local maxLayers = 256

---@alias Texture number
---@alias TextureMetadata { width: number, height: number, image?: Image }

---@class TextureManager
---@field textures TextureMetadata[]
---@field textureCount number
---@field textureDimsBuffer gfx.Buffer
---@field textureHandle number
---@field sampler gfx.Sampler
---@field whiteTexture Texture
---@field errorTexture Texture
local TextureManager = {}
TextureManager.__index = TextureManager

---@param device gfx.Device
function TextureManager.new(device)
	local textureId = ffi.new("GLuint[1]")
	gl.createTextures(gl.TEXTURE_2D_ARRAY, 1, textureId)
	local textureHandle = textureId[0]

	gl.textureStorage3D(textureHandle, 1, gl.RGBA8, maxWidth, maxHeight, maxLayers)

	local sampler = device:createSampler({
		minFilter = gfx.FilterMode.NEAREST,
		magFilter = gfx.FilterMode.NEAREST,
		addressModeU = gfx.AddressMode.CLAMP_TO_EDGE,
		addressModeV = gfx.AddressMode.CLAMP_TO_EDGE,
		addressModeW = gfx.AddressMode.CLAMP_TO_EDGE,
	})

	-- Use vec4 for proper alignment
	local textureDimsBuffer = device:createBuffer({
		size = maxLayers * util.sizeof("f32") * 4,
		usages = { "UNIFORM", "COPY_DST" },
	})

	local this = setmetatable({
		textureCount = 0,
		textureDimsBuffer = textureDimsBuffer,
		textureHandle = textureHandle,
		sampler = sampler,
		textures = {},
	}, TextureManager)

	this.whiteTexture = this:upload(Image.new(1, 1, 3, ffi.new("uint8_t[?]", 3, { 255, 255, 255 }), ""))
	this.errorTexture = this:upload(Image.new(
		2,
		2,
		4,
		ffi.new(
			"uint8_t[?]",
			16,
			{
				255, 0, 255, 255,
				0, 0, 0, 255,
				0, 0, 0, 255,
				255, 0, 255, 255
			}
		),
		""
	))

	return this
end

function TextureManager:destroy()
	gl.deleteTextures(1, ffi.new("GLuint[1]", self.textureHandle))
	self.textureDimsBuffer:destroy()
	self.sampler:destroy()
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

	-- Update dimensions in buffer
	local dims = ffi.new("float[4]", width, height, 0, 0)
	self.textureDimsBuffer:setData(dims, layer * 16, 16)

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

	-- Update dimensions
	local dims = ffi.new("float[4]", image.width, image.height, 0, 0)
	self.textureDimsBuffer:write(dims, texture * 16, 16)

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

---Create a bind group for this texture manager
---@param binding number The binding index for the texture array
---@param samplerBinding number The binding index for the sampler
---@param dimsBinding number The binding index for the dimensions buffer
---@return gfx.BindGroup
function TextureManager:createBindGroup(binding, samplerBinding, dimsBinding)
	return gfx.BindGroup.new({
		{
			binding = binding,
			texture = self.textureHandle,
			visibility = { gfx.ShaderStage.FRAGMENT },
		},
		{
			binding = samplerBinding,
			sampler = self.sampler,
			visibility = { gfx.ShaderStage.FRAGMENT },
		},
		{
			binding = dimsBinding,
			buffer = self.textureDimsBuffer,
			visibility = { gfx.ShaderStage.FRAGMENT },
		},
	})
end

return TextureManager
