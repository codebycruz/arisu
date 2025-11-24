local ffi = require("ffi")

ffi.cdef[[
    // Types
    typedef unsigned int GLenum;
    typedef unsigned int GLuint;
    typedef int32_t GLsizei;
    typedef int32_t GLint;
    typedef uint8_t GLubyte;
    typedef float GLfloat;
    typedef char GLchar;
    typedef intptr_t GLintptr;
    typedef intptr_t GLsizeiptr;

    typedef void (*GLDEBUGPROC)(unsigned int, unsigned int, unsigned int, unsigned int, int, const char*, const void*);

    void glClear(unsigned int mask);
    void glClearColor(float r, float g, float b, float a);
    void glViewport(int x, int y, GLsizei width, GLsizei height);

    // Shader programs
    GLuint glCreateShaderProgramv(GLenum type, GLsizei count, const char** strings);
    void glGetProgramiv(GLuint program, GLenum pname, GLint* params);
    void glGetProgramInfoLog(GLuint program, GLsizei bufSize, GLsizei* length, GLchar* infoLog);
    void glUseProgram(GLuint program);
    void glDeleteProgram(GLuint program);

    // Pipelines
    void glGenProgramPipelines(GLsizei n, GLuint* pipelines);
    void glUseProgramStages(GLuint pipeline, unsigned int stages, GLuint program);
    void glBindProgramPipeline(GLuint pipeline);
    void glDeleteProgramPipelines(GLsizei n, const GLuint* pipelines);

    // Buffers
    void glVertexArrayVertexBuffer(GLuint vaobj, GLuint bindingindex, GLuint buffer, GLintptr offset, GLsizei stride);
    void glVertexArrayElementBuffer(GLuint vaobj, GLuint buffer);
    void glEnableVertexArrayAttrib(GLuint vaobj, GLuint attribindex);
    void glVertexArrayAttribFormat(GLuint vaobj, GLuint attribindex, GLint size, GLenum type, unsigned char normalized, GLuint relativeoffset);
    void glVertexArrayAttribBinding(GLuint vaobj, GLuint attribindex, GLuint bindingindex);
    void glBindVertexArray(GLuint array);

    void glCreateBuffers(GLsizei n, GLuint* buffers);
    void glNamedBufferData(GLuint buffer, GLsizeiptr size, const void* data, GLenum usage);
    void glNamedBufferSubData(GLuint buffer, GLintptr offset, GLsizeiptr size, const void* data);
]]

local C = ffi.load("GL")

return {
    INVALID_VALUE = 0x0501,
    INVALID_OPERATION = 0x0502,

    COLOR_BUFFER_BIT = 0x4000,
    DEPTH_BUFFER_BIT = 0x0100,

    STATIC_DRAW = 0x88E4,

    VERTEX_SHADER_BIT = 0x00000001,
    FRAGMENT_SHADER_BIT = 0x00000002,

    --- @enum ShaderType
    ShaderType = {
        VERTEX = 0x8B31,
        FRAGMENT = 0x8B30,
    },

    --- @param type ShaderType
    --- @param src string
    --- @return number
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

    ---@type fun(x: number, y: number, width: number, height: number)
    viewport = C.glViewport,

    -- ---@type fun(n: number, pipelines: userdata)
    -- genProgramPipelines = C.glGenProgramPipelines,

    ---@param n number
    ---@return number[]
    genProgramPipelines = function(n)
        local handle = ffi.new("GLuint[?]", n)
        C.glGenProgramPipelines(n, handle)

        local pipelineIds = {}
        for i = 0, n - 1 do
            pipelineIds[i + 1] = handle[i]
        end

        return pipelineIds
    end,

    ---@type fun(pipeline: number, stages: number, program: number)
    useProgramStages = C.glUseProgramStages,

    ---@type fun(pipeline: number)
    bindProgramPipeline = C.glBindProgramPipeline,

    ---@type fun(program: number)
    deleteProgram = C.glDeleteProgram,

    ---@type fun(n: number, pipelines: userdata)
    deleteProgramPipelines = C.glDeleteProgramPipelines,

    ---@type fun(n: number, buffers: userdata)
    createBuffers = C.glCreateBuffers,

    ---@type fun(buffer: number, size: number, data: userdata?, usage: number)
    namedBufferData = C.glNamedBufferData,

    ---@type fun(buffer: number, offset: number, size: number, data: userdata)
    namedBufferSubData = C.glNamedBufferSubData,
}
