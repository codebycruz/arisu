local alsa = require "src.bindings.alsa"

local WAV = require "src.audio.wav"

---@class Audio
---@field channels number
---@field sampleRate number
---@field bitsPerSample number
---@field data string
---@field dataLen number
---@field buffer string
local Audio = {}
Audio.__index = Audio

---@param channels number
---@param sampleRate number
---@param bitsPerSample number
---@param data string
---@param dataLen number
---@param buffer string
function Audio.new(channels, sampleRate, bitsPerSample, data, dataLen, buffer)
    return setmetatable({
        channels = channels,
        sampleRate = sampleRate,
        bitsPerSample = bitsPerSample,
        data = data,
        dataLen = dataLen,
        buffer = buffer
    }, Audio)
end

---@param content string
---@return Audio?
function Audio.fromData(content)
    if WAV.isValid(content) then
        local wavData = WAV.Decode(content)
        return Audio.new(wavData.channels, wavData.sampleRate, wavData.bitsPerSample, wavData.data, wavData.dataLen, wavData.buffer)
    end

    return nil, "Unsupported audio format"
end

function Audio.isValid(content)
    return WAV.isValid(content)
end

---@param path string
---@return Audio?
function Audio.fromPath(path)
    local file, err = io.open(path, "rb")
    if not file then
        return nil, "Failed to open image file: " .. err
    end

    local content = file:read("*all")
    return Audio.fromData(content)
end

return Audio
