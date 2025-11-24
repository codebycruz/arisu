local gl = require "src.bindings.gl"
local ffi = require("ffi")

--- @class Pipeline
--- @field id number
--- @field stages table<ShaderType, Program>
local Pipeline = {}
Pipeline.__index = Pipeline

function Pipeline.new()
    local pipeline = gl.genProgramPipelines(1)[1]
    return setmetatable({ id = pipeline, stages = {} }, Pipeline)
end

function Pipeline:setProgram(stage --[[@param stage ShaderType]], program --[[@param program Program]])
    self.stages[stage] = program
    gl.useProgramStages(self.id, stage, program.id)
end

function Pipeline:bind()
    gl.bindProgramPipeline(self.id)
end

function Pipeline:destroy()
    for _, program in pairs(self.stages) do
        program:destroy()
    end

    gl.deleteProgramPipelines(1, ffi.new("GLuint[1]", self.id))
end

return Pipeline
