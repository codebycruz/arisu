local alsa = require "src.bindings.alsa"
local ffi = require "ffi"

local Audio = require "src.audio"

---@class SoundManager
---@field pcms table<Audio, userdata>
local SoundManager = {}
SoundManager.__index = SoundManager

function SoundManager.new()
    return setmetatable({
        pcms = setmetatable({}, { __mode = "k" })
    }, SoundManager)
end

---@param audio Audio
function SoundManager:play(audio)
    local pcm_array = ffi.new("snd_pcm_t*[1]")
    local err = alsa.pcmOpen(pcm_array, "default", 0, 1)
    if err < 0 then
        error("Error opening PCM device: " .. ffi.string(alsa.strError(err)))
    end

    local pcm = pcm_array[0]

    err = alsa.pcmSetParams(
        pcm,
        alsa.SND_PCM_FORMAT_S16_LE,
        alsa.SND_PCM_ACCESS_RW_INTERLEAVED,
        audio.channels,
        audio.sampleRate,
        alsa.SOFT_RESAMPLE,
        500000 -- latency in us
    )

    if err < 0 then
        alsa.pcmClose(pcm)
        error("Error setting PCM parameters: " .. ffi.string(alsa.strError(err)))
    end

    local frames = audio.dataLen / (audio.channels * (audio.bitsPerSample / 8))

    -- Copy string data to a proper buffer
    local buffer = ffi.new("int16_t[?]", frames * audio.channels)
    ffi.copy(buffer, audio.data, audio.dataLen)

    err = alsa.pcmWritei(pcm, buffer, frames)
    if err < 0 then
        alsa.pcmClose(pcm)
        error("Error writing to PCM device: " .. ffi.string(alsa.strError(err)))
    end

    -- alsa.pcmDrain(pcm)
    -- alsa.pcmClose(pcm)
end

return SoundManager
