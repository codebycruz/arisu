local ffi = require("ffi")

ffi.cdef([[
	typedef void* HDC;
	typedef void* HGLRC;
	typedef void* HWND;
	typedef int BOOL;
	typedef unsigned short WORD;
	typedef unsigned long DWORD;
	typedef unsigned char BYTE;

	void* wglGetProcAddress(const char* name);

	HGLRC wglCreateContext(HDC hdc);
	BOOL wglMakeCurrent(HDC hdc, HGLRC hglrc);
	BOOL wglDeleteContext(HGLRC hglrc);
]])

local C = ffi.load("opengl32")

---@class wgl.HGLRC: userdata

return {
	---@type fun(name: string): fun(...): any
	getProcAddress = C.wglGetProcAddress,

	---@type fun(hdc: user32.HDC): wgl.HGLRC
	createContext = C.wglCreateContext,

	---@type fun(hdc: user32.HDC, hglrc: wgl.HGLRC): number
	makeCurrent = C.wglMakeCurrent,

	---@type fun(hglrc: wgl.HGLRC): boolean
	deleteContext = C.wglDeleteContext,
}
