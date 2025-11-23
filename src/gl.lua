local ffi = require("ffi")

ffi.cdef[[
    typedef void (*GLDEBUGPROC)(unsigned int, unsigned int, unsigned int, unsigned int, int, const char*, const void*);
    void glClear(unsigned int mask);
    void glClearColor(float r, float g, float b, float a);
]]

local C = ffi.load("GL")

return {
    ---@type fun(mask: number)
    clear = C.glClear,

    ---@type fun(r: number, g: number, b: number, a: number)
    clearColor = C.glClearColor,
}
