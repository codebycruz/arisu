local gl = require("src.bindings.gl")

local Uniform = require("src.gl.uniform")
local Program = require("src.gl.program")
local Pipeline = require("src.gl.pipeline")

local computeSource = io.open("src/shaders/brush.compute.glsl"):read("*a")

---@class Compute
---@field pipeline Pipeline
---@field writeLayer Uniform
---@field readLayer Uniform
---@field center Uniform
---@field radius Uniform
---@field color Uniform
---@field tool Uniform
---@field selectTopLeft Uniform
---@field selectBottomRight Uniform
---@field canvas Texture
---@field temp Texture
---@field textureManager TextureManager
local Compute = {}
Compute.__index = Compute

---@param canvas Texture
function Compute.new(textureManager, canvas)
	local computeProgram = Program.new(gl.ShaderType.COMPUTE, computeSource)

	local pipeline = Pipeline.new()
	pipeline:setProgram(gl.ShaderType.COMPUTE, computeProgram)

	local center = Uniform.new(computeProgram, "ivec2", 0)
	local radius = Uniform.new(computeProgram, "float", 1)
	local writeLayer = Uniform.new(computeProgram, "int", 2)
	local color = Uniform.new(computeProgram, "vec4", 3)
	local tool = Uniform.new(computeProgram, "int", 4)
	local readLayer = Uniform.new(computeProgram, "int", 5)
	local selectTopLeft = Uniform.new(computeProgram, "vec2", 6)
	local selectBottomRight = Uniform.new(computeProgram, "vec2", 7)

	-- TODO: Un-hard code this when canvas is passed as a Texture with width/height
	local tempLayer = textureManager:allocate(800, 600)

	local self = setmetatable({
		textureManager = textureManager,
		canvas = canvas,
		temp = tempLayer,
		pipeline = pipeline,
		center = center,
		radius = radius,
		readLayer = readLayer,
		writeLayer = writeLayer,
		color = color,
		tool = tool,
		selectTopLeft = selectTopLeft,
		selectBottomRight = selectBottomRight,
	}, Compute)

	self:resetSelection()
	return self
end

local TOOL_BRUSH = 0
local TOOL_ERASER = 1
local TOOL_FILL = 2

local WORK_GROUP_SIZE = 16

function Compute:resetSelection()
	self.selectTopLeft:set({ -1, -1 })
	self.selectBottomRight:set({ -1, -1 })
end

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
function Compute:setSelection(x1, y1, x2, y2)
	self.selectTopLeft:set({ x1, y1 })
	self.selectBottomRight:set({ x2, y2 })
end

---@param x number
---@param y number
---@param radius number
---@param color { r: number, g: number, b: number, a: number }
function Compute:stamp(x, y, radius, color)
	self.pipeline:bind()

	self.center:set({ x, y })
	self.radius:set(radius)
	self.writeLayer:set(self.canvas)
	self.color:set({ color.r, color.g, color.b, color.a })
	self.tool:set(TOOL_BRUSH)

	-- Bind the canvas as an image for writing
	gl.bindImageTexture(0, self.textureManager.textureHandle, 0, 1, 0, gl.WRITE_ONLY, gl.RGBA8)

	local diameter = radius * 2
	local groupsX = math.ceil(diameter / WORK_GROUP_SIZE)
	local groupsY = math.ceil(diameter / WORK_GROUP_SIZE)
	self.pipeline:dispatchCompute(groupsX, groupsY, 1)
	gl.memoryBarrier(gl.SHADER_IMAGE_ACCESS_BARRIER_BIT)
	gl.finish()
end

---@param x number
---@param y number
---@param radius number
function Compute:erase(x, y, radius)
	self.pipeline:bind()

	self.center:set({ x, y })
	self.radius:set(radius)
	self.writeLayer:set(self.canvas)
	self.tool:set(TOOL_ERASER)

	gl.bindImageTexture(0, self.textureManager.textureHandle, 0, 1, 0, gl.WRITE_ONLY, gl.RGBA8)

	local diameter = radius * 2
	local groupsX = math.ceil(diameter / WORK_GROUP_SIZE)
	local groupsY = math.ceil(diameter / WORK_GROUP_SIZE)
	self.pipeline:dispatchCompute(groupsX, groupsY, 1)
	gl.memoryBarrier(gl.SHADER_IMAGE_ACCESS_BARRIER_BIT)
	gl.finish()
end

---@param x number
---@param y number
---@param color { r: number, g: number, b: number, a: number }
function Compute:fill(x, y, color)
	self.pipeline:bind()

	self.textureManager:copy(self.canvas, self.temp)
	gl.memoryBarrier(gl.SHADER_IMAGE_ACCESS_BARRIER_BIT)
	gl.finish()

	self.center:set({ x, y })
	self.color:set({ color.r, color.g, color.b, color.a })
	self.tool:set(TOOL_FILL)

	gl.bindImageTexture(0, self.textureManager.textureHandle, 0, 1, 0, gl.READ_WRITE, gl.RGBA8)

	local canvasInfo = self.textureManager.textures[self.canvas]

	local canvasWidth = canvasInfo.width
	local canvasHeight = canvasInfo.height

	-- This one needs to run iteratively.
	for i = 1, 1 do
		-- Ping pong between the two to avoid constant copies
		-- Need to do this so the parallel reads/writes don't conflict
		if i % 2 == 1 then
			self.readLayer:set(self.temp)
			self.writeLayer:set(self.canvas)
		else
			self.readLayer:set(self.canvas)
			self.writeLayer:set(self.temp)
		end

		self.pipeline:dispatchCompute(canvasWidth / WORK_GROUP_SIZE, canvasHeight / WORK_GROUP_SIZE, 1)

		gl.memoryBarrier(gl.SHADER_IMAGE_ACCESS_BARRIER_BIT)
	end
end

return Compute
