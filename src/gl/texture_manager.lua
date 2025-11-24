---@class TextureManager
---@field textures Texture[]
---@field sampler2DArray Uniform
local TextureManager = {}
TextureManager.__index = TextureManager

---@param sampler2DArray Uniform
function TextureManager.new(sampler2DArray)
    return setmetatable({ sampler2DArray = sampler2DArray, textures = {} }, TextureManager)
end

---@return Texture
function TextureManager:allocate()

end

return TextureManager
