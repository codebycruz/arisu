local ffi = require("ffi")

ffi.cdef([[
	typedef void* HWND;
	typedef const char* LPCSTR;
	typedef unsigned int UINT;
	typedef int BOOL;
	typedef unsigned short ATOM;
	typedef unsigned long WPARAM;
	typedef long LPARAM;
	typedef long LONG;
	typedef unsigned long DWORD;
	typedef struct {
		LONG x;
		LONG y;
	} POINT;
	typedef long LRESULT;
	typedef void VOID;
	typedef void* HCURSOR;
	typedef void* HMODULE;
	typedef void* HDC;

	typedef struct {
		HWND hwnd;
		UINT message;
		WPARAM wParam;
		LPARAM lParam;
		DWORD time;
		POINT pt;
		DWORD lPrivate;
	} MSG;
	typedef MSG* LPMSG;

	typedef LRESULT (*WNDPROC)(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

	typedef struct {
		UINT cbSize;
		UINT style;
		void* lpfnWndProc;
		int cbClsExtra;
		int cbWndExtra;
		void* hInstance;
		void* hIcon;
		void* hCursor;
		void* hbrBackground;
		LPCSTR lpszMenuName;
		LPCSTR lpszClassName;
		void* hIconSm;
	} WNDCLASSEXA;

	HWND CreateWindowExA(
		LPCSTR lpClassName,
		LPCSTR lpWindowName,
		UINT dwStyle,
		int X,
		int Y,
		int nWidth,
		int nHeight,
		HWND hWndParent,
		void* hMenu,
		void* hInstance,
		void* lpParam
	);

	// Window Creation
	BOOL DestroyWindow(HWND hWnd);
	BOOL ShowWindow(HWND hWnd, int nCmdShow);
	BOOL UpdateWindow(HWND hWnd);
	BOOL SetWindowTextA(HWND hWnd, LPCSTR lpString);
	ATOM RegisterClassA(const WNDCLASSEXA* lpWndClass);

	// Cursor
	HCURSOR SetCursor(HCURSOR hCursor);

	// Event Loop
	BOOL PeekMessageA(void* lpMsg, HWND hWnd, UINT wMsgFilterMin, UINT wMsgFilterMax, UINT wRemoveMsg);
	BOOL GetMessageA(void* lpMsg, HWND hWnd, UINT wMsgFilterMin, UINT wMsgFilterMax);
	BOOL TranslateMessage(const MSG* lpMsg);
	LRESULT DispatchMessageA(const MSG* lpMsg);
	VOID PostQuitMessage(int nExitCode);

	// Misc
	HDC GetDC(HWND hWnd);
]])

---@class user32.HWND: userdata

---@class user32.MSG: userdata
---@field hwnd user32.HWND
---@field message number
---@field wParam number
---@field lParam number
---@field time number
---@field pt { x: number, y: number }
---@field lPrivate number

---@alias user32.WNDPROC fun(hWnd: user32.HWND, uMsg: number, wParam: number, lParam: number): number

---@class user32.WNDCLASSEXA: userdata
---@field lpfnWndProc userdata
---@field hInstance userdata
---@field lpszClassName string
---@field hCursor userdata

---@class user32.HDC: userdata

local C = ffi.load("user32")

return {
	WS_OVERLAPPED = 0x0,
	WS_CAPTION = 0x00C,
	WS_BORDER = 0x008,
	WS_SYSMENU = 0x0008,
	WS_THICKFRAME = 0x00040000,
	WS_MINIMIZEBOX = 0x00020000,
	WS_MAXIMIZEBOX = 0x00010000,
	WS_OVERLAPPEDWINDOW = 0x00CF0000,

	PM_REMOVE = 0x0001,

	---@enum user32.ShowWindow
	ShowWindow = {
		HIDE = 0,
		SHOWNORMAL = 1,
		SHOWMINIMIZED = 2,
		SHOWMAXIMIZED = 3,
		SHOWNOACTIVATE = 4,
		SHOW = 5,
		MINIMIZE = 6,
		SHOWMINNOACTIVE = 7,
		SHOWNA = 8,
		RESTORE = 9,
		SHOWDEFAULT = 10,
		FORCEMINIMIZE = 11,
	},

	CW_USEDEFAULT = 0x80000000,

	---@type fun(lpClassName: string, lpWindowName: string, dwStyle: number, X: number, Y: number, nWidth: number, nHeight: number, hWndParent: userdata?, hMenu: userdata?, hInstance: userdata?, lpParam: userdata?): user32.HWND?
	createWindow = C.CreateWindowExA,

	---@type fun(hWnd: user32.HWND): number
	destroyWindow = C.DestroyWindow,

	---@type fun(hWnd: user32.HWND, nCmdShow: number): number
	showWindow = C.ShowWindow,

	---@type fun(hWnd: user32.HWND): number
	updateWindow = C.UpdateWindow,

	---@type fun(hWnd: user32.HWND, lpString: string): number
	setWindowText = C.SetWindowTextA,

	---@type fun(lpWndClass: userdata): number
	registerClass = C.RegisterClassA,

	---@type fun(hCursor: userdata): userdata
	setCursor = C.SetCursor,

	---@type fun(lpMsg: userdata, hWnd: userdata?, wMsgFilterMin: number, wMsgFilterMax: number, wRemoveMsg: number): number
	peekMessage = C.PeekMessageA,

	---@type fun(lpMsg: userdata, hWnd: userdata?, wMsgFilterMin: number, wMsgFilterMax: number): number
	getMessage = C.GetMessageA,

	---@type fun(lpMsg: userdata): number
	translateMessage = C.TranslateMessage,

	---@type fun(lpMsg: userdata): number
	dispatchMessage = C.DispatchMessageA,

	---@type fun(nExitCode: number)
	postQuitMessage = C.PostQuitMessage,

	---@type fun(): user32.MSG
	newMsg = function()
		return ffi.new("MSG")
	end,

	---@type fun(): user32.WNDCLASSEXA
	newWndClassEx = function()
		return ffi.new("WNDCLASSEXA")
	end,

	---@type fun(fn: user32.WNDPROC): userdata
	newWndProc = function(fn)
		return ffi.cast("WNDPROC", fn)
	end,

	---@type fun(hwnd: user32.HWND): user32.HDC
	getDC = C.GetDC,
}
