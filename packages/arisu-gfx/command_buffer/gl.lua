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

---@type table<gfx.gl.Context, gfx.gl.VAO>
local vaos = setmetatable({}, {
	__mode = "k",
})

---@type table<gfx.IndexFormat, number>
local indexFormatToGL = {
	[gfx.IndexType.u16] = gl.UNSIGNED_SHORT,
	[gfx.IndexType.u32] = gl.UNSIGNED_INT,
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

					print("created vao", vao.id)
				end
				vao = vaos[texture.context]
				vao:bind()

				gl.bindFramebuffer(gl.FRAMEBUFFER, texture.framebuffer)
				executeOp(attachment.op)
			end
		elseif command.type == "setPipeline" then
			pipeline = command.pipeline

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
			local buffer = command.buffer --[[@as gfx.gl.Buffer]]
			buffer:setSlice(command.size, command.data, command.offset)
		elseif command.type == "setBindGroup" then
			-- I don't think this needs to exist for OpenGL
		elseif command.type == "drawIndexed" then
			gl.drawElements(gl.TRIANGLES, command.indexCount, indexType, nil)
		else
			print("Unknown command type: " .. tostring(command.type))
		end
	end
end

return GLCommandBuffer
