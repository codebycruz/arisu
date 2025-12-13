local ffi = require("ffi")

local util = {}

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
