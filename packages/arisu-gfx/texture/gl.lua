---@class gfx.gl.Texture
---@field framebuffer number
---@field id number? # if nil, it is the backbuffer (default framebuffer)
local GLTexture = {}
GLTexture.__index = GLTexture

---@param framebuffer number
---@param id number?
function GLTexture.new(framebuffer, id)
	return setmetatable({ framebuffer = framebuffer, id = id }, GLTexture)
end

GLTexture.VIEWPORT_TEXTURE = GLTexture.new(0, nil)

return GLTexture
