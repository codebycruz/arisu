local alsa = require "src.bindings.alsa"
local ffi = require "ffi"

local Audio = require "src.audio"

---@class Playback
---@field started number
---@field audio Audio

---@class SoundManager
---@field pcms table<alsa.PCM, Playback>
local SoundManager = {}
SoundManager.__index = SoundManager

function SoundManager.new()
    return setmetatable({
        pcms = {}
    }, SoundManager)
end

--- Removes unused pcms
---@param force boolean? # If true, remove even those still playing
function SoundManager:clean(force)
    local now = os.time()

    for pcm, playback in pairs(self.pcms) do
        local elapsed = now - playback.started
        if force or elapsed >= playback.audio.duration then
            alsa.pcmClose(pcm)
            self.pcms[pcm] = nil
        end
    end
end

---@param audio Audio
function SoundManager:play(audio)
    self:clean()

    local pcm, err = alsa.pcmOpen("default", 0, 1)
    if not pcm then
        error("Error opening PCM device: " .. err)
    end

    local ok, err = alsa.pcmSetParams(
        pcm,
        alsa.SND_PCM_FORMAT_S16_LE,
        alsa.SND_PCM_ACCESS_RW_INTERLEAVED,
        audio.channels,
        audio.sampleRate,
        alsa.SOFT_RESAMPLE,
        500000 -- latency in us
    )

    if not ok then
        alsa.pcmClose(pcm)
        error("Error setting PCM parameters: " .. err)
    end

    local frames = audio.dataLen / (audio.channels * (audio.bitsPerSample / 8))

    -- Copy string data to a proper buffer
    local buffer = ffi.new("int16_t[?]", frames * audio.channels)
    ffi.copy(buffer, audio.data, audio.dataLen)

    ok, err = alsa.pcmWritei(pcm, buffer, frames)
    if not ok then
        alsa.pcmClose(pcm)
        error("Error writing to PCM device: " .. err)
    end

    self.pcms[pcm] = {
        started = os.time(),
        audio = audio
    }
end

return SoundManager
