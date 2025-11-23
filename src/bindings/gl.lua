local ffi = require("ffi")

ffi.cdef[[
    // Types
    typedef unsigned int GLenum;
    typedef unsigned int GLuint;
    typedef int GLsizei;
    typedef int GLint;
    typedef char GLchar;
    typedef void (*GLDEBUGPROC)(unsigned int, unsigned int, unsigned int, unsigned int, int, const char*, const void*);

    void glClear(unsigned int mask);
    void glClearColor(float r, float g, float b, float a);

    // Compiling shaders
    GLuint glCreateShaderProgramv(GLenum type, GLsizei count, const char** strings);
    void glGetProgramiv(GLuint program, GLenum pname, GLint* params);
    void glGetProgramInfoLog(GLuint program, GLsizei bufSize, GLsizei* length, GLchar* infoLog);
]]

local C = ffi.load("GL")

return {
    INVALID_VALUE = 0x0501,
    INVALID_OPERATION = 0x0502,

    COLOR_BUFFER_BIT = 0x4000,
    DEPTH_BUFFER_BIT = 0x0100,

    SHADER_TYPE = {
        VERTEX = 0x8B31,
        FRAGMENT = 0x8B30,
    },

    createShaderProgram = function(type, src)
        local srcs = ffi.new("const char*[1]", { src })
        local program = C.glCreateShaderProgramv(type, 1, srcs)

        local status = ffi.new("GLint[1]")
        C.glGetProgramiv(program, 0x8B82 --[[GL_LINK_STATUS]], status)

        if status[0] == 0 then
            local infoLogLength = ffi.new("GLint[1]")
            C.glGetProgramiv(program, 0x8B84 --[[GL_INFO_LOG_LENGTH]], infoLogLength)

            local infoLog = ffi.new("GLchar[?]", infoLogLength[0])
            C.glGetProgramInfoLog(program, infoLogLength[0], nil, infoLog)

            error("Shader compilation failed: " .. ffi.string(infoLog))
        end

        return program
    end,

    ---@type fun(mask: number)
    clear = C.glClear,

    ---@type fun(r: number, g: number, b: number, a: number)
    clearColor = C.glClearColor,
}
