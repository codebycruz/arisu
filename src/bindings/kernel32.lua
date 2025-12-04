local ffi = require("ffi")

ffi.cdef([[
	typedef void* HMODULE;
	typedef const char* LPCSTR;
	HMODULE GetModuleHandleA(LPCSTR lpModuleName);
]])

---@class kernel32.HMODULE: ffi.cdata*

local C = ffi.load("kernel32")

return {
	---@type fun(lpModuleName: string?): kernel32.HMODULE
	getModuleHandle = C.GetModuleHandleA,
}
