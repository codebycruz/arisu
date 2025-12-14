---@class gfx.gl.Pipeline
---@field fragment gfx.FragmentState
---@field vertex gfx.VertexState
local GLPipeline = {}
GLPipeline.__index = GLPipeline

---@param descriptor gfx.PipelineDescriptor
function GLPipeline.new(descriptor)
	return setmetatable({ fragment = descriptor.fragment, vertex = descriptor.vertex }, GLPipeline)
end

return GLPipeline
