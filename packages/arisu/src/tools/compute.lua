local ffi = require("ffi")

local isVulkan = os.getenv("VULKAN") and true or false
local shaderType = isVulkan and "spirv" or "glsl"
local shaderExt = isVulkan and "spv" or "glsl"

local computeSource = require("arisu.shaders.brush.compute." .. shaderExt) --[[@as string]]

---@class Compute
---@field pipeline hood.ComputePipeline
---@field inputs ComputeInputs
---@field inputsBuffer hood.Buffer
---@field canvas Texture
---@field temp Texture
---@field textureManager TextureManager
---@field bindGroup hood.BindGroup
---@field device hood.Device
---@field fillQueueX ffi.cdata*
---@field fillQueueY ffi.cdata*
local Compute = {}
Compute.__index = Compute

ffi.cdef([[
typedef struct {
    float color[4];
    float selectTopLeft[2];
    float selectBottomRight[2];
    int32_t center[2];
    int32_t lineEnd[2];
    float radius;
    int32_t tool;
} ComputeInputs;
]])

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
---@param device hood.Device
function Compute.new(textureManager, canvas, device)
	local inputs = ffi.new("ComputeInputs")

	local inputsBuffer = device:createBuffer({
		size = sizeofComputeInputs,
		usages = { "STORAGE", "COPY_DST" },
	})

	local bindGroupLayout = device:createBindGroupLayout({
		{
			binding = 0,
			type = "storageTexture",
			visibility = { "COMPUTE" },
		},
		{
			binding = 1,
			type = "buffer",
			visibility = { "COMPUTE" },
		},
	})

	local bindGroup = device:createBindGroup({
		layout = bindGroupLayout,
		entries = {
			{
				binding = 0,
				type = "storageTexture",
				texture = textureManager.texture:createView({ dimension = "2d", baseArrayLayer = canvas, layerCount = 1 }),
				visibility = { "COMPUTE" },
				layer = canvas,
				access = "WRITE_ONLY",
			},

			{
				binding = 1,
				type = "buffer",
				buffer = inputsBuffer,
				visibility = { "COMPUTE" },
			},
		},
	})

	local computePipeline = device:createComputePipeline({
		layout = bindGroupLayout,
		module = { type = shaderType, source = computeSource },
	})

	-- TODO: Un-hard code this when canvas is passed as a Texture with width/height
	local tempLayer = textureManager:allocate(800, 600)

	local maxPixels = 1024 * 1024
	local self = setmetatable({
		device = device,
		textureManager = textureManager,
		canvas = canvas,
		temp = tempLayer,
		pipeline = computePipeline,
		inputs = inputs,
		inputsBuffer = inputsBuffer,
		bindGroup = bindGroup,
		fillQueueX = ffi.new("int32_t[?]", maxPixels),
		fillQueueY = ffi.new("int32_t[?]", maxPixels),
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
	encoder:setComputePipeline(self.pipeline)
	encoder:setBindGroup(0, self.bindGroup)
	encoder:beginComputePass({})
	encoder:dispatchWorkgroups(groupsX, groupsY, 1)
	encoder:endComputePass()
	self.device.queue:submit(encoder:finish())
end

---@param x number
---@param y number
---@param radius number
function Compute:erase(x, y, radius)
	self.inputs.center[0] = x
	self.inputs.center[1] = y
	self.inputs.radius = radius
	self.inputs.tool = TOOL_ERASER

	local diameter = radius * 2
	local groupsX = math.ceil(diameter / WORK_GROUP_SIZE)
	local groupsY = math.ceil(diameter / WORK_GROUP_SIZE)

	self:updateInputs()
	local encoder = self.device:createCommandEncoder()
	encoder:setComputePipeline(self.pipeline)
	encoder:setBindGroup(0, self.bindGroup)
	encoder:beginComputePass({})
	encoder:dispatchWorkgroups(groupsX, groupsY, 1)
	encoder:endComputePass()
	self.device.queue:submit(encoder:finish())
end

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param thickness number
---@param color { r: number, g: number, b: number, a: number }
function Compute:drawLine(x1, y1, x2, y2, thickness, color)
	self.inputs.center[0] = x1
	self.inputs.center[1] = y1
	self.inputs.lineEnd[0] = x2
	self.inputs.lineEnd[1] = y2
	self.inputs.radius = thickness
	self.inputs.color[0] = color.r
	self.inputs.color[1] = color.g
	self.inputs.color[2] = color.b
	self.inputs.color[3] = color.a
	self.inputs.tool = TOOL_LINE

	local groupsX = math.ceil(800 / WORK_GROUP_SIZE)
	local groupsY = math.ceil(600 / WORK_GROUP_SIZE)

	self:updateInputs()
	local encoder = self.device:createCommandEncoder()
	encoder:setComputePipeline(self.pipeline)
	encoder:setBindGroup(0, self.bindGroup)
	encoder:beginComputePass({})
	encoder:dispatchWorkgroups(groupsX, groupsY, 1)
	encoder:endComputePass()
	self.device.queue:submit(encoder:finish())
end

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param thickness number
---@param color { r: number, g: number, b: number, a: number }
function Compute:drawRectangle(x1, y1, x2, y2, thickness, color)
	self.inputs.center[0] = x1
	self.inputs.center[1] = y1
	self.inputs.lineEnd[0] = x2
	self.inputs.lineEnd[1] = y2
	self.inputs.radius = thickness
	self.inputs.color[0] = color.r
	self.inputs.color[1] = color.g
	self.inputs.color[2] = color.b
	self.inputs.color[3] = color.a
	self.inputs.tool = TOOL_RECTANGLE

	local groupsX = math.ceil(800 / WORK_GROUP_SIZE)
	local groupsY = math.ceil(600 / WORK_GROUP_SIZE)

	self:updateInputs()
	local encoder = self.device:createCommandEncoder()
	encoder:setComputePipeline(self.pipeline)
	encoder:setBindGroup(0, self.bindGroup)
	encoder:beginComputePass({})
	encoder:dispatchWorkgroups(groupsX, groupsY, 1)
	encoder:endComputePass()
	self.device.queue:submit(encoder:finish())
end

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param thickness number
---@param color { r: number, g: number, b: number, a: number }
function Compute:drawEllipse(x1, y1, x2, y2, thickness, color)
	self.inputs.center[0] = x1
	self.inputs.center[1] = y1
	self.inputs.lineEnd[0] = x2
	self.inputs.lineEnd[1] = y2
	self.inputs.radius = thickness
	self.inputs.color[0] = color.r
	self.inputs.color[1] = color.g
	self.inputs.color[2] = color.b
	self.inputs.color[3] = color.a
	self.inputs.tool = TOOL_CIRCLE

	local groupsX = math.ceil(800 / WORK_GROUP_SIZE)
	local groupsY = math.ceil(600 / WORK_GROUP_SIZE)

	self:updateInputs()
	local encoder = self.device:createCommandEncoder()
	encoder:setComputePipeline(self.pipeline)
	encoder:setBindGroup(0, self.bindGroup)
	encoder:beginComputePass({})
	encoder:dispatchWorkgroups(groupsX, groupsY, 1)
	encoder:endComputePass()
	self.device.queue:submit(encoder:finish())
end

---@param x number
---@param y number
---@param color { r: number, g: number, b: number, a: number }
function Compute:fill(x, y, color)
	local cw, ch = self.textureManager:getSize(self.canvas)
	local ix, iy = math.floor(x), math.floor(y)
	if ix < 0 or ix >= cw or iy < 0 or iy >= ch then return end

	local bufferSize = cw * ch * 4
	local readBuffer = self.device:createBuffer({ size = bufferSize, usages = { "COPY_DST", "MAP_READ" } })

	local encoder = self.device:createCommandEncoder()
	encoder:copyTextureToBuffer(
		{ texture = self.textureManager.texture, origin = { x = 0, y = 0, z = self.canvas } },
		{ buffer = readBuffer, bytesPerRow = cw * 4 },
		{ width = cw, height = ch, depthOrArrayLayers = 1 }
	)
	self.device.queue:submit(encoder:finish())
	self.device.queue:waitIdle()

	readBuffer:mapAsync()
	local pixelsU32 = ffi.cast("uint32_t*", readBuffer:getMappedRange())

	local fr = math.floor(color.r * 255 + 0.5)
	local fg = math.floor(color.g * 255 + 0.5)
	local fb = math.floor(color.b * 255 + 0.5)
	local fa = math.floor(color.a * 255 + 0.5)
	local fillPacked = ffi.cast("uint32_t", bit.bor(fr, bit.lshift(fg, 8), bit.lshift(fb, 16), bit.lshift(fa, 24)))

	local seedI = iy * cw + ix
	local targetPacked = pixelsU32[seedI]

	if targetPacked == fillPacked then
		readBuffer:unmap()
		readBuffer:destroy()
		return
	end

	local qx, qy = self.fillQueueX, self.fillQueueY
	local head, tail = 0, 0
	qx[tail] = ix; qy[tail] = iy; tail = tail + 1

	local ch1 = ch - 1
	while head < tail do
		local x = qx[head]; local y = qy[head]; head = head + 1

		-- scan left
		local x1 = x
		while x1 > 0 and pixelsU32[y * cw + x1 - 1] == targetPacked do x1 = x1 - 1 end

		-- scan right, fill span, push one point per contiguous run above/below
		local spanAbove, spanBelow = false, false
		local xi = x1
		while xi < cw and pixelsU32[y * cw + xi] == targetPacked do
			pixelsU32[y * cw + xi] = fillPacked

			if y > 0 then
				local ai = (y - 1) * cw + xi
				if pixelsU32[ai] == targetPacked then
					if not spanAbove then qx[tail] = xi; qy[tail] = y-1; tail = tail + 1; spanAbove = true end
				else spanAbove = false end
			end

			if y < ch1 then
				local bi = (y + 1) * cw + xi
				if pixelsU32[bi] == targetPacked then
					if not spanBelow then qx[tail] = xi; qy[tail] = y+1; tail = tail + 1; spanBelow = true end
				else spanBelow = false end
			end

			xi = xi + 1
		end
	end

	readBuffer:unmap()

	self.device.queue:writeTexture(
		self.textureManager.texture,
		{ layer = self.canvas, width = cw, height = ch },
		ffi.cast("uint8_t*", pixelsU32)
	)

	readBuffer:destroy()
end

return Compute
