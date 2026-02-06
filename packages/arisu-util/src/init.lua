local ffi = require("ffi")

local util = {}

---@generic T
---@param tbl T[]
---@return table<T, number>
function util.toLookupTable(tbl)
	local lookup = {}
	for i, v in ipairs(tbl) do
		lookup[v] = i
	end
	return lookup
end

do
	---@alias util.SizeofType
	---|'u8'
	---|'u16'
	---|'u32'
	---|'u64'
	---|'f32'
	---|'f64'

	local sizes = {
		u8 = 1,
		u16 = 2,
		u32 = 4,
		u64 = 8,
		f32 = 4,
		f64 = 8,
	}

	---@param type util.SizeofType
	function util.sizeof(type)
		return sizes[type]
	end
end

---@param done table<any, number>
local function stringify(val, depth, done)
	if done[val] then
		return "<self " .. done[val] .. ">"
	end

	local ty = type(val)
	if ty == "table" then
		local out = { "{" }
		local indent = string.rep("    ", depth + 1)

		done[val] = depth
		for k, v in pairs(val) do
			local key = stringify(k, depth + 1, done)
			local value = stringify(v, depth + 1, done)

			out[#out + 1] = indent .. "[" .. key .. "] = " .. value .. ","
		end
		done[val] = nil

		out[#out + 1] = string.sub(indent, 1, -4) .. "}"
		return table.concat(out, "\n")
	elseif ty == "string" then
		return string.format("%q", val)
	else
		return tostring(val)
	end
end

function util.dbg(val)
	print(stringify(val, 0, {}))
end

function util.isWindows()
	return ffi.os == "Windows"
end

function util.isLinux()
	return ffi.os == "Linux"
end

function util.isMac()
	return ffi.os == "OSX"
end

return util
