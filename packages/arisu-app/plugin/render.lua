local util = require("arisu-util")
local gl = require("arisu-opengl")
local Pipeline = require("arisu.gl.pipeline")
local Program = require("arisu.gl.program")
local VertexLayout = require("arisu-gfx.vertex_layout")
local VAO = require("arisu.gl.vao")
local Uniform = require("arisu.gl.uniform")
local UniformBlock = require("arisu.gl.uniform_block")
local TextureManager = require("arisu.gl.texture_manager")
local FontManager = require("arisu.gl.font_manager")

local Device = require("arisu-gfx.device.gl")

---@class arisu.plugin.Render.Context
---@field window winit.Window
---@field renderCtx gfx.Context
---@field quadVAO VAO
---@field quadPipeline Pipeline
---@field quadVertex gfx.Buffer
---@field quadIndex gfx.Buffer
---@field overlayVAO VAO
---@field overlayPipeline Pipeline
---@field overlayVertex gfx.Buffer
---@field overlayIndex gfx.Buffer
---@field ui? arisu.Element
---@field layoutTree? arisu.Layout
---@field computedLayout? arisu.ComputedLayout
---@field nIndices number

---@class arisu.plugin.Render.SharedResources
---@field mainVertexProgram Program
---@field mainFragmentProgram Program
---@field overlayVertexProgram Program
---@field overlayFragmentProgram Program
---@field samplers Uniform
---@field textureDims UniformBlock
---@field textureManager TextureManager
---@field fontManager FontManager

---@class arisu.plugin.Render<Message>: { onWindowCreate: Message }
---@field windowPlugin arisu.plugin.Window<any>
---@field mainCtx arisu.plugin.Render.Context?
---@field contexts table<winit.Window, arisu.plugin.Render.Context>
---@field sharedResources arisu.plugin.Render.SharedResources?
local RenderPlugin = {}
RenderPlugin.__index = RenderPlugin

---@param windowPlugin arisu.plugin.Window
function RenderPlugin.new(windowPlugin)
	return setmetatable({ contexts = {}, windowPlugin = windowPlugin }, RenderPlugin)
end

---@param window winit.Window
---@param vertexData number[]
---@param indexData number[]
function RenderPlugin:setRenderData(window, vertexData, indexData)
	local ctx = self:getContext(window)
	ctx.quadVertex:setData("f32", vertexData)
	ctx.quadIndex:setData("u32", indexData)
	ctx.nIndices = #indexData
end

---@param window winit.Window
function RenderPlugin:register(window)
	local ctx = self.windowPlugin:getContext(window)
	assert(ctx, "Window context not found for render plugin")

	ctx.renderCtx:makeCurrent()

	-- todo: dont make this here
	local device = Device.new()

	local vertexDescriptor = VertexLayout.new()
		:withAttribute({ type = "f32", size = 3, offset = 0 }) -- position (vec3)
		:withAttribute({ type = "f32", size = 4, offset = 12 }) -- color (rgba)
		:withAttribute({ type = "f32", size = 2, offset = 28 }) -- uv
		:withAttribute({ type = "f32", size = 1, offset = 36 }) -- texture id

	local quadVertex = device:createBuffer({ size = vertexDescriptor:getStride() * 1000, usages = { "VERTEX" } })
	local quadIndex = device:createBuffer({ size = util.sizeof("u16") * 1000, usages = { "INDEX" } })

	local quadVAO = VAO.new()
	quadVAO:setVertexBuffer(quadVertex, vertexDescriptor)
	quadVAO:setIndexBuffer(quadIndex)

	local overlayVertex = device:createBuffer({ size = vertexDescriptor:getStride() * 1000, usages = { "VERTEX" } })
	local overlayIndex = device:createBuffer({ size = util.sizeof("u16") * 1000, usages = { "INDEX" } })

	local overlayVertexDescriptor = VertexLayout.new()
		:withAttribute({ type = "f32", size = 3, offset = 0 }) -- position (vec3)
		:withAttribute({ type = "f32", size = 4, offset = 12 }) -- color (rgba)
		:withAttribute({ type = "f32", size = 2, offset = 28 }) -- uv

	local overlayVAO = VAO.new()
	overlayVAO:setVertexBuffer(overlayVertex, overlayVertexDescriptor)
	overlayVAO:setIndexBuffer(overlayIndex)

	-- Initialize shared resources
	if not self.mainCtx then
		local mainVertexShader = io.open("packages/arisu/shaders/main.vert.glsl", "r"):read("*a")
		local mainFragmentShadder = io.open("packages/arisu/shaders/main.frag.glsl", "r"):read("*a")

		local mainVertexProgram = Program.new(gl.ShaderType.VERTEX, mainVertexShader)
		local mainFragmentProgram = Program.new(gl.ShaderType.FRAGMENT, mainFragmentShadder)

		local overlayVertexShader = io.open("packages/arisu/shaders/overlay.vert.glsl", "r"):read("*a")
		local overlayFragmentShader = io.open("packages/arisu/shaders/overlay.frag.glsl", "r"):read("*a")

		local overlayVertexProgram = Program.new(gl.ShaderType.VERTEX, overlayVertexShader)
		local overlayFragmentProgram = Program.new(gl.ShaderType.FRAGMENT, overlayFragmentShader)

		local samplers = Uniform.new(mainFragmentProgram, "sampler2DArray", 0)
		local textureDims = UniformBlock.new(0)
		local textureManager = TextureManager.new(samplers, textureDims, 0)
		local fontManager = FontManager.new(textureManager)

		self.sharedResources = {
			mainVertexProgram = mainVertexProgram,
			mainFragmentProgram = mainFragmentProgram,
			overlayVertexProgram = overlayVertexProgram,
			overlayFragmentProgram = overlayFragmentProgram,
			samplers = samplers,
			textureDims = textureDims,
			textureManager = textureManager,
			fontManager = fontManager
		}
	end

	local quadPipeline = Pipeline.new()
	quadPipeline:setProgram(gl.ShaderType.VERTEX, self.sharedResources.mainVertexProgram)
	quadPipeline:setProgram(gl.ShaderType.FRAGMENT, self.sharedResources.mainFragmentProgram)

	local overlayPipeline = Pipeline.new()
	overlayPipeline:setProgram(gl.ShaderType.VERTEX, self.sharedResources.overlayVertexProgram)
	overlayPipeline:setProgram(gl.ShaderType.FRAGMENT, self.sharedResources.overlayFragmentProgram)

	---@type arisu.plugin.Render.Context
	local ctx = {
		window = window,
		renderCtx = ctx.renderCtx,
		quadVAO = quadVAO,
		quadPipeline = quadPipeline,
		quadVertex = quadVertex,
		quadIndex = quadIndex,
		overlayVAO = overlayVAO,
		overlayPipeline = overlayPipeline,
		overlayVertex = overlayVertex,
		overlayIndex = overlayIndex,
		nIndices = 0
	}

	self.contexts[window] = ctx
	return ctx
end

--- SAFETY: Returns non-nil as we will assume user registers all windows properly :)
function RenderPlugin:getContext(window)
	return self.contexts[window]
end

---@param ctx arisu.plugin.Render.Context
function RenderPlugin:draw(ctx)
	ctx.renderCtx:makeCurrent()

	gl.enable(gl.BLEND)
	gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)

	gl.enable(gl.DEPTH_TEST)
	gl.depthFunc(gl.LESS_EQUAL)
	gl.clear(bit.bor(gl.COLOR_BUFFER_BIT, gl.DEPTH_BUFFER_BIT))

	gl.viewport(0, 0, ctx.window.width, ctx.window.height)

	ctx.quadPipeline:bind()
	self.sharedResources.textureManager:bind()
	ctx.quadVAO:bind()
	gl.drawElements(gl.TRIANGLES, ctx.nIndices, gl.UNSIGNED_INT, nil)
end

---@param event winit.Event
---@param handler winit.EventManager
function RenderPlugin:event(event, handler)
	if event.name == "resize" then
		local ctx = self:getContext(event.window)
		ctx.renderCtx:makeCurrent()
		gl.viewport(0, 0, ctx.window.width, ctx.window.height)

		if util.isWindows() then
			handler:requestRedraw(event.window)
		end
	end
end

return RenderPlugin
