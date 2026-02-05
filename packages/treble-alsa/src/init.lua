local ffi = require("ffi")

ffi.cdef([[
	typedef void snd_pcm_t;

	int snd_pcm_open(snd_pcm_t **pcm, const char *name, int stream, int mode);
	int snd_pcm_close(snd_pcm_t *pcm);
	int snd_pcm_set_params(
		snd_pcm_t *pcm,
		int format,
		int access,
		unsigned int channels,
		unsigned int rate,
		int soft_resample,
		unsigned int latency
	);
	int snd_pcm_writei(snd_pcm_t *pcm, const void *buffer, unsigned int size);
	int snd_pcm_drain(snd_pcm_t *pcm);
	int snd_pcm_prepare(snd_pcm_t *pcm);
	const char* snd_strerror(int errnum);
	int snd_pcm_state(snd_pcm_t *pcm);
]])

local C = ffi.load("asound.so.2")

---@class alsa.PCM : ffi.cdata*

local alsa = {}

alsa.SND_PCM_FORMAT_S16_LE = 2
alsa.SND_PCM_ACCESS_RW_INTERLEAVED = 3

alsa.SOFT_RESAMPLE = 1

alsa.EAGAIN = -11
alsa.EPIPE = -32

---@enum alsa.SoundState
alsa.SoundState = {
	OPEN = 0,
	SETUP = 1,
	PREPARED = 2,
	RUNNING = 3,
	XRUN = 4,
	DRAINING = 5,
	PAUSED = 6,
	SUSPENDED = 7,
	DISCONNECTED = 8,
}

---@param name string
---@param stream number
---@param mode number
function alsa.pcmOpen(name, stream, mode)
	local pcm = ffi.new("snd_pcm_t*[1]")

	local err = C.snd_pcm_open(pcm, name, stream, mode)
	if err < 0 then
		return nil, ffi.string(C.snd_strerror(err))
	end

	return pcm[0]
end

---@type fun(pcm: alsa.PCM): number
alsa.pcmClose = C.snd_pcm_close

---@param pcm alsa.PCM
---@param format number
---@param access number
---@param channels number
---@param rate number
---@param soft_resample number
---@param latency number
---@return boolean?, string?
function alsa.pcmSetParams(pcm, format, access, channels, rate, soft_resample, latency)
	local err = C.snd_pcm_set_params(pcm, format, access, channels, rate, soft_resample, latency)
	if err < 0 then
		return false, ffi.string(C.snd_strerror(err))
	end

	return true
end

---@param pcm alsa.PCM
---@param buffer userdata
---@param size number
---@return boolean?, string?
function alsa.pcmWritei(pcm, buffer, size)
	local err = C.snd_pcm_writei(pcm, buffer, size)
	if err < 0 then
		return false, ffi.string(C.snd_strerror(err))
	end

	return true
end

---@type fun(pcm: alsa.PCM): number
alsa.pcmDrain = C.snd_pcm_drain

---@type fun(pcm: alsa.PCM): number
alsa.pcmPrepare = C.snd_pcm_prepare

---@param errnum number
function alsa.strError(errnum)
	return ffi.string(C.snd_strerror(errnum))
end

---@type fun(pcm: alsa.PCM): alsa.SoundState
alsa.pcmState = C.snd_pcm_state

return alsa
