local ffi = require("ffi")

local isWindows = string.sub(package.config, 1, 1) == "\\"
local isUnix = string.sub(package.config, 1, 1) == "/"

local util = {}

function util.isWindows()
	return isWindows
end

function util.isUnix()
	return isUnix
end

-- This should work in the majority of cases
function util.toPointer(value)
	return tonumber(ffi.cast("uintptr_t", value))
end

return util
