local ffi = require("ffi")

---@class Sound
---@field play fun(audio: Audio, volume?: number): Sound
local Sound = (
	ffi.os == "Linux" and require("apl.raw.alsa")
	or error("Unsupported OS for audio")
) --[[@as Sound]]
