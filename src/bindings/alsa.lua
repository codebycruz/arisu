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

local C = ffi.load("asound")

---@class alsa.PCM : userdata

return {
	SND_PCM_FORMAT_S16_LE = 2,
	SND_PCM_ACCESS_RW_INTERLEAVED = 3,

	SOFT_RESAMPLE = 1,

	EAGAIN = -11,
	EPIPE = -32,

	---@enum alsa.SoundState
	SoundState = {
		OPEN = 0,
		SETUP = 1,
		PREPARED = 2,
		RUNNING = 3,
		XRUN = 4,
		DRAINING = 5,
		PAUSED = 6,
		SUSPENDED = 7,
		DISCONNECTED = 8,
	},

	---@type fun(name: string, stream: number, mode: number): alsa.PCM?, string?
	pcmOpen = function(name, stream, mode)
		local pcm = ffi.new("snd_pcm_t*[1]")

		local err = C.snd_pcm_open(pcm, name, stream, mode)
		if err < 0 then
			return nil, ffi.string(C.snd_strerror(err))
		end

		return pcm[0]
	end,

	---@type fun(pcm: alsa.PCM): number
	pcmClose = C.snd_pcm_close,

	---@type fun(pcm: alsa.PCM, format: number, access: number, channels: number, rate: number, soft_resample: number, latency: number): boolean?, string?
	pcmSetParams = function(pcm, format, access, channels, rate, soft_resample, latency)
		local err = C.snd_pcm_set_params(pcm, format, access, channels, rate, soft_resample, latency)
		if err < 0 then
			return false, ffi.string(C.snd_strerror(err))
		end

		return true
	end,

	---@type fun(pcm: alsa.PCM, buffer: userdata, size: number): boolean, string?
	pcmWritei = function(pcm, buffer, size)
		local err = C.snd_pcm_writei(pcm, buffer, size)
		if err < 0 then
			return false, ffi.string(C.snd_strerror(err))
		end

		return true
	end,

	---@type fun(pcm: alsa.PCM): number
	pcmDrain = C.snd_pcm_drain,

	---@type fun(pcm: alsa.PCM): number
	pcmPrepare = C.snd_pcm_prepare,

	---@type fun(errnum: number): string
	strError = function(errnum)
		return ffi.string(C.snd_strerror(errnum))
	end,

	---@type fun(pcm: alsa.PCM): alsa.SoundState
	pcmState = C.snd_pcm_state,
}
