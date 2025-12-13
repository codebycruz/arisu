local ffi = require("ffi")

local util = {}

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
		f64 = 8
	}

	---@param type util.SizeofType
	function util.sizeof(type)
		return sizes[type]
	end
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

-- This should work in the majority of cases
function util.toPointer(value)
	return tonumber(ffi.cast("uintptr_t", value))
end

return util
