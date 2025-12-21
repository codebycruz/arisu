---@alias gfx.ShaderModule
---| { type: "glsl", source: string }
---| { type: "spirv", source: string }

---@class gfx.DepthStencilState
---@field depthWriteEnabled boolean
---@field depthCompare gfx.CompareFunction
---@field format gfx.TextureFormat

---@class gfx.VertexState
---@field module gfx.ShaderModule
---@field buffers gfx.VertexLayout[]

---@class gfx.ColorTargetState
---@field format gfx.TextureFormat
---@field blend? gfx.BlendState
---@field writeMask? gfx.ColorWrites

---@class gfx.FragmentState
---@field module gfx.ShaderModule
---@field targets? gfx.ColorTargetState[]

---@class gfx.PipelineDescriptor
---@field vertex gfx.VertexState
---@field fragment gfx.FragmentState
---@field depthStencil? gfx.DepthStencilState

---@class gfx.Pipeline
local Pipeline = require("arisu-gfx.pipeline.gl") --[[@as gfx.Pipeline]]

return Pipeline
