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
    typedef void* GLsync;

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

    // Pipeline Uniforms
    void glProgramUniform1i(GLuint program, GLint location, GLint v0);
    void glProgramUniform1f(GLuint program, GLint location, GLfloat v0);
    void glProgramUniform2i(GLuint program, GLint location, GLint v0, GLint v1);
    void glProgramUniform2f(GLuint program, GLint location, GLfloat v0, GLfloat v1);
    void glProgramUniform3f(GLuint program, GLint location, GLfloat v0, GLfloat v1, GLfloat v2);
    void glProgramUniform4f(GLuint program, GLint location, GLfloat v0, GLfloat v1, GLfloat v2, GLfloat v3);
    void glProgramUniformMatrix4fv(GLuint program, GLint location, GLsizei count, unsigned char transpose, const GLfloat* value);

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

    // Textures
    void glCreateTextures(GLenum target, GLsizei n, GLuint* textures);
    void glTextureStorage3D(GLuint texture, GLsizei levels, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth);
    void glTextureSubImage3D(GLuint texture, GLsizei level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, const void* pixels);
    void glTextureParameteri(GLuint texture, GLenum pname, GLint param);
    void glBindTextureUnit(GLuint unit, GLuint texture);
    void glDeleteTextures(GLsizei n, const GLuint* textures);
    void glCopyImageSubData(GLuint srcName, GLenum srcTarget, GLint srcLevel, GLint srcX, GLint srcY, GLint srcZ, GLuint dstName, GLenum dstTarget, GLint dstLevel, GLint dstX, GLint dstY, GLint dstZ, GLsizei width, GLsizei height, GLsizei depth);

    // Uniform Buffer Objects
    void glBindBufferBase(GLenum target, GLuint index, GLuint buffer);

    // Compute shaders
    void glDispatchCompute(GLuint num_groups_x, GLuint num_groups_y, GLuint num_groups_z);
    void glMemoryBarrier(unsigned int barriers);
    void glBindImageTexture(GLuint unit, GLuint texture, GLint level, unsigned char layered, GLint layer, GLenum access, GLenum format);

    // Misc
    char* glGetString(GLenum name);
    void glEnable(GLenum cap);
    void glDisable(GLenum cap);
    void glBlendFunc(GLenum sfactor, GLenum dfactor);
    void glFinish();
    void glFlush();
    void glDepthFunc(GLenum func);

    // Fences
    GLsync glFenceSync(GLenum condition, unsigned int flags);
    void glDeleteSync(GLsync sync);
    GLenum glClientWaitSync(GLsync sync, unsigned int flags, uint64_t timeout);
]]

local C = ffi.load("GL")

---@class Fence: userdata

return {
    INVALID_VALUE = 0x0501,
    INVALID_OPERATION = 0x0502,

    COLOR_BUFFER_BIT = 0x4000,
    DEPTH_BUFFER_BIT = 0x0100,

    DEPTH_TEST = 0x0B71,

    STATIC_DRAW = 0x88E4,

    VERTEX_SHADER_BIT = 0x00000001,
    FRAGMENT_SHADER_BIT = 0x00000002,
    COMPUTE_SHADER_BIT = 0x00000020,

    FLOAT = 0x1406,
    UNSIGNED_INT = 0x1405,
    INT = 0x1404,

    TRIANGLES = 0x0004,

    --- @enum ShaderType
    ShaderType = {
        VERTEX = 0x8B31,
        FRAGMENT = 0x8B30,
        COMPUTE = 0x91B9,
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
    SHADER_STORAGE_BUFFER = 0x90D2,

    SHADER_STORAGE_BARRIER_BIT = 0x00002000,
    BUFFER_UPDATE_BARRIER_BIT = 0x00000200,
    ALL_BARRIER_BITS = 0xFFFFFFFF,

    BLEND = 0x0BE2,
    SRC_ALPHA = 0x0302,
    ONE_MINUS_SRC_ALPHA = 0x0303,

    READ_WRITE = 0x88BA,
    SHADER_IMAGE_ACCESS_BARRIER_BIT = 0x00000020,

    SYNC_GPU_COMMANDS_COMPLETE = 0x9117,
    SYNC_FLUSH_COMMANDS_BIT = 0x00000001,

    LESS = 0x0201,
    LESS_EQUAL = 0x0203,
    GREATER = 0x0204,
    GREATER_EQUAL = 0x0206,

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

    ---@type fun(pId: number, uId: number, v0: userdata)
    programUniform1i = C.glProgramUniform1i,

    ---@type fun(pId: number, uId: number, v0: number)
    programUniform1f = C.glProgramUniform1f,

    ---@type fun(pId: number, uId: number, v0: number, v1: number)
    programUniform2i = C.glProgramUniform2i,

    ---@type fun(pId: number, uId: number, v0: number, v1: number)
    programUniform2f = C.glProgramUniform2f,

    ---@type fun(pId: number, uId: number, v0: number, v1: number, v2: number)
    programUniform3f = C.glProgramUniform3f,

    ---@type fun(pId: number, uId: number, v0: number, v1: number, v2: number, v3: number)
    programUniform4f = C.glProgramUniform4f,

    ---@type fun(pId: number, uId: number, count: number, transpose: number, value: userdata)
    programUniformMatrix4fv = C.glProgramUniformMatrix4fv,

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

    ---@type fun(num_groups_x: number, num_groups_y: number, num_groups_z: number)
    dispatchCompute = C.glDispatchCompute,

    ---@type fun(barriers: number)
    memoryBarrier = C.glMemoryBarrier,

    ---@type fun(cap: number)
    enable = C.glEnable,

    ---@type fun(cap: number)
    disable = C.glDisable,

    ---@type fun(sfactor: number, dfactor: number)
    blendFunc = C.glBlendFunc,

    ---@type fun(unit: number, texture: number, level: number, layered: number, layer: number, access: number, format: number)
    bindImageTexture = C.glBindImageTexture,

    ---@type fun()
    finish = C.glFinish,

    ---@type fun()
    flush = C.glFlush,

    ---@type fun(srcName: number, srcTarget: number, srcLevel: number, srcX: number, srcY: number, srcZ: number, dstName: number, dstTarget: number, dstLevel: number, dstX: number, dstY: number, dstZ: number, width: number, height: number, depth: number)
    copyImageSubData = C.glCopyImageSubData,

    ---@type fun(condition: number, flags: number): Fence
    fenceSync = C.glFenceSync,

    ---@type fun(sync: Fence)
    deleteSync = C.glDeleteSync,

    ---@type fun(sync: Fence, flags: number, timeout: number): number
    clientWaitSync = C.glClientWaitSync,

    ---@type fun(func: number)
    depthFunc = C.glDepthFunc,
}
