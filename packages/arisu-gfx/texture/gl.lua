local gl = require("arisu-opengl")
local gfx = require("arisu-gfx")

---@class gfx.gl.Texture
---@field framebuffer number
---@field id number? # if nil, it is the backbuffer (default framebuffer)
---@field context gfx.gl.Context? # only present if id is nil
local GLTexture = {}
GLTexture.__index = GLTexture

local formatMap = {
	[gfx.TextureFormat.Rgba8UNorm] = gl.RGBA8,
}

---@param device gfx.gl.Device
---@param descriptor gfx.TextureDescriptor
function GLTexture.new(device, descriptor)
	local levels = descriptor.mipLevelCount or 1
	local extents = descriptor.extents
	local format = assert(formatMap[descriptor.format], "Unsupported texture format")

	local id ---@type number
	if extents.dim == "1d" then
		local type = extents.count and gl.TEXTURE_1D_ARRAY or gl.TEXTURE_1D
		id = gl.createTextures(type, 1)[1]

		if extents.count then
			gl.textureStorage2D(id, levels, format, extents.width, extents.count)
		else
			gl.textureStorage1D(id, levels, format, extents.width)
		end
	elseif extents.dim == "2d" then
		local type = extents.count and gl.TEXTURE_2D_ARRAY or gl.TEXTURE_2D
		id = gl.createTextures(type, 1)[1]

		if extents.count then
			gl.textureStorage3D(id, levels, format, extents.width, extents.height, extents.count)
		else
			gl.textureStorage2D(id, levels, format, extents.width, extents.height)
		end
	elseif descriptor.extents.dim == "3d" then
		id = gl.createTextures(gl.TEXTURE_3D, 1)[1]
		gl.textureStorage3D(id, levels, format, extents.width, extents.height, extents.depth)
	else
		error("Unsupported texture extents")
	end

	return setmetatable({ framebuffer = 0, id = id }, GLTexture)
end

---@param framebuffer number
---@param id number?
---@param context gfx.gl.Context?
function GLTexture.fromRaw(framebuffer, id, context)
	return setmetatable({ framebuffer = framebuffer, id = id, context = context }, GLTexture)
end

---@param context gfx.gl.Context
function GLTexture.forContextViewport(context)
	return GLTexture.fromRaw(0, nil, context)
end

function GLTexture:destroy()
end

return GLTexture
