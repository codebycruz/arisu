local gl = require("arisu-opengl")

local gfx = require("arisu-gfx")
local GLVAO = require("arisu-gfx.gl_vao")

---@class gfx.gl.CommandBuffer
---@field private commands gfx.gl.Command[]
---@field private svbCache table # tbd
local GLCommandBuffer = {}
GLCommandBuffer.__index = GLCommandBuffer

---@param commands gfx.gl.Command[]
function GLCommandBuffer.new(commands)
	return setmetatable({ svbCache = {}, commands = commands }, GLCommandBuffer)
end

---@param op gfx.LoadOp
local function executeOp(op)
	if op.type == "clear" then
		gl.clearColor(op.color.r, op.color.g, op.color.b, op.color.a)
		gl.clear(gl.COLOR_BUFFER_BIT)
	elseif op.type == "load" then
		-- Do nothing, just keep the existing content
	end
end

---@param op gfx.DepthOp
local function executeDepthOp(op)
	if op.type == "clear" then
		gl.depthMask(true)
		gl.clearDepthf(op.depth)
		gl.clear(gl.DEPTH_BUFFER_BIT)
	end
end

---@type table<gfx.gl.Context, gfx.gl.VAO>
local vaos = setmetatable({}, {
	__mode = "k",
})

--- TODO: Probably need to support multiple contexts too?
---@type table<gfx.gl.Pipeline, gfx.gl.RawPipeline>
local pipelines = setmetatable({}, {
	__mode = "k",
})

---@type table<gfx.IndexFormat, number>
local indexFormatToGL = {
	[gfx.IndexType.u16] = gl.UNSIGNED_SHORT,
	[gfx.IndexType.u32] = gl.UNSIGNED_INT,
}

---@type table<gfx.CompareFunction, number>
local compareFnsMap = {
	[gfx.CompareFunction.NEVER] = gl.NEVER,
	[gfx.CompareFunction.LESS] = gl.LESS,
	[gfx.CompareFunction.EQUAL] = gl.EQUAL,
	[gfx.CompareFunction.LESS_EQUAL] = gl.LESS_EQUAL,
	[gfx.CompareFunction.GREATER] = gl.GREATER,
	[gfx.CompareFunction.NOT_EQUAL] = gl.NOTEQUAL,
	[gfx.CompareFunction.GREATER_EQUAL] = gl.GREATER_EQUAL,
	[gfx.CompareFunction.ALWAYS] = gl.ALWAYS,
}

function GLCommandBuffer:execute()
	---@type gfx.gl.Pipeline?
	local pipeline

	--- TODO: absolutely cache the vao somewhere instead of recreating it every frame
	---@type gfx.gl.VAO?
	local vao

	local indexType = gl.UNSIGNED_INT

	for _, command in ipairs(self.commands) do
		if command.type == "beginRendering" then
			local attachments = command.descriptor.colorAttachments
			for _, attachment in ipairs(attachments) do
				local texture = attachment.texture --[[@as gfx.gl.Texture]]
				if texture.id then
					-- Rendering to a texture rather than a framebuffer
					error("Haven't handled this case yet")
				end

				texture.context:makeCurrent()
				if not vaos[texture.context] then
					local vao = GLVAO.new()
					vaos[texture.context] = vao
				end
				vao = vaos[texture.context]
				vao:bind()

				assert(texture.framebuffer == 0, "Unimplemented: support for different frame buffers")
				gl.bindFramebuffer(gl.FRAMEBUFFER, texture.framebuffer)
				executeOp(attachment.op)
			end

			-- TODO: Support separate depth/stencil textures
			local depthStencilAttachment = command.descriptor.depthStencilAttachment
			if depthStencilAttachment then
				local texture = depthStencilAttachment.texture --[[@as gfx.gl.Texture]]
				executeDepthOp(depthStencilAttachment.op)
			end
		elseif command.type == "setPipeline" then
			-- todo: pipelines need to be fixed as they are created in the headless context atm
			pipeline = command.pipeline

			local rawPipeline = pipelines[pipeline]
			if not rawPipeline then
				rawPipeline = pipeline:genForCurrentContext()
				pipelines[pipeline] = rawPipeline
			end
			rawPipeline:bind()

			if pipeline.depthStencil then
				gl.enable(gl.DEPTH_TEST)

				local compareFunc = pipeline.depthStencil.depthCompare
				local glCompareFunc = compareFnsMap[compareFunc]
				gl.depthFunc(glCompareFunc)
				gl.depthMask(pipeline.depthStencil.depthWriteEnabled)
			else
				gl.disable(gl.DEPTH_TEST)
			end

			for _, target in ipairs(pipeline.fragment.targets) do
				if target.blend == gfx.BlendState.ALPHA_BLENDING then
					gl.enable(gl.BLEND)
					gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
				else
					gl.disable(gl.BLEND)
				end
			end
		elseif command.type == "setViewport" then
			gl.viewport(command.x, command.y, command.width, command.height)
		elseif command.type == "endRendering" then
			gl.bindFramebuffer(gl.FRAMEBUFFER, 0)
		elseif command.type == "setVertexBuffer" then
			if not pipeline then
				error("Pipeline must be set before setting vertex buffers")
			end

			local descriptor = pipeline.vertex.buffers[command.slot + 1]
			vao:setVertexBuffer(command.buffer, descriptor, command.slot)
		elseif command.type == "setIndexBuffer" then
			vao:setIndexBuffer(command.buffer)
			indexType = indexFormatToGL[command.format]
		elseif command.type == "writeBuffer" then
			command.buffer:setSlice(command.size, command.data, command.offset)
		elseif command.type == "writeTexture" then
			command.texture:writeData(command.descriptor, command.data)
		elseif command.type == "setBindGroup" then
			for _, entry in ipairs(command.bindGroup.entries) do
				if entry.type == "buffer" then
					local buffer = entry.buffer --[[@as gfx.gl.Buffer]]
					if buffer.isUniform then
						gl.bindBufferBase(gl.UNIFORM_BUFFER, entry.binding, buffer.id)
					else
						error("Only uniform buffers are supported in bind groups for now")
					end
				elseif entry.type == "texture" then
					local texture = entry.texture --[[@as gfx.gl.Texture]]
					gl.bindTextureUnit(entry.binding, texture.id)
				elseif entry.type == "sampler" then
					local sampler = entry.sampler --[[@as gfx.gl.Sampler]]
					gl.bindSampler(entry.binding, sampler.id)
				end
			end
		elseif command.type == "drawIndexed" then
			gl.drawElements(gl.TRIANGLES, command.indexCount, indexType, nil)
		else
			print("Unknown command type: " .. tostring(command.type))
		end
	end
end

return GLCommandBuffer
