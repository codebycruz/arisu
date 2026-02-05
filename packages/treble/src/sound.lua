local util = require("arisu-util")

---@class Sound
---@field play fun(audio: Audio, volume?: number): Sound
local Sound = (
	util.isLinux() and require("apl.raw.alsa")
	or error("Unsupported OS for audio")
) --[[@as Sound]]
