local ffi = require("ffi")

ffi.cdef([[
	typedef void* HWND;
	typedef const char* LPCSTR;
	typedef unsigned int UINT;
	typedef int BOOL;
	typedef unsigned short ATOM;
	typedef uintptr_t WPARAM;
	typedef intptr_t LPARAM;
	typedef long LONG;
	typedef unsigned long DWORD;
	typedef struct {
		LONG x;
		LONG y;
	} POINT;
	typedef intptr_t LRESULT;
	typedef void VOID;
	typedef void* HCURSOR;
	typedef void* HMODULE;
	typedef void* HDC;
	typedef void* HICON;
	typedef void* HBRUSH;
	typedef void* HINSTANCE;
	typedef void* HMENU;

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

	typedef LRESULT (__stdcall *WNDPROC)(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

	typedef struct {
		UINT cbSize;
		UINT style;
		WNDPROC lpfnWndProc;
		int cbClsExtra;
		int cbWndExtra;
		HINSTANCE hInstance;
		HICON hIcon;
		HCURSOR hCursor;
		HBRUSH hbrBackground;
		LPCSTR lpszMenuName;
		LPCSTR lpszClassName;
		HICON hIconSm;
	} WNDCLASSEXA;

	HWND CreateWindowExA(
		DWORD dwExStyle,
		LPCSTR lpClassName,
		LPCSTR lpWindowName,
		UINT dwStyle,
		int X,
		int Y,
		int nWidth,
		int nHeight,
		HWND hWndParent,
		HMENU hMenu,
		HINSTANCE hInstance,
		void* lpParam
	);

	// Window Creation
	BOOL DestroyWindow(HWND hWnd);
	BOOL ShowWindow(HWND hWnd, int nCmdShow);
	BOOL UpdateWindow(HWND hWnd);
	BOOL SetWindowTextA(HWND hWnd, LPCSTR lpString);
	ATOM RegisterClassExA(const WNDCLASSEXA* lpWndClass);

	// Cursor
	HCURSOR SetCursor(HCURSOR hCursor);
	HCURSOR LoadCursorA(HMODULE hInstance, LPCSTR lpCursorName);

	// Event Loop
	BOOL PeekMessageA(MSG* lpMsg, HWND hWnd, UINT wMsgFilterMin, UINT wMsgFilterMax, UINT wRemoveMsg);
	BOOL GetMessageA(MSG* lpMsg, HWND hWnd, UINT wMsgFilterMin, UINT wMsgFilterMax);
	BOOL TranslateMessage(const MSG* lpMsg);
	LRESULT DispatchMessageA(const MSG* lpMsg);
	VOID PostQuitMessage(int nExitCode);
	LRESULT DefWindowProcA(HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam);

	// Misc
	HDC GetDC(HWND hWnd);
	HICON LoadIconA(HMODULE hInstance, LPCSTR lpIconName);
	HBRUSH GetSysColorBrush(int nIndex);
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

---@class user32.WNDCLASSEXA: ffi.cdata*
---@field lpfnWndProc userdata
---@field hInstance userdata
---@field lpszClassName string
---@field hCursor userdata
---@field hIcon userdata
---@field hIconSm userdata
---@field cbSize number
---@field hbrBackground userdata
---@field style number

---@class user32.HDC: userdata

local C = ffi.load("user32")

return {
	IDC_ARROW = ffi.cast("LPCSTR", 32512),
	IDC_HAND = ffi.cast("LPCSTR", 32649),

	IDI_APPLICATION = ffi.cast("LPCSTR", 32512),

	COLOR_WINDOW = 5,

	CS_HREDRAW = 0x0002,
	CS_VREDRAW = 0x0001,

	WS_BORDER = 0x00800000,
	WS_CAPTION = 0x00C00000,
	WS_CHILD = 0x40000000,
	WS_CHILDWINDOW = 0x40000000,
	WS_CLIPCHILDREN = 0x02000000,
	WS_CLIPSIBLINGS = 0x04000000,
	WS_DISABLED = 0x08000000,
	WS_DLGFRAME = 0x00400000,
	WS_GROUP = 0x00020000,
	WS_HSCROLL = 0x00100000,
	WS_ICONIC = 0x20000000,
	WS_MAXIMIZE = 0x01000000,
	WS_MAXIMIZEBOX = 0x00010000,
	WS_MINIMIZE = 0x20000000,
	WS_MINIMIZEBOX = 0x00020000,
	WS_OVERLAPPED = 0x00000000,
	WS_OVERLAPPEDWINDOW = 0x00CF0000,
	WS_POPUP = 0x80000000,
	WS_POPUPWINDOW = 0x80880000,
	WS_SIZEBOX = 0x00040000,
	WS_SYSMENU = 0x00080000,
	WS_TABSTOP = 0x00010000,
	WS_THICKFRAME = 0x00040000,
	WS_VISIBLE = 0x10000000,
	WS_VSCROLL = 0x00200000,

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

	---@type fun(dwExStyle: number, lpClassName: string, lpWindowName: string, dwStyle: number, X: number, Y: number, nWidth: number, nHeight: number, hWndParent: userdata?, hMenu: userdata?, hInstance: userdata?, lpParam: userdata?): user32.HWND?
	createWindow = C.CreateWindowExA,

	---@type fun(hWnd: user32.HWND): number
	destroyWindow = C.DestroyWindow,

	---@type fun(hWnd: user32.HWND, nCmdShow: number): boolean
	showWindow = function(hWnd, nCmdShow)
		return C.ShowWindow(hWnd, nCmdShow) ~= 0
	end,

	---@type fun(hWnd: user32.HWND): boolean
	updateWindow = function(hWnd)
		return C.UpdateWindow(hWnd) ~= 0
	end,

	---@type fun(hWnd: user32.HWND, lpString: string): number
	setWindowText = C.SetWindowTextA,

	---@type fun(lpWndClass: user32.WNDCLASSEXA): number
	registerClass = C.RegisterClassExA,

	---@type fun(hCursor: userdata): userdata
	setCursor = C.SetCursor,

	---@type fun(lpMsg: userdata, hWnd: userdata?, wMsgFilterMin: number, wMsgFilterMax: number, wRemoveMsg: number): boolean
	peekMessage = function(lpMsg, hWnd, wMsgFilterMin, wMsgFilterMax, wRemoveMsg)
		return C.PeekMessageA(lpMsg, hWnd or nil, wMsgFilterMin, wMsgFilterMax, wRemoveMsg) ~= 0
	end,

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
		return ffi.new("WNDCLASSEXA", { cbSize = ffi.sizeof("WNDCLASSEXA") })
	end,

	---@type fun(fn: user32.WNDPROC): userdata
	newWndProc = function(fn)
		return ffi.cast("WNDPROC", fn)
	end,

	---@type fun(hwnd: user32.HWND): user32.HDC
	getDC = C.GetDC,

	---@type fun(hwnd: user32.HWND, Msg: number, wParam: number, lParam: number): number
	defWindowProc = C.DefWindowProcA,

	---@type fun(hInstance: userdata, lpCursorName: string): userdata
	loadCursor = C.LoadCursorA,

	---@type fun(hInstance: userdata, lpIconName: string): userdata
	loadIcon = C.LoadIconA,

	---@type fun(nIndex: number): userdata
	getSysColorBrush = C.GetSysColorBrush,
}
