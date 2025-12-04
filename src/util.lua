local ffi = require("ffi")

local Util = {}

function Util.isWindows()
	return package.config:sub(1, 1) == '\\'
end

function Util.isUnix()
	return package.config:sub(1, 1) == '/'
end

-- This should work in the majority of cases
function Util.toPointer(value)
	return tonumber(ffi.cast("uintptr_t", value))
end

return Util
