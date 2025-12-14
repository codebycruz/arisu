---@class gfx.gl.Texture
---@field framebuffer number
---@field id number? # if nil, it is the backbuffer (default framebuffer)
---@field context gfx.gl.Context? # only present if id is nil
local GLTexture = {}
GLTexture.__index = GLTexture

---@param framebuffer number
---@param id number?
---@param context gfx.gl.Context?
function GLTexture.new(framebuffer, id, context)
	return setmetatable({ framebuffer = framebuffer, id = id, context = context }, GLTexture)
end

---@param context gfx.gl.Context
function GLTexture.forContextViewport(context)
	return GLTexture.new(0, nil, context)
end

-- GLTexture.VIEWPORT_TEXTURE = GLTexture.new(0, nil)

return GLTexture
