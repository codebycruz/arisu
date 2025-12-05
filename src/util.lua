local ffi = require("ffi")

local isWindows = string.sub(package.config, 1, 1) == "\\"
local isUnix = string.sub(package.config, 1, 1) == "/"

local Util = {}

function Util.isWindows()
	return isWindows
end

function Util.isUnix()
	return isUnix
end

-- This should work in the majority of cases
function Util.toPointer(value)
	return tonumber(ffi.cast("uintptr_t", value))
end

return Util
