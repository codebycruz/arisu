local typing = require("arisu-slang.typing")

---@alias slang.vm.Scope table<string, slang.vm.Value>

---@class slang.vm.NumberValue
---@field variant "number"
---@field value number

---@class slang.vm.StringValue
---@field variant "string"
---@field value string

---@class slang.vm.BoolValue
---@field variant "bool"
---@field value boolean

---@class slang.vm.RecordValue
---@field variant "record"
---@field fields table<string, slang.vm.Value>

---@alias slang.vm.Value
--- | slang.vm.NumberValue
--- | slang.vm.StringValue
--- | slang.vm.BoolValue
--- | slang.vm.RecordValue

---@class slang.vm.Interpreter
---@field scopes slang.vm.Scope[]
local Interpreter = {}
Interpreter.__index = Interpreter

---@param scope slang.vm.Scope?
function Interpreter.new(scope)
	return setmetatable({ scopes = { scope or {} } }, Interpreter)
end

function Interpreter:pushScope()
	self.scopes[#self.scopes + 1] = {}
end

function Interpreter:popScope()
	self.scopes[#self.scopes] = nil
end

---@param v slang.vm.Value
---@return slang.Type
function Interpreter.typeOfValue(v)
	if v.variant == "number" then
		return typing.f32
	elseif v.variant == "string" then
		return typing.string
	elseif v.variant == "bool" then
		return typing.bool
	elseif v.variant == "record" then
		local fields = {} ---@type table<string, slang.Type>
		for name, value in pairs(v.fields) do
			fields[name] = Interpreter.typeOfValue(value)
		end

		return { type = "record", fields = fields }
	else
		error("Unsupported value variant in typeOfValue: " .. tostring(v.variant))
	end
end

---@param name string
---@return slang.vm.Value?
function Interpreter:lookupVar(name)
	for i = #self.scopes, 1, -1 do
		local scope = self.scopes[i]
		if scope[name] then
			return scope[name]
		end
	end
end

---@param n slang.Node
---@return slang.vm.Value
function Interpreter:eval(n)
	if n.variant == "const" then
		local value = self:eval(n.value)
		self.scopes[#self.scopes][n.name.value] = value
		return value
	elseif n.variant == "let" then
		local value = self:eval(n.value)
		self.scopes[#self.scopes][n.name.value] = value
		return value
	elseif n.variant == "number" then
		return { variant = "number", value = n.value }
	elseif n.variant == "string" then
		return { variant = "string", value = n.value }
	elseif n.variant == "bool" then
		return { variant = "bool", value = n.value }
	elseif n.variant == "ident" then
		local v = self:lookupVar(n.value)
		if not v then
			error("Undefined variable: " .. n.value)
		end

		return v
	elseif n.variant == "recordInit" then
		local fields = {} ---@type table<string, slang.vm.Value>
		for _, field in ipairs(n.fields) do
			fields[field.name] = self:eval(field.value)
		end

		return { variant = "record", fields = fields }
	elseif n.variant == "+" then
		local lhs = self:eval(n.lhs)
		local rhs = self:eval(n.rhs)

		if lhs.variant == "number" and rhs.variant == "number" then
			return { variant = "number", value = lhs.value + rhs.value }
		else
			error("Unsupported operand types for +: " .. lhs.variant .. " and " .. rhs.variant)
		end
	elseif n.variant == "-" then
		local lhs = self:eval(n.lhs)
		local rhs = self:eval(n.rhs)

		if lhs.variant == "number" and rhs.variant == "number" then
			return { variant = "number", value = lhs.value - rhs.value }
		else
			error("Unsupported operand types for -: " .. lhs.variant .. " and " .. rhs.variant)
		end
	elseif n.variant == "*" then
		local lhs = self:eval(n.lhs)
		local rhs = self:eval(n.rhs)

		if lhs.variant == "number" and rhs.variant == "number" then
			return { variant = "number", value = lhs.value * rhs.value }
		else
			error("Unsupported operand types for *: " .. lhs.variant .. " and " .. rhs.variant)
		end
	elseif n.variant == "/" then
		local lhs = self:eval(n.lhs)
		local rhs = self:eval(n.rhs)

		if lhs.variant == "number" and rhs.variant == "number" then
			return { variant = "number", value = lhs.value / rhs.value }
		else
			error("Unsupported operand types for /: " .. lhs.variant .. " and " .. rhs.variant)
		end
	else
		error("Unsupported node variant in interpreter: " .. tostring(n.variant))
	end
end

return Interpreter
