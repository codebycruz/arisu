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

	HWND CreateWindowA(
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
]])

local C = ffi.load("user32")

return {
	---@type fun(lpClassName: string, lpWindowName: string, dwStyle: number, X: number, Y: number, nWidth: number, nHeight: number, hWndParent: userdata?, hMenu: userdata?, hInstance: userdata?, lpParam: userdata?): userdata?
	createWindow = C.CreateWindowA,

	---@type fun(hWnd: userdata): number
	destroyWindow = C.DestroyWindow,

	---@type fun(hWnd: userdata, nCmdShow: number): number
	showWindow = C.ShowWindow,

	---@type fun(hWnd: userdata): number
	updateWindow = C.UpdateWindow,

	---@type fun(hWnd: userdata, lpString: string): number
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

	---@type fun(): userdata
	newMsg = function()
		return ffi.new("MSG")
	end,

	---@type fun(): userdata
	newWndClassEx = function()
		return ffi.new("WNDCLASSEXA")
	end,
}
