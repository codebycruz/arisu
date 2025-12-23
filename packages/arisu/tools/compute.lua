local ffi = require("ffi")

local computeSource = io.open("packages/arisu/shaders/brush.compute.glsl", "rb"):read("*a") --[[@as string]]

---@class Compute
---@field pipeline gfx.ComputePipeline
---@field inputs ComputeInputs
---@field inputsBuffer gfx.Buffer
---@field canvas Texture
---@field temp Texture
---@field textureManager TextureManager
---@field bindGroup gfx.BindGroup
---@field device gfx.Device
local Compute = {}
Compute.__index = Compute

ffi.cdef [[
typedef struct {
    int center[2];
    float radius;
    float color[4];
    int tool;
    float selectTopLeft[2];
    float selectBottomRight[2];
    int lineEnd[2];
} ComputeInputs;
]]

local sizeofComputeInputs = assert(ffi.sizeof("ComputeInputs"))

---@class ComputeInputs: ffi.cdata*
---@field center number[2]
---@field radius number
---@field color number[4]
---@field tool number
---@field selectTopLeft number[2]
---@field selectBottomRight number[2]
---@field lineEnd number[2]

---@param textureManager TextureManager
---@param canvas number
---@param device gfx.Device
function Compute.new(textureManager, canvas, device)
	local inputs = ffi.new("ComputeInputs")

	local inputsBuffer = device:createBuffer({
		size = sizeofComputeInputs,
		usages = { "STORAGE", "COPY_DST" }
	})

	local bindGroup = device:createBindGroup({
		{
			binding = 0,
			type = "storageTexture",
			texture = textureManager.texture,
			visibility = { "COMPUTE" },
			layer = canvas,
			access = "WRITE_ONLY"
		},

		{
			binding = 1,
			type = "buffer",
			buffer = inputsBuffer,
			visibility = { "COMPUTE" }
		},
	})

	local computePipeline = device:createComputePipeline({
		module = { type = "glsl", source = computeSource }
	})

	-- TODO: Un-hard code this when canvas is passed as a Texture with width/height
	local tempLayer = textureManager:allocate(800, 600)

	local self = setmetatable({
		device = device,
		textureManager = textureManager,
		canvas = canvas,
		temp = tempLayer,
		pipeline = computePipeline,
		inputs = inputs,
		inputsBuffer = inputsBuffer,
		bindGroup = bindGroup,
	}, Compute)

	self:resetSelection()
	return self
end

local TOOL_BRUSH = 0
local TOOL_ERASER = 1
local TOOL_FILL = 2
local TOOL_LINE = 3
local TOOL_RECTANGLE = 4
local TOOL_CIRCLE = 5

local WORK_GROUP_SIZE = 16

function Compute:updateInputs()
	self.device.queue:writeBuffer(self.inputsBuffer, sizeofComputeInputs, self.inputs)
end

function Compute:resetSelection()
	self:setSelection(-1, -1, -1, -1)
end

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
function Compute:setSelection(x1, y1, x2, y2)
	self.inputs.selectTopLeft[0] = x1
	self.inputs.selectTopLeft[1] = y1
	self.inputs.selectBottomRight[0] = x2
	self.inputs.selectBottomRight[1] = y2
end

---@param x number
---@param y number
---@param radius number
---@param color { r: number, g: number, b: number, a: number }
function Compute:stamp(x, y, radius, color)
	self.inputs.center[0] = x
	self.inputs.center[1] = y
	self.inputs.radius = radius
	self.inputs.color[0] = color.r
	self.inputs.color[1] = color.g
	self.inputs.color[2] = color.b
	self.inputs.color[3] = color.a
	self.inputs.tool = TOOL_BRUSH

	local diameter = radius * 2
	local groupsX = math.ceil(diameter / WORK_GROUP_SIZE)
	local groupsY = math.ceil(diameter / WORK_GROUP_SIZE)

	self:updateInputs()
	local encoder = self.device:createCommandEncoder()
	encoder:beginComputePass({})
	encoder:setComputePipeline(self.pipeline)
	encoder:setBindGroup(0, self.bindGroup)
	encoder:dispatchWorkgroups(groupsX, groupsY, 1)
	self.device.queue:submit(encoder:finish())
end

-- ---@param x number
-- ---@param y number
-- ---@param radius number
-- function Compute:erase(x, y, radius)
-- 	self.center:set({ x, y })
-- 	self.radius:set(radius)
-- 	self.writeLayer:set(self.canvas)
-- 	self.tool:set(TOOL_ERASER)

-- 	gl.bindImageTexture(0, self.textureManager.textureHandle, 0, 1, 0, gl.WRITE_ONLY, gl.RGBA8)

-- 	local diameter = radius * 2
-- 	local groupsX = math.ceil(diameter / WORK_GROUP_SIZE)
-- 	local groupsY = math.ceil(diameter / WORK_GROUP_SIZE)
-- 	self.pipeline:dispatchCompute(groupsX, groupsY, 1)
-- 	gl.memoryBarrier(gl.SHADER_IMAGE_ACCESS_BARRIER_BIT)
-- 	gl.finish()
-- end

-- ---@param x number
-- ---@param y number
-- ---@param color { r: number, g: number, b: number, a: number }
-- function Compute:fill(x, y, color)
-- 	self.pipeline:bind()

-- 	self.textureManager:copy(self.canvas, self.temp)
-- 	gl.memoryBarrier(gl.SHADER_IMAGE_ACCESS_BARRIER_BIT)
-- 	gl.finish()

-- 	self.center:set({ x, y })
-- 	self.color:set({ color.r, color.g, color.b, color.a })
-- 	self.tool:set(TOOL_FILL)

-- 	gl.bindImageTexture(0, self.textureManager.textureHandle, 0, 1, 0, gl.READ_WRITE, gl.RGBA8)

-- 	local canvasInfo = self.textureManager.textures[self.canvas]

-- 	local canvasWidth = canvasInfo.width
-- 	local canvasHeight = canvasInfo.height

-- 	-- This one needs to run iteratively.
-- 	for i = 1, 1 do
-- 		-- Ping pong between the two to avoid constant copies
-- 		-- Need to do this so the parallel reads/writes don't conflict
-- 		if i % 2 == 1 then
-- 			self.readLayer:set(self.temp)
-- 			self.writeLayer:set(self.canvas)
-- 		else
-- 			self.readLayer:set(self.canvas)
-- 			self.writeLayer:set(self.temp)
-- 		end

-- 		self.pipeline:dispatchCompute(canvasWidth / WORK_GROUP_SIZE, canvasHeight / WORK_GROUP_SIZE, 1)

-- 		gl.memoryBarrier(gl.SHADER_IMAGE_ACCESS_BARRIER_BIT)
-- 	end
-- end

-- ---@param x1 number
-- ---@param y1 number
-- ---@param x2 number
-- ---@param y2 number
-- ---@param thickness number
-- ---@param color { r: number, g: number, b: number, a: number }
-- function Compute:drawLine(x1, y1, x2, y2, thickness, color)
-- 	self.pipeline:bind()

-- 	self.center:set({ x1, y1 })
-- 	self.lineEnd:set({ x2, y2 })
-- 	self.radius:set(thickness)
-- 	self.writeLayer:set(self.canvas)
-- 	self.color:set({ color.r, color.g, color.b, color.a })
-- 	self.tool:set(TOOL_LINE)

-- 	gl.bindImageTexture(0, self.textureManager.textureHandle, 0, 1, 0, gl.WRITE_ONLY, gl.RGBA8)

-- 	local canvasInfo = self.textureManager.textures[self.canvas]
-- 	local canvasWidth = canvasInfo.width
-- 	local canvasHeight = canvasInfo.height

-- 	local groupsX = math.ceil(canvasWidth / WORK_GROUP_SIZE)
-- 	local groupsY = math.ceil(canvasHeight / WORK_GROUP_SIZE)
-- 	self.pipeline:dispatchCompute(groupsX, groupsY, 1)
-- 	gl.memoryBarrier(gl.SHADER_IMAGE_ACCESS_BARRIER_BIT)
-- 	gl.finish()
-- end

-- ---@param x1 number
-- ---@param y1 number
-- ---@param x2 number
-- ---@param y2 number
-- ---@param thickness number
-- ---@param color { r: number, g: number, b: number, a: number }
-- function Compute:drawRectangle(x1, y1, x2, y2, thickness, color)
-- 	self.pipeline:bind()

-- 	self.center:set({ x1, y1 })
-- 	self.lineEnd:set({ x2, y2 })
-- 	self.radius:set(thickness)
-- 	self.writeLayer:set(self.canvas)
-- 	self.color:set({ color.r, color.g, color.b, color.a })
-- 	self.tool:set(TOOL_RECTANGLE)

-- 	gl.bindImageTexture(0, self.textureManager.textureHandle, 0, 1, 0, gl.WRITE_ONLY, gl.RGBA8)

-- 	local canvasInfo = self.textureManager.textures[self.canvas]
-- 	local canvasWidth = canvasInfo.width
-- 	local canvasHeight = canvasInfo.height

-- 	local groupsX = math.ceil(canvasWidth / WORK_GROUP_SIZE)
-- 	local groupsY = math.ceil(canvasHeight / WORK_GROUP_SIZE)
-- 	self.pipeline:dispatchCompute(groupsX, groupsY, 1)
-- 	gl.memoryBarrier(gl.SHADER_IMAGE_ACCESS_BARRIER_BIT)
-- 	gl.finish()
-- end

-- ---@param x1 number
-- ---@param y1 number
-- ---@param x2 number
-- ---@param y2 number
-- ---@param thickness number
-- ---@param color { r: number, g: number, b: number, a: number }
-- function Compute:drawEllipse(x1, y1, x2, y2, thickness, color)
-- 	self.pipeline:bind()

-- 	self.center:set({ x1, y1 })
-- 	self.lineEnd:set({ x2, y2 })
-- 	self.radius:set(thickness)
-- 	self.writeLayer:set(self.canvas)
-- 	self.color:set({ color.r, color.g, color.b, color.a })
-- 	self.tool:set(TOOL_CIRCLE)

-- 	gl.bindImageTexture(0, self.textureManager.textureHandle, 0, 1, 0, gl.WRITE_ONLY, gl.RGBA8)

-- 	local canvasInfo = self.textureManager.textures[self.canvas]
-- 	local canvasWidth = canvasInfo.width
-- 	local canvasHeight = canvasInfo.height

-- 	local groupsX = math.ceil(canvasWidth / WORK_GROUP_SIZE)
-- 	local groupsY = math.ceil(canvasHeight / WORK_GROUP_SIZE)
-- 	self.pipeline:dispatchCompute(groupsX, groupsY, 1)
-- 	gl.memoryBarrier(gl.SHADER_IMAGE_ACCESS_BARRIER_BIT)
-- 	gl.finish()
-- end

return Compute
