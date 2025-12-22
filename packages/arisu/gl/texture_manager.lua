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
---@field device gfx.Device
---@field textures TextureMetadata[]
---@field textureCount number
---@field textureDimsBuffer gfx.Buffer
---@field texture gfx.gl.Texture
---@field sampler gfx.Sampler
---@field whiteTexture Texture
---@field errorTexture Texture
local TextureManager = {}
TextureManager.__index = TextureManager

---@param device gfx.Device
function TextureManager.new(device)
	local texture = device:createTexture({
		extents = { dim = "2d", width = maxWidth, height = maxHeight, count = maxLayers },
		format = gfx.TextureFormat.Rgba8UNorm,
		usages = { "TEXTURE_BINDING", "COPY_DST", "COPY_SRC" },
	})

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
		texture = texture,
		sampler = sampler,
		device = device,
		textures = {},
	}, TextureManager)

	this.whiteTexture = this:upload(Image.new(1, 1, 4, ffi.new("uint8_t[?]", 3, { 255, 255, 255, 255 }), ""))
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
	self.texture:destroy()
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

	-- todo: is this right?
	local dims = ffi.new("float[4]", width, height, 0, 0)
	self.device.queue:writeBuffer(self.textureDimsBuffer, 16, dims, layer * 16)

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
		self.texture.id,
		gl.TEXTURE_2D_ARRAY,
		0,
		0,
		0,
		source,
		self.texture.id,
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

	-- Update dimensions
	local dims = ffi.new("float[4]", image.width, image.height, 0, 0)
	self.device.queue:writeBuffer(self.textureDimsBuffer, 16, dims, texture * 16)

	self.device.queue:writeTexture(self.texture, { layer = texture, width = image.width, height = image.height },
		image.pixels)
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
	return self.device:createBindGroup({
		{
			type = "texture",
			binding = binding,
			texture = self.texture,
			visibility = { "FRAGMENT" },
		},
		{
			type = "sampler",
			binding = samplerBinding,
			sampler = self.sampler,
			visibility = { "FRAGMENT" },
		},
		{
			type = "buffer",
			binding = dimsBinding,
			buffer = self.textureDimsBuffer,
			visibility = { "FRAGMENT" },
		},
	})
end

return TextureManager
