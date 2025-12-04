local ffi = require("ffi")

ffi.cdef([[
	typedef void* HDC;
	typedef int BOOL;
	typedef struct {
		WORD  nSize;
		WORD  nVersion;
		DWORD dwFlags;
		BYTE  iPixelType;
		BYTE  cColorBits;
		BYTE  cRedBits;
		BYTE  cRedShift;
		BYTE  cGreenBits;
		BYTE  cGreenShift;
		BYTE  cBlueBits;
		BYTE  cBlueShift;
		BYTE  cAlphaBits;
		BYTE  cAlphaShift;
		BYTE  cAccumBits;
		BYTE  cAccumRedBits;
		BYTE  cAccumGreenBits;
		BYTE  cAccumBlueBits;
		BYTE  cAccumAlphaBits;
		BYTE  cDepthBits;
		BYTE  cStencilBits;
		BYTE  cAuxBuffers;
		BYTE  iLayerType;
		BYTE  bReserved;
		DWORD dwLayerMask;
		DWORD dwVisibleMask;
		DWORD dwDamageMask;
	} PIXELFORMATDESCRIPTOR;

	int ChoosePixelFormat(HDC hdc, const PIXELFORMATDESCRIPTOR* ppfd);
	BOOL SetPixelFormat(HDC hdc, int iPixelFormat, const PIXELFORMATDESCRIPTOR* ppfd);
	void SwapBuffers(HDC hdc);
]])

---@class gdi.PIXELFORMATDESCRIPTOR: ffi.cdata*
---@field nSize number
---@field nVersion number
---@field dwFlags number
---@field iPixelType number
---@field cColorBits number
---@field cRedBits number
---@field cRedShift number
---@field cGreenBits number
---@field cGreenShift number
---@field cBlueBits number
---@field cBlueShift number
---@field cAlphaBits number
---@field cAlphaShift number
---@field cAccumBits number
---@field cAccumRedBits number
---@field cAccumGreenBits number
---@field cAccumBlueBits number
---@field cAccumAlphaBits number
---@field cDepthBits number
---@field cStencilBits number
---@field cAuxBuffers number
---@field iLayerType number

local C = ffi.load("gdi32")

return {
	---@type fun(hdc: user32.HDC, ppfd: gdi.PIXELFORMATDESCRIPTOR): integer
	choosePixelFormat = C.ChoosePixelFormat,

	---@type fun(hdc: user32.HDC, iPixelFormat: integer, ppfd: gdi.PIXELFORMATDESCRIPTOR): boolean
	setPixelFormat = C.SetPixelFormat,

	---@type fun(hdc: user32.HDC)
	swapBuffers = C.SwapBuffers,
}
