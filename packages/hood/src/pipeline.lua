---@class hood.DepthStencilState
---@field depthWriteEnabled boolean
---@field depthCompare hood.CompareFunction
---@field format hood.TextureFormat

---@class hood.VertexState
---@field module hood.ShaderModule
---@field buffers hood.VertexLayout[]

---@class hood.ColorTargetState
---@field format hood.TextureFormat
---@field blend? hood.BlendState
---@field writeMask? hood.ColorWrites

---@class hood.FragmentState
---@field module hood.ShaderModule
---@field targets? hood.ColorTargetState[]

---@class hood.PipelineDescriptor
---@field vertex hood.VertexState
---@field fragment hood.FragmentState
---@field depthStencil? hood.DepthStencilState

---@class hood.Pipeline
local Pipeline = require("hood.pipeline.gl") --[[@as hood.Pipeline]]

return Pipeline
