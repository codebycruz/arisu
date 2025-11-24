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
    void glCreateVertexArrays(GLsizei n, GLuint* arrays);

    void glCreateBuffers(GLsizei n, GLuint* buffers);
    void glNamedBufferData(GLuint buffer, GLsizeiptr size, const void* data, GLenum usage);
    void glNamedBufferSubData(GLuint buffer, GLintptr offset, GLsizeiptr size, const void* data);

    // Drawing
    void glDrawElements(GLenum mode, GLsizei count, GLenum type, const void* indices);

    // Uniforms
    void glUniform1i(GLint location, GLint v0);
    void glUniform1f(GLint location, GLfloat v0);
    void glUniform2f(GLint location, GLfloat v0, GLfloat v1);
    void glUniform3f(GLint location, GLfloat v0, GLfloat v1, GLfloat v2);
    void glUniform4f(GLint location, GLfloat v0, GLfloat v1, GLfloat v2, GLfloat v3);
    void glUniformMatrix4fv(GLint location, GLsizei count, unsigned char transpose, const GLfloat* value);

    // Textures
    void glCreateTextures(GLenum target, GLsizei n, GLuint* textures);
    void glTextureStorage3D(GLuint texture, GLsizei levels, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth);
    void glTextureSubImage3D(GLuint texture, GLsizei level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, const void* pixels);
    void glTextureParameteri(GLuint texture, GLenum pname, GLint param);
    void glBindTextureUnit(GLuint unit, GLuint texture);
    void glDeleteTextures(GLsizei n, const GLuint* textures);

    // Uniform Buffer Objects
    void glBindBufferBase(GLenum target, GLuint index, GLuint buffer);

    // Misc
    char* glGetString(GLenum name);
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

    FLOAT = 0x1406,
    UNSIGNED_INT = 0x1405,
    INT = 0x1404,

    TRIANGLES = 0x0004,

    --- @enum ShaderType
    ShaderType = {
        VERTEX = 0x8B31,
        FRAGMENT = 0x8B30,
    },

    TEXTURE_2D_ARRAY = 0x8C1A,
    RGBA8 = 0x8058,

    RG = 0x8227,
    RGB = 0x1907,
    RGBA = 0x1908,

    UNSIGNED_BYTE = 0x1401,

    TEXTURE_WRAP_S = 0x2802,
    TEXTURE_WRAP_T = 0x2803,
    CLAMP_TO_EDGE = 0x812F,
    TEXTURE_MIN_FILTER = 0x2801,
    TEXTURE_MAG_FILTER = 0x2800,
    NEAREST = 0x2600,
    REPEAT = 0x2901,
    LINEAR = 0x2601,

    UNIFORM_BUFFER = 0x8A11,

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

    ---@type fun(vaobj: number, bindingindex: number, buffer: number, offset: number, stride: number)
    vertexArrayVertexBuffer = C.glVertexArrayVertexBuffer,
    ---@type fun(vaobj: number, buffer: number)
    vertexArrayElementBuffer = C.glVertexArrayElementBuffer,
    ---@type fun(vaobj: number, attribindex: number)
    enableVertexArrayAttrib = C.glEnableVertexArrayAttrib,
    ---@type fun(vaobj: number, attribindex: number, size: number, type: number, normalized: number, relativeoffset: number)
    vertexArrayAttribFormat = C.glVertexArrayAttribFormat,
    ---@type fun(vaobj: number, attribindex: number, bindingindex: number)
    vertexArrayAttribBinding = C.glVertexArrayAttribBinding,
    ---@type fun(array: number)
    bindVertexArray = C.glBindVertexArray,
    ---@type fun(n: number, arrays: userdata)
    createVertexArrays = C.glCreateVertexArrays,

    ---@type fun(mode: number, count: number, type: number, indices: userdata?)
    drawElements = C.glDrawElements,

    ---@type fun(name: number): string
    getString = function(name)
        local str = C.glGetString(name)
        return ffi.string(str)
    end,

    ---@type fun(location: number, v0: number)
    uniform1i = C.glUniform1i,

    ---@type fun(location: number, v0: number)
    uniform1f = C.glUniform1f,

    ---@type fun(location: number, v0: number, v1: number)
    uniform2f = C.glUniform2f,

    ---@type fun(location: number, v0: number, v1: number, v2: number)
    uniform3f = C.glUniform3f,

    ---@type fun(location: number, v0: number, v1: number, v2: number, v3: number)
    uniform4f = C.glUniform4f,

    ---@type fun(location: number, count: number, transpose: number, value: userdata)
    uniformMatrix4fv = C.glUniformMatrix4fv,

    ---@type fun(target: number, n: number, textures: userdata)
    createTextures = C.glCreateTextures,

    ---@type fun(texture: number, levels: number, internalformat: number, width: number, height: number, depth: number)
    textureStorage3D = C.glTextureStorage3D,

    ---@type fun(texture: number, level: number, xoffset: number, yoffset: number, zoffset: number, width: number, height: number, depth: number, format: number, type: number, pixels: userdata)
    textureSubImage3D = C.glTextureSubImage3D,

    ---@type fun(texture: number, pname: number, param: number)
    textureParameteri = C.glTextureParameteri,

    ---@type fun(unit: number, texture: number)
    bindTextureUnit = C.glBindTextureUnit,

    ---@type fun(n: number, textures: userdata)
    deleteTextures = C.glDeleteTextures,

    ---@type fun(target: number, index: number, buffer: number)
    bindBufferBase = C.glBindBufferBase,
}
