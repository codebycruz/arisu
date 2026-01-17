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
    int glXMakeContextCurrent(XDisplay*, Window, Window, GLXContext);

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


local glx = {}

do
    glx.RGBA = 4
    glx.DEPTH_SIZE = 12
    glx.DOUBLEBUFFER = 5

    glx.RENDER_TYPE = 0x8011
    glx.RGBA_BIT = 1

    glx.DRAWABLE_TYPE = 0x8010
    glx.WINDOW_BIT = 1

    glx.CONTEXT_MAJOR_VERSION_ARB = 0x2091
    glx.CONTEXT_MINOR_VERSION_ARB = 0x2092

    glx.CONTEXT_PROFILE_MASK_ARB = 0x9126
    glx.CONTEXT_CORE_PROFILE_BIT_ARB = 0x00000001

    glx.SWAP_INTERVAL_EXT = 0x20F1
end

do
    local core = ffi.load("libGL.so.1")

    ---@type fun(display: XDisplay, window: number, context: GLXContext)
    glx.makeCurrent = core.glXMakeCurrent

    ---@type fun(display: XDisplay, window: number, read: number, context: GLXContext)
    glx.makeContextCurrent = core.glXMakeContextCurrent

    ---@type fun(display: XDisplay, window: number)
    glx.swapBuffers = core.glXSwapBuffers

    ---@type fun(display: XDisplay, ctx: GLXContext)
    glx.destroyContext = core.glXDestroyContext

    ---@type fun(): GLXContext?
    glx.getCurrentContext = core.glXGetCurrentContext

    ---@type fun(): XDisplay?
    glx.getCurrentDisplay = core.glXGetCurrentDisplay

    ---@type fun(): number
    glx.getCurrentDrawable = core.glXGetCurrentDrawable

    ---@type fun(display: XDisplay, draw: number, attribute: number): number
    glx.queryDrawable = function(display, draw, attribute)
        local value = ffi.new("unsigned int[1]")
        core.glXQueryDrawable(display, draw, attribute, value)
        return value[0]
    end

    ---@type fun(display: XDisplay, screen: number): string
    glx.queryExtensionsString = function(display, screen)
        local extStr = core.glXQueryExtensionsString(display, screen)
        if extStr == nil then
            return ""
        end

        return ffi.string(extStr)
    end

    ---@type fun(procname: string): function
    glx.getProcAddress = core.glXGetProcAddress
end

do
    local types = {
        glXChooseFBConfig = "GLXFBConfig*(*)(XDisplay*, int, const int*, int*)",
        glXCreateContextAttribsARB = "GLXContext(*)(XDisplay*, GLXFBConfig*, GLXContext, int, const int*)",
    }

    local C = {}
    for name, type in pairs(types) do
        C[name] = ffi.cast(type, glx.getProcAddress(name))
    end

    ---@param display XDisplay
	---@param screen number
	---@param attributes number[]
	---@return GLXFBConfig?
    glx.chooseFBConfig = function(display, screen, attributes)
		local attribList = ffi.new("int[?]", #attributes + 1, attributes)
		attribList[#attributes] = 0

		local nelements = ffi.new("int[1]")
		local configs = C.glXChooseFBConfig(display, screen, attribList, nelements)

		if configs == nil or nelements[0] == 0 then
			return nil
		end

		return configs[0]
	end

	---@type fun(display: XDisplay, config: GLXFBConfig, share_context: userdata|nil, direct: number, attrib_list: number[]): userdata
	glx.createContextAttribsARB = function(display, config, share_context, direct, attrib_list)
		local attribList = ffi.new("int[?]", #attrib_list + 1, attrib_list)
		attribList[#attrib_list] = 0

		return C.glXCreateContextAttribsARB(display, config, share_context, direct, attribList)
	end
end


return glx
