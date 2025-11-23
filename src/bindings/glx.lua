local ffi = require("ffi")

ffi.cdef[[
    // X11
    typedef void* Display;
    typedef unsigned long Window;
    typedef void* XVisualInfo;
    typedef void* GLXContext;

    XVisualInfo* glXChooseVisual(Display*, int, int*);
    GLXContext glXCreateContext(Display*, XVisualInfo*, GLXContext, int);
    int glXMakeCurrent(Display*, Window, GLXContext);
    void glXSwapBuffers(Display*, Window);
]]

local GLX_RGBA = 4
local GLX_DEPTH_SIZE = 12
local GLX_DOUBLEBUFFER = 5

local C = ffi.load("GL")

return {
    GLX_RGBA = GLX_RGBA,
    GLX_DEPTH_SIZE = GLX_DEPTH_SIZE,
    GLX_DOUBLEBUFFER = GLX_DOUBLEBUFFER,

    ---@type fun(display: userdata, screen: number, attribs: userdata): userdata
    chooseVisual = C.glXChooseVisual,

    ---@type fun(display: userdata, vis: userdata, share_list: userdata, direct: number): userdata
    createContext = C.glXCreateContext,

    ---@type fun(display: userdata, window: number, ctx: userdata): number
    makeCurrent = C.glXMakeCurrent,

    ---@type fun(display: userdata, window: number)
    swapBuffers = C.glXSwapBuffers,
}
