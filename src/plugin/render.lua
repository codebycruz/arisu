local util = require("util")
local gl = require("bindings.gl")
local Pipeline = require("gl.pipeline")
local Program = require("gl.program")
local BufferDescriptor = require("gl.buffer_descriptor")
local Buffer = require("gl.buffer")
local VAO = require("gl.vao")
local Uniform = require("gl.uniform")
local UniformBlock = require("gl.uniform_block")
local TextureManager = require("gl.texture_manager")
local FontManager = require("gl.font_manager")

---@class plugin.Render.Context
---@field window Window
---@field renderCtx Context
---@field quadVAO VAO
---@field quadPipeline Pipeline
---@field quadVertex Buffer
---@field quadIndex Buffer
---@field overlayVAO VAO
---@field overlayPipeline Pipeline
---@field overlayVertex Buffer
---@field overlayIndex Buffer
---@field ui? Element
---@field layoutTree? Layout
---@field computedLayout? ComputedLayout
---@field nIndices number

---@class plugin.Render.SharedResources
---@field mainVertexProgram Program
---@field mainFragmentProgram Program
---@field overlayVertexProgram Program
---@field overlayFragmentProgram Program
---@field samplers Uniform
---@field textureDims UniformBlock
---@field textureManager TextureManager
---@field fontManager FontManager

---@class plugin.Render<Message>: { onWindowCreate: Message }
---@field windowPlugin plugin.Window<any>
---@field mainCtx plugin.Render.Context?
---@field contexts table<Window, plugin.Render.Context>
---@field sharedResources plugin.Render.SharedResources?
local RenderPlugin = {}
RenderPlugin.__index = RenderPlugin

---@param windowPlugin plugin.Window
function RenderPlugin.new(windowPlugin)
	return setmetatable({ contexts = {}, windowPlugin = windowPlugin }, RenderPlugin)
end

---@param window Window
---@param vertexData number[]
---@param indexData number[]
function RenderPlugin:setRenderData(window, vertexData, indexData)
	local ctx = self:getContext(window)
	ctx.quadVertex:setData("f32", vertexData)
	ctx.quadIndex:setData("u32", indexData)
	ctx.nIndices = #indexData
end

---@param window Window
function RenderPlugin:register(window)
	local ctx = self.windowPlugin:getContext(window)
	assert(ctx, "Window context not found for render plugin")

	ctx.renderCtx:makeCurrent()
	ctx.renderCtx:setPresentMode("vsync")

	local vertexDescriptor = BufferDescriptor
		.new()
		:withAttribute({ type = "f32", size = 3, offset = 0 }) -- position (vec3)
		:withAttribute({ type = "f32", size = 4, offset = 12 }) -- color (rgba)
		:withAttribute({ type = "f32", size = 2, offset = 28 }) -- uv
		:withAttribute({ type = "f32", size = 1, offset = 36 }) -- texture id

	local quadVertex = Buffer.new()
	local quadIndex = Buffer.new()

	local quadVAO = VAO.new()
	quadVAO:setVertexBuffer(quadVertex, vertexDescriptor)
	quadVAO:setIndexBuffer(quadIndex)

	local overlayVertex = Buffer.new()
	local overlayIndex = Buffer.new()

	local overlayVertexDescriptor = BufferDescriptor
		.new()
		:withAttribute({ type = "f32", size = 3, offset = 0 }) -- position (vec3)
		:withAttribute({ type = "f32", size = 4, offset = 12 }) -- color (rgba)
		:withAttribute({ type = "f32", size = 2, offset = 28 }) -- uv

	local overlayVAO = VAO.new()
	overlayVAO:setVertexBuffer(overlayVertex, overlayVertexDescriptor)
	overlayVAO:setIndexBuffer(overlayIndex)

	-- Initialize shared resources
	if not self.mainCtx then
		local mainVertexShader = io.open("src/shaders/main.vert.glsl", "r"):read("*a")
		local mainFragmentShadder = io.open("src/shaders/main.frag.glsl", "r"):read("*a")

		local mainVertexProgram = Program.new(gl.ShaderType.VERTEX, mainVertexShader)
		local mainFragmentProgram = Program.new(gl.ShaderType.FRAGMENT, mainFragmentShadder)

		local overlayVertexShader = io.open("src/shaders/overlay.vert.glsl", "r"):read("*a")
		local overlayFragmentShader = io.open("src/shaders/overlay.frag.glsl", "r"):read("*a")

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

	---@type plugin.Render.Context
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

---@param ctx plugin.Render.Context
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

---@param event Event
---@param handler EventHandler
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
