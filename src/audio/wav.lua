local ffi = require "ffi"

ffi.cdef [[
    typedef struct {
        char riff[4];
        uint32_t size;
        char wave[4];
        char fmt[4];
        uint32_t fmt_size;
        uint16_t audio_format;
        uint16_t num_channels;
        uint32_t sample_rate;
        uint32_t byte_rate;
        uint16_t block_align;
        uint16_t bits_per_sample;
    } wav_header_t;
]]

local WAV = {}

---@return { channels: number, sampleRate: number, bitsPerSample: number, data: userdata, dataLen: number, buffer: string }
function WAV.Decode(
	content --[[@param content string]]
)
	local header = ffi.cast("const wav_header_t*", content)
	local channels = tonumber(header.num_channels)
	local sampleRate = tonumber(header.sample_rate)
	local bitsPerSample = tonumber(header.bits_per_sample)

	-- Search for the "data" chunk
	local dataOffset = nil
	local dataSize = nil
	local pos = 12 -- Skip "RIFF" + size + "WAVE"

	while pos < #content - 8 do
		local chunkId = string.sub(content, pos + 1, pos + 4)
		local chunkSize = ffi.cast("const uint32_t*", string.sub(content, pos + 5, pos + 8))[0]

		if chunkId == "data" then
			dataOffset = pos + 8
			dataSize = tonumber(chunkSize)
			break
		end

		pos = pos + 8 + chunkSize
	end

	assert(dataOffset, "Data chunk not found in WAV file")
	local rawData = string.sub(content, dataOffset + 1, dataOffset + dataSize)

	return {
		channels = channels,
		sampleRate = sampleRate,
		bitsPerSample = bitsPerSample,
		data = rawData,
		dataLen = dataSize,
		buffer = content,
	}
end

function WAV.isValid(
	content --[[@param content string]]
)
	return string.sub(content, 1, 4) == "RIFF" and string.sub(content, 9, 12) == "WAVE"
end

return WAV
