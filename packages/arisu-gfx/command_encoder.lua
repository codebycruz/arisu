---@alias gfx.LoadOp
--- | { type: "clear", color: gfx.Color }
--- | { type: "load" }

---@class gfx.RenderPassDescriptor
---@field colorAttachments { op: gfx.LoadOp, texture: gfx.Texture }[]

---@class gfx.CommandEncoder
---@field finish fun(self: gfx.CommandEncoder): gfx.CommandBuffer
---@field beginRendering fun(self: gfx.CommandEncoder, descriptor: gfx.RenderPassDescriptor)
---@field endRendering fun(self: gfx.CommandEncoder)
---@field setViewport fun(self: gfx.CommandEncoder, x: number, y: number, width: number, height: number)
---@field setVertexBuffer fun(self: gfx.CommandEncoder, slot: number, buffer: gfx.Buffer, offset: number?)
---@field setIndexBuffer fun(self: gfx.CommandEncoder, buffer: gfx.Buffer, offset: number?)
---@field setBindGroup fun(self: gfx.CommandEncoder, index: number, bindGroup: gfx.BindGroup)
---@field setPipeline fun(self: gfx.CommandEncoder, pipeline: gfx.Pipeline)
---@field draw fun(self: gfx.CommandEncoder, vertexCount: number, instanceCount: number, firstVertex: number?, firstInstance: number?)
---@field writeBuffer fun(self: gfx.CommandEncoder, buffer: gfx.Buffer, size: number, data: ffi.cdata*, offset: number?)
local Encoder = require("arisu-gfx.encoder.gl") --[[@as gfx.CommandEncoder]]

return Encoder
