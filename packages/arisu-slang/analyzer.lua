local analyzer = {}

---@class slang.TypedNumberNode: slang.NumberNode
---@field variant "number"
---@field type slang.Type

---@class slang.TypedStringNode: slang.StringNode
---@field variant "string"
---@field type slang.Type

---@class slang.TypedIdentNode: slang.IdentNode
---@field variant "ident"
---@field type slang.Type

---@class slang.TypedDeclarationNode: slang.DeclarationNode
---@field variant "let"
---@field type slang.Type

---@class slang.TypedUniformDefinitionNode: slang.UniformDefinitionNode
---@field variant "uniform"
---@field type slang.Type

---@class slang.TypedStorageBufferDefinitionNode: slang.StorageBufferDefinitionNode
---@field variant "storage"
---@field type slang.Type

---@class slang.TypedAddNode: slang.AddNode
---@field variant "+"
---@field type slang.Type

---@class slang.TypedSubNode: slang.SubNode
---@field variant "-"
---@field type slang.Type

---@class slang.TypedMulNode: slang.MulNode
---@field variant "*"
---@field type slang.Type

---@class slang.TypedDivNode: slang.DivNode
---@field variant "/"
---@field type slang.Type

---@class slang.TypedIndexNode: slang.IndexNode
---@field variant "index"
---@field type slang.Type

---@class slang.TypedFunctionNode: slang.FunctionNode
---@field variant "fn"
---@field type slang.Type

---@class slang.TypedNotNode: slang.NotNode
---@field variant "!"
---@field type slang.Type

---@class slang.TypedIfNode: slang.IfNode
---@field variant "if"
---@field type slang.Type

---@class slang.TypedReturnNode: slang.ReturnNode
---@field variant "return"
---@field type slang.Type

---@class slang.TypedBlockNode: slang.BlockNode
---@field variant "block"
---@field type slang.Type

---@class slang.TypedCallNode: slang.CallNode
---@field variant "call"
---@field type slang.Type

---@class slang.TypedTestNode: slang.TestNode
---@field variant "test"
---@field type slang.Type

---@alias slang.TypedNode
--- | slang.TypedNumberNode
--- | slang.TypedStringNode
--- | slang.TypedIdentNode
--- | slang.TypedDeclarationNode
--- | slang.TypedUniformDefinitionNode
--- | slang.TypedStorageBufferDefinitionNode
--- | slang.TypedAddNode
--- | slang.TypedSubNode
--- | slang.TypedMulNode
--- | slang.TypedDivNode
--- | slang.TypedIndexNode
--- | slang.TypedFunctionNode
--- | slang.TypedNotNode
--- | slang.TypedIfNode
--- | slang.TypedReturnNode
--- | slang.TypedBlockNode
--- | slang.TypedCallNode
--- | slang.TypedTestNode

---@param ast slang.Node
---@return slang.TypedNode
function analyzer.analyze(ast) end

return analyzer
