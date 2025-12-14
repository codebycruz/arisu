local gl = require("arisu-opengl")
local Uniform = require("arisu.gl.uniform")

---@class plugin.Overlay.Context
---@field window winit.Window
---@field vertices number[]
---@field indices number[]
---@field nIndices number
---@field timeUniform Uniform
---@field patternTypeUniform Uniform
---@field overlayTexture Texture
---@field framebuffer number

---@alias OverlayPattern "solid" | "dashed" | "marching_ants"

---@class plugin.Overlay
---@field renderPlugin arisu.plugin.Render
---@field contexts table<winit.Window, plugin.Overlay.Context>
local OverlayPlugin = {}
OverlayPlugin.__index = OverlayPlugin

local PATTERN_SOLID = 0
local PATTERN_DASHED = 1
local PATTERN_MARCHING_ANTS = 2

---@param renderPlugin arisu.plugin.Render
function OverlayPlugin.new(renderPlugin)
	return setmetatable({ renderPlugin = renderPlugin, contexts = {} }, OverlayPlugin)
end

---@param window winit.Window
function OverlayPlugin:register(window)
	local renderCtx = self.renderPlugin:getContext(window)
	assert(renderCtx, "Render context not found for overlay plugin")

	renderCtx.surface.context:makeCurrent()

	local textureManager = self.renderPlugin.sharedResources.textureManager
	local overlayTexture = textureManager:allocate(800, 600)

	local framebuffer = gl.createFramebuffer()

	gl.namedFramebufferTextureLayer(framebuffer, gl.COLOR_ATTACHMENT0, textureManager.textureHandle, 0, overlayTexture)

	local status = gl.checkNamedFramebufferStatus(framebuffer, gl.FRAMEBUFFER)
	if status ~= gl.FRAMEBUFFER_COMPLETE then
		error("Framebuffer is not complete: " .. tostring(status))
	end

	local timeUniform = Uniform.new(self.renderPlugin.sharedResources.overlayFragmentProgram, "float", 0)
	local patternTypeUniform = Uniform.new(self.renderPlugin.sharedResources.overlayFragmentProgram, "int", 1)

	---@type plugin.Overlay.Context
	local ctx = {
		window = window,
		vertices = {},
		indices = {},
		nIndices = 0,
		timeUniform = timeUniform,
		patternTypeUniform = patternTypeUniform,
		overlayTexture = overlayTexture,
		framebuffer = framebuffer
	}

	self.contexts[window] = ctx
	return ctx
end

---@param window winit.Window
---@return plugin.Overlay.Context?
function OverlayPlugin:getContext(window)
	return self.contexts[window]
end

local function toNDC(pos, screenSize)
	return (pos / (screenSize * 0.5)) - 1.0
end

local function convertZ(z)
	return 1 - math.min(z or 0, 100000) / 1000000
end

---@param window winit.Window
function OverlayPlugin:clear(window)
	local ctx = self:getContext(window)
	if not ctx then return end

	ctx.vertices = {}
	ctx.indices = {}
	ctx.nIndices = 0
end

---@param window winit.Window
---@param x number
---@param y number
---@param width number
---@param height number
---@param color {r: number, g: number, b: number, a: number}
---@param thickness number?
---@param z number?
function OverlayPlugin:addBox(window, x, y, width, height, color, thickness, z)
	local ctx = self:getContext(window)
	if not ctx then return end

	thickness = thickness or 1
	z = z or 99999

	self:addLine(window, x, y, x + width, y, color, thickness, z)
	self:addLine(window, x + width, y, x + width, y + height, color, thickness, z)
	self:addLine(window, x + width, y + height, x, y + height, color, thickness, z)
	self:addLine(window, x, y + height, x, y, color, thickness, z)
end

---@param window winit.Window
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param color {r: number, g: number, b: number, a: number}
---@param thickness number?
---@param z number?
function OverlayPlugin:addEllipse(window, x1, y1, x2, y2, color, thickness, z)
	local ctx = self:getContext(window)
	if not ctx then return end

	thickness = thickness or 1
	z = z or 99999

	local centerX = (x1 + x2) / 2
	local centerY = (y1 + y2) / 2
	local radiusX = math.abs(x2 - x1) / 2
	local radiusY = math.abs(y2 - y1) / 2

	local avgRadius = (radiusX + radiusY) / 2
	local segments = math.max(16, math.floor(avgRadius / 2))

	for i = 0, segments - 1 do
		local angle1 = (i / segments) * 2 * math.pi
		local angle2 = ((i + 1) / segments) * 2 * math.pi

		local px1 = centerX + math.cos(angle1) * radiusX
		local py1 = centerY + math.sin(angle1) * radiusY
		local px2 = centerX + math.cos(angle2) * radiusX
		local py2 = centerY + math.sin(angle2) * radiusY

		self:addLine(window, px1, py1, px2, py2, color, thickness, z)
	end
end

---@param window winit.Window
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param color {r: number, g: number, b: number, a: number}
---@param thickness number?
---@param z number?
function OverlayPlugin:addLine(window, x1, y1, x2, y2, color, thickness, z)
	local ctx = self:getContext(window)
	if not ctx then return end

	thickness = thickness or 1
	z = z or 99999

	local w = 800
	local h = 600

	local dx = x2 - x1
	local dy = y2 - y1
	local len = math.sqrt(dx * dx + dy * dy)

	if len < 0.001 then return end

	local nx = -dy / len
	local ny = dx / len

	local half = thickness * 0.5

	local x1a = x1 + nx * half
	local y1a = y1 + ny * half
	local x1b = x1 - nx * half
	local y1b = y1 - ny * half

	local x2a = x2 + nx * half
	local y2a = y2 + ny * half
	local x2b = x2 - nx * half
	local y2b = y2 - ny * half

	local baseIdx = #ctx.vertices / 9

	local left1 = toNDC(x1a, w)
	local top1 = toNDC(y1a, h)
	local left2 = toNDC(x1b, w)
	local top2 = toNDC(y1b, h)
	local right1 = toNDC(x2a, w)
	local bottom1 = toNDC(y2a, h)
	local right2 = toNDC(x2b, w)
	local bottom2 = toNDC(y2b, h)

	local zNDC = convertZ(z)

	for _, v in ipairs({
		left1, top1, zNDC, color.r, color.g, color.b, color.a, 0, 0,
		right1, bottom1, zNDC, color.r, color.g, color.b, color.a, len / 10, 0,
		right2, bottom2, zNDC, color.r, color.g, color.b, color.a, len / 10, 1,
		left2, top2, zNDC, color.r, color.g, color.b, color.a, 0, 1,
	}) do
		table.insert(ctx.vertices, v)
	end

	for _, idx in ipairs({
		baseIdx, baseIdx + 1, baseIdx + 2,
		baseIdx, baseIdx + 2, baseIdx + 3,
	}) do
		table.insert(ctx.indices, idx)
	end

	ctx.nIndices = #ctx.indices
end

---@param window winit.Window
---@param pattern OverlayPattern?
---@param time number?
function OverlayPlugin:draw(window, pattern, time)
	local ctx = self:getContext(window)
	if not ctx then return end

	local renderCtx = self.renderPlugin:getContext(window)
	if not renderCtx then return end

	pattern = pattern or "solid"
	time = time or 0

	local patternType = PATTERN_SOLID
	if pattern == "dashed" then
		patternType = PATTERN_DASHED
	elseif pattern == "marching_ants" then
		patternType = PATTERN_MARCHING_ANTS
	end

	renderCtx.surface.context:makeCurrent()

	gl.bindFramebuffer(gl.FRAMEBUFFER, ctx.framebuffer)
	gl.viewport(0, 0, 800, 600)
	gl.clearColor(0, 0, 0, 0)
	gl.clear(gl.COLOR_BUFFER_BIT)

	if ctx.nIndices > 0 then
		gl.enable(gl.BLEND)
		gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)

		renderCtx.overlayVertex:setData("f32", ctx.vertices)
		renderCtx.overlayIndex:setData("u32", ctx.indices)

		renderCtx.overlayPipeline:bind()

		ctx.timeUniform:set(time)
		ctx.patternTypeUniform:set(patternType)

		renderCtx.overlayVAO:bind()
		gl.drawElements(gl.TRIANGLES, ctx.nIndices, gl.UNSIGNED_INT, nil)
	end

	gl.bindFramebuffer(gl.FRAMEBUFFER, 0)
end

---@param window winit.Window
---@return Texture?
function OverlayPlugin:getTexture(window)
	local ctx = self:getContext(window)
	return ctx and ctx.overlayTexture
end

return OverlayPlugin
