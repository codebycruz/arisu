local gl = require "src.bindings.gl"

local Uniform = require "src.gl.uniform"
local Program = require "src.gl.program"
local Pipeline = require "src.gl.pipeline"

local computeSource = io.open("src/shaders/brush.compute.glsl"):read("*a")

---@class Compute
---@field pipeline Pipeline
---@field layer Uniform
---@field center Uniform
---@field radius Uniform
---@field color Uniform
---@field canvas Texture
---@field textureManager TextureManager
local Compute = {}
Compute.__index = Compute

---@param canvas Texture
function Compute.new(textureManager, canvas)
    local computeProgram = Program.new(gl.ShaderType.COMPUTE, computeSource)

    local pipeline = Pipeline.new()
    pipeline:setProgram(gl.ShaderType.COMPUTE, computeProgram)

    local center = Uniform.new("vec2", 0)
    local radius = Uniform.new("float", 1)
    local layer = Uniform.new("float", 2)
    local color = Uniform.new("vec4", 3)

    print(canvas)

    return setmetatable({ textureManager = textureManager, canvas = canvas, pipeline = pipeline, center = center, radius = radius, layer = layer, color = color }, Compute)
end

local WORK_GROUP_SIZE = 16

---@param x number
---@param y number
---@param radius number
function Compute:stamp(x, y, radius)
    self.pipeline:bind()

    self.center:set({ x, y })
    self.radius:set(radius)
    self.layer:set(self.canvas)
    self.color:set({ 1, 0, 0, 1 })

    -- Bind the canvas as an image for writing
    gl.bindImageTexture(0, self.textureManager.textureHandle, 0, 1, 0, gl.READ_WRITE, gl.RGBA8)

    local diameter = radius * 2
    local groupsX = math.ceil(diameter / WORK_GROUP_SIZE)
    local groupsY = math.ceil(diameter / WORK_GROUP_SIZE)
    self.pipeline:dispatchCompute(groupsX, groupsY, 1)
end

return Compute
