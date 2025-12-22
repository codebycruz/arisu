local gl = require("arisu-opengl")
local gfx = require("arisu-gfx")

---@class gfx.gl.Texture
---@field framebuffer number
---@field id number? # if nil, it is the backbuffer (default framebuffer)
---@field context gfx.gl.Context? # only present if id is nil
---@field private descriptor gfx.TextureDescriptor
local GLTexture = {}
GLTexture.__index = GLTexture

local glInternalFormatMap = {
	[gfx.TextureFormat.Rgba8UNorm] = gl.RGBA8,
	[gfx.TextureFormat.Depth24Plus] = gl.DEPTH_COMPONENT24,
}

local glFormatMap = {
	[gfx.TextureFormat.Rgba8UNorm] = gl.RGBA,
}

local glTypeMap = {
	[gfx.TextureFormat.Rgba8UNorm] = gl.UNSIGNED_BYTE,
}

---@param device gfx.gl.Device
---@param descriptor gfx.TextureDescriptor
function GLTexture.new(device, descriptor)
	local levels = descriptor.mipLevelCount or 1
	local extents = descriptor.extents
	local format = assert(glInternalFormatMap[descriptor.format], "Unsupported texture format")

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

	return setmetatable({ framebuffer = 0, id = id, descriptor = descriptor }, GLTexture)
end

---@param desc gfx.TextureWriteDescriptor
---@param data ffi.cdata*
function GLTexture:writeData(desc, data)
	local extents = self.descriptor.extents
	local mip = desc.mip or 0
	local layer = desc.layer or 0

	local format = assert(glFormatMap[self.descriptor.format], "Unsupported texture format")
	local type = assert(glTypeMap[self.descriptor.format], "Unsupported texture format")

	data = data + (desc.offset or 0)
	local bytesPerRow = desc.bytesPerRow
	local rowsPerImage = desc.rowsPerImage

	local width = desc.width or extents.width
	local height = desc.height or extents.height
	local depth = desc.depth or extents.depth

	gl.pixelStorei(gl.UNPACK_ALIGNMENT, 1)
	gl.pixelStorei(gl.UNPACK_IMAGE_HEIGHT, rowsPerImage or 0)
	gl.pixelStorei(gl.UNPACK_ROW_LENGTH, bytesPerRow and (bytesPerRow / 4) or 0)

	if extents.dim == "1d" then
		if extents.count then
			gl.textureSubImage2D(self.id, mip, 0, layer, width, 1, format, type, data)
		else
			gl.textureSubImage1D(self.id, mip, 0, width, format, type, data)
		end
	elseif extents.dim == "2d" then
		if extents.count then
			gl.textureSubImage3D(self.id, mip, 0, 0, layer, width, height, 1, format, type, data)
		else
			gl.textureSubImage2D(self.id, mip, 0, 0, width, height, format, type, data)
		end
	elseif extents.dim == "3d" then
		gl.textureSubImage3D(self.id, mip, 0, 0, 0, width, height, depth, format, type, data)
	else
		error("Unsupported texture extents")
	end

	gl.pixelStorei(gl.UNPACK_ALIGNMENT, 4)
	gl.pixelStorei(gl.UNPACK_IMAGE_HEIGHT, 0)
	gl.pixelStorei(gl.UNPACK_ROW_LENGTH, 0)
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
	gl.deleteTextures({ self.id })
end

function GLTexture:__tostring()
	if self.context then
		return "GLBackbuffer(" .. tostring(self.context) .. ")"
	end

	return "GLTexture(" .. tostring(self.id) .. ")"
end

return GLTexture
