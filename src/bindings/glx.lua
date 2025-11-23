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

local C = ffi.load("GL")

return {
    RGBA = 4,
    DEPTH_SIZE = 12,
    DOUBLEBUFFER = 5,

    ---@param display XDisplay
    ---@param screen number
    ---@param attributes number[]
    ---@return userdata
    chooseVisual = function(display, screen, attributes)
        local attribList = ffi.new("int[?]", #attributes + 1, attributes)
        attribList[#attributes] = 0

        return C.glXChooseVisual(display, screen, attribList)
    end,

    ---@type fun(display: userdata, vis: userdata, share_list: userdata, direct: number): userdata
    createContext = C.glXCreateContext,

    ---@type fun(display: userdata, window: number, ctx: userdata): number
    makeCurrent = C.glXMakeCurrent,

    ---@type fun(display: userdata, window: number)
    swapBuffers = C.glXSwapBuffers,
}
