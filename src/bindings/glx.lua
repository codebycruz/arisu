local ffi = require("ffi")

ffi.cdef([[
	// X11
	typedef void* XDisplay;
	typedef unsigned long Window;
	typedef void* GLXContext;
	typedef void* GLXFBConfig;

	int glXMakeCurrent(XDisplay*, Window, GLXContext);
	void glXSwapBuffers(XDisplay*, Window);
	void glXDestroyContext(XDisplay*, GLXContext);

	// Modern OpenGL
	GLXFBConfig* glXChooseFBConfig(XDisplay* dpy, int screen, const int* attrib_list, int* nelements);
	GLXContext glXCreateContextAttribsARB(XDisplay* dpy, GLXFBConfig* config, GLXContext share_context, int direct, const int* attrib_list);

	// Vsync
	void glXSwapIntervalEXT(XDisplay* dpy, Window drawable, int interval);

	// Getters
	GLXContext glXGetCurrentContext();
	XDisplay* glXGetCurrentDisplay();
	Window glXGetCurrentDrawable();
	void glXQueryDrawable(XDisplay* dpy, Window draw, int attribute, unsigned int* value);

	// Misc
	const char* glXQueryExtensionsString(XDisplay* dpy, int screen);
	void* glXGetProcAddress(const unsigned char* procname);
]])

---@class GLXContext: ffi.cdata*
---@class GLXFBConfig: ffi.cdata*

local C = ffi.load("GL")

return {
	RGBA = 4,
	DEPTH_SIZE = 12,
	DOUBLEBUFFER = 5,

	RENDER_TYPE = 0x8011,
	RGBA_BIT = 1,

	DRAWABLE_TYPE = 0x8010,
	WINDOW_BIT = 1,

	CONTEXT_MAJOR_VERSION_ARB = 0x2091,
	CONTEXT_MINOR_VERSION_ARB = 0x2092,

	SWAP_INTERVAL_EXT = 0x20F1,

	---@param display XDisplay
	---@param screen number
	---@param attributes number[]
	---@return GLXFBConfig?
	chooseFBConfig = function(display, screen, attributes)
		local attribList = ffi.new("int[?]", #attributes + 1, attributes)
		attribList[#attributes] = 0

		local nelements = ffi.new("int[1]")
		local configs = C.glXChooseFBConfig(display, screen, attribList, nelements)

		if configs == nil or nelements[0] == 0 then
			return nil
		end

		return configs[0]
	end,

	---@type fun(display: XDisplay, config: GLXFBConfig, share_context: userdata|nil, direct: number, attrib_list: number[]): userdata
	createContextAttribsARB = function(display, config, share_context, direct, attrib_list)
		local attribList = ffi.new("int[?]", #attrib_list + 1, attrib_list)
		attribList[#attrib_list] = 0

		return C.glXCreateContextAttribsARB(display, config, share_context, direct, attribList)
	end,

	---@type fun(display: XDisplay, window: number, ctx: GLXContext): number
	makeCurrent = C.glXMakeCurrent,

	---@type fun(display: XDisplay, window: number)
	swapBuffers = C.glXSwapBuffers,

	---@type fun(display: XDisplay, ctx: GLXContext)
	destroyContext = C.glXDestroyContext,

	---@type fun(display: XDisplay, window: number, interval: number)
	swapIntervalEXT = C.glXSwapIntervalEXT,

	---@type fun(): GLXContext?
	getCurrentContext = C.glXGetCurrentContext,

	---@type fun(): XDisplay?
	getCurrentDisplay = C.glXGetCurrentDisplay,

	---@type fun(): number
	getCurrentDrawable = C.glXGetCurrentDrawable,

	---@type fun(display: XDisplay, draw: number, attribute: number): number
	queryDrawable = function(display, draw, attribute)
		local value = ffi.new("unsigned int[1]")
		C.glXQueryDrawable(display, draw, attribute, value)
		return value[0]
	end,

	---@type fun(display: XDisplay, screen: number): string
	queryExtensionsString = function(display, screen)
		local extStr = C.glXQueryExtensionsString(display, screen)
		if extStr == nil then
			return ""
		end

		return ffi.string(extStr)
	end,

	---@type fun(procname: string): function
	getProcAddress = C.glXGetProcAddress
}
