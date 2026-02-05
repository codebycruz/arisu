local gl = require("hood-opengl")

local hood = require("hood")
local GLVAO = require("hood.gl_vao")

---@class hood.gl.CommandBuffer
---@field private commands hood.gl.Command[]
---@field private svbCache table # tbd
local GLCommandBuffer = {}
GLCommandBuffer.__index = GLCommandBuffer

---@param commands hood.gl.Command[]
function GLCommandBuffer.new(commands)
	return setmetatable({ svbCache = {}, commands = commands }, GLCommandBuffer)
end

---@param op hood.LoadOp
local function executeOp(op)
	if op.type == "clear" then
		gl.clearColor(op.color.r, op.color.g, op.color.b, op.color.a)
		gl.clear(gl.COLOR_BUFFER_BIT)
	elseif op.type == "load" then
		-- Do nothing, just keep the existing content
	end
end

---@param op hood.DepthOp
local function executeDepthOp(op)
	if op.type == "clear" then
		gl.depthMask(true)
		gl.clearDepthf(op.depth)
		gl.clear(gl.DEPTH_BUFFER_BIT)
	end
end

---@type table<hood.gl.Context, hood.gl.VAO>
local vaos = setmetatable({}, {
	__mode = "k",
})

--- TODO: Probably need to support multiple contexts too?
---@type table<hood.gl.Pipeline, hood.gl.RawPipeline>
local pipelines = setmetatable({}, {
	__mode = "k",
})

---@type table<hood.gl.ComputePipeline, hood.gl.RawComputePipeline>
local computePipelines = setmetatable({}, {
	__mode = "k",
})

---@type table<hood.IndexFormat, number>
local indexFormatToGL = {
	[hood.IndexType.u16] = gl.UNSIGNED_SHORT,
	[hood.IndexType.u32] = gl.UNSIGNED_INT,
}

---@type table<hood.CompareFunction, number>
local compareFnsMap = {
	[hood.CompareFunction.NEVER] = gl.NEVER,
	[hood.CompareFunction.LESS] = gl.LESS,
	[hood.CompareFunction.EQUAL] = gl.EQUAL,
	[hood.CompareFunction.LESS_EQUAL] = gl.LESS_EQUAL,
	[hood.CompareFunction.GREATER] = gl.GREATER,
	[hood.CompareFunction.NOT_EQUAL] = gl.NOTEQUAL,
	[hood.CompareFunction.GREATER_EQUAL] = gl.GREATER_EQUAL,
	[hood.CompareFunction.ALWAYS] = gl.ALWAYS,
}

---@type table<hood.StorageAccess, number>
local accessMap = {
	["READ_ONLY"] = gl.READ_ONLY,
	["WRITE_ONLY"] = gl.WRITE_ONLY,
	["READ_WRITE"] = gl.READ_WRITE,
}

function GLCommandBuffer:execute()
	---@type hood.gl.ComputePipeline?
	local computePipeline

	---@type hood.gl.Pipeline?
	local pipeline

	--- TODO: absolutely cache the vao somewhere instead of recreating it every frame
	---@type hood.gl.VAO?
	local vao

	local indexType = gl.UNSIGNED_INT

	for _, command in ipairs(self.commands) do
		if command.type == "beginRendering" then
			local attachments = command.descriptor.colorAttachments
			for _, attachment in ipairs(attachments) do
				local texture = attachment.texture --[[@as hood.gl.Texture]]
				if not texture.id then -- rendering to a framebuffer
					texture.context:makeCurrent()
					if not vaos[texture.context] then
						local vao = GLVAO.new()
						vaos[texture.context] = vao
					end
					vao = vaos[texture.context]
					vao:bind()
				end

				assert(texture.framebuffer == 0, "Unimplemented: support for different frame buffers")
				gl.bindFramebuffer(gl.FRAMEBUFFER, texture.framebuffer)
				executeOp(attachment.op)
			end

			-- TODO: Support separate depth/stencil textures
			local depthStencilAttachment = command.descriptor.depthStencilAttachment
			if depthStencilAttachment then
				local texture = depthStencilAttachment.texture --[[@as hood.gl.Texture]]
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
				if target.blend == hood.BlendState.ALPHA_BLENDING then
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
					local buffer = entry.buffer --[[@as hood.gl.Buffer]]
					if buffer.isUniform then
						gl.bindBufferBase(gl.UNIFORM_BUFFER, entry.binding, buffer.id)
					elseif buffer.isStorage then
						gl.bindBufferBase(gl.SHADER_STORAGE_BUFFER, entry.binding, buffer.id)
					else
						error("Only uniform or storage buffers are supported in bind groups for now")
					end
				elseif entry.type == "texture" then
					local texture = entry.texture --[[@as hood.gl.Texture]]
					gl.bindTextureUnit(entry.binding, texture.id)
				elseif entry.type == "sampler" then
					local sampler = entry.sampler --[[@as hood.gl.Sampler]]
					gl.bindSampler(entry.binding, sampler.id)
				elseif entry.type == "storageTexture" then
					local texture = entry.texture --[[@as hood.gl.Texture]]

					gl.bindImageTexture(
						entry.binding,
						texture.id,
						0,
						entry.layer and 0 or 1,
						entry.layer or 0,
						accessMap[entry.access],
						texture.format
					)
				end
			end
		elseif command.type == "drawIndexed" then
			gl.drawElements(gl.TRIANGLES, command.indexCount, indexType, nil)
		elseif command.type == "beginComputePass" then
			gl.bindVertexArray(0)
		elseif command.type == "setComputePipeline" then
			computePipeline = command.pipeline

			local rawComputePipeline = computePipelines[computePipeline]
			if not rawComputePipeline then
				rawComputePipeline = computePipeline:genForCurrentContext()
				computePipelines[computePipeline] = rawComputePipeline
			end
			rawComputePipeline:bind()
		elseif command.type == "dispatchWorkgroups" then
			gl.dispatchCompute(command.x, command.y, command.z)
			gl.memoryBarrier(gl.ALL_BARRIER_BITS)
			gl.finish()
		else
			print("Unknown command type: " .. tostring(command.type))
		end
	end
end

return GLCommandBuffer
