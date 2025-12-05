local window = require("window")
local util = require("util")

local Context = require("context")

local Layout = require("ui.layout")
local Element = require("ui.element")

--[[
	The Arisu app architecture is simple.

	// This is the base type. You decide what it is.
	// Depending on how simple your usecases are, it could just be a string or number.
	type Message<T> = T
	type App<Message> = ...

	An event loop is created which triggers the lowest level "App:event"

	`function App:event(event: Event, handler: EventHandler) -> Message?`
		- If returns, triggers `App:update`
		- Triggered by `Events` which are low level X11/Win32 windowing events.
		- Usually a `Plugin` will register this and you can just worry about defining App:update and App:view

	`function App:update(message: Message) -> Task?`
		- Triggered by `App:event`
		- A task can be returned which will do internal work like creating windows asynchronously

	`function App:view() -> Element`
		- This is used by the base `QuadPlugin` (bad temp name for now)
		- You provide `Message` values as "callbacks" for element click/hover/whatever events.
		- Basically it doesn't really mean anything
		  beyond providing data to the App:event so it can decide things like
		  when to fire an update if your mouse clicked at a certain position.
]]
local Arisu = {}

---@generic T
---@generic Message
---@param cons fun(window: Window, textureManager: TextureManager, fontManager: FontManager): { view: fun(self: T, window: Window): Element, update: fun(self: T, message: Message, window: Window): Task?, event: fun(self: T, event: Event): Message }
function Arisu.runApp(cons)
	---@type table<Window, WindowContext>
	local windowContexts = {}

	---@type WindowContext
	local mainCtx

	local mainVertexProgram ---@type Program
	local mainFragmentProgram ---@type Program
	local overlayVertexProgram ---@type Program
	local overlayFragmentProgram ---@type Program
	local samplers ---@type Uniform
	local textureDims ---@type UniformBlock
	local textureManager ---@type TextureManager
	local fontManager ---@type FontManager

	local gl
	local Pipeline
	local Program
	local BufferDescriptor
	local Buffer
	local VAO
	local Uniform
	local UniformBlock
	local TextureManager
	local FontManager

	---@param window Window
	---@return WindowContext
	local function initWindow(window)
		local renderCtx = Context.new(window, mainCtx and mainCtx.renderCtx)
		if not renderCtx then
			error("Failed to create rendering context for window " .. tostring(window.id))
		end

		renderCtx:makeCurrent()
		renderCtx:setPresentMode("vsync")

		if not mainCtx then
			gl = require("bindings.gl")
			Pipeline = require("gl.pipeline")
			Program = require("gl.program")
			BufferDescriptor = require("gl.buffer_descriptor")
			Buffer = require("gl.buffer")
			VAO = require("gl.vao")
			Uniform = require("gl.uniform")
			UniformBlock = require("gl.uniform_block")
			TextureManager = require("gl.texture_manager")
			FontManager = require("gl.font_manager")
		end

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

		if not mainCtx then
			local mainVertexShader = io.open("src/shaders/main.vert.glsl", "r"):read("*a")
			local mainFragmentShadder = io.open("src/shaders/main.frag.glsl", "r"):read("*a")

			mainVertexProgram = Program.new(gl.ShaderType.VERTEX, mainVertexShader)
			mainFragmentProgram = Program.new(gl.ShaderType.FRAGMENT, mainFragmentShadder)

			local overlayVertexShader = io.open("src/shaders/overlay.vert.glsl", "r"):read("*a")
			local overlayFragmentShader = io.open("src/shaders/overlay.frag.glsl", "r"):read("*a")

			overlayVertexProgram = Program.new(gl.ShaderType.VERTEX, overlayVertexShader)
			overlayFragmentProgram = Program.new(gl.ShaderType.FRAGMENT, overlayFragmentShader)

			samplers = Uniform.new(mainFragmentProgram, "sampler2DArray", 0)
			textureDims = UniformBlock.new(0)
			textureManager = TextureManager.new(samplers, textureDims, 0)
			fontManager = FontManager.new(textureManager)
		end

		local quadPipeline = Pipeline.new()
		quadPipeline:setProgram(gl.ShaderType.VERTEX, mainVertexProgram)
		quadPipeline:setProgram(gl.ShaderType.FRAGMENT, mainFragmentProgram)

		local overlayPipeline = Pipeline.new()
		overlayPipeline:setProgram(gl.ShaderType.VERTEX, overlayFragmentProgram)
		overlayPipeline:setProgram(gl.ShaderType.FRAGMENT, overlayVertexProgram)

		---@type WindowContext
		local ctx = {
			window = window,

			quadPipeline = quadPipeline,
			quadVAO = quadVAO,
			quadVertex = quadVertex,
			quadIndex = quadIndex,

			overlayPipeline = overlayPipeline,
			overlayVAO = overlayVAO,
			overlayVertex = overlayVertex,
			overlayIndex = overlayIndex,

			renderCtx = renderCtx,
		}

		windowContexts[window] = ctx
		return ctx
	end

	local eventLoop = window.EventLoop.new()
	local mainWindow = window.WindowBuilder.new():withTitle("Arisu Application"):withSize(1280, 720):build(eventLoop)

	mainCtx = initWindow(mainWindow)
	mainCtx.renderCtx:makeCurrent()

	-- TODOHUGEREFACTOR: With the huge refactor, App.new shouldn't run with a gl context.
	-- Ideally they'll have a hook with a plugin when a window is made.
	-- Then they can make assets in there.

	-- Run the app constructor in the rendering context so they can initialize any
	-- GL resources they need.
	local app = cons(mainWindow, textureManager, fontManager)

	local runUpdate

	---@param event Event
	---@param handler EventHandler
	local function runEvent(event, handler)
		local message = app:event(event)
		if message then
			runUpdate(message, handler)
		end
	end

	---@param task Task?
	---@param handler EventHandler
	local function runTask(task, handler)
		if not task then
			return
		end

		if task.variant == "refreshView" then
			refreshView(windowContexts[task.window], handler)
		elseif task.variant == "redraw" then
			handler:requestRedraw(task.window)
		elseif task.variant == "windowOpen" then
			task.builder:build(eventLoop)
		elseif task.variant == "setTitle" then
			mainWindow:setTitle(task.to)
		elseif task.variant == "closeWindow" then
			windowContexts[task.window] = nil
			eventLoop:close(task.window)
		elseif task.variant == "chain" then
			for _, subtask in ipairs(task.tasks) do
				runTask(subtask, handler)
			end
		end
	end

	---@param handler EventHandler
	---@param window Window
	function runUpdate(message, window, handler)
		runTask(app:update(message, window), handler)
	end

	eventLoop:run(function(event, handler)
		handler:setMode("wait")
		runEvent(event, handler)
	end)
end

return Arisu
