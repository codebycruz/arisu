local ffi = require("ffi")

ffi.cdef[[
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
    const char* snd_strerror(int errnum);
]]

local C = ffi.load("asound")

return {
    SND_PCM_FORMAT_S16_LE = 2,
    SND_PCM_ACCESS_RW_INTERLEAVED = 3,

    SOFT_RESAMPLE = 1,

    ---@type fun(pcm: userdata, name: string, stream: number, mode: number): number
    pcmOpen = C.snd_pcm_open,

    ---@type fun(pcm: userdata): number
    pcmClose = C.snd_pcm_close,

    ---@type fun(pcm: userdata, format: number, access: number, channels: number, rate: number, soft_resample: number, latency: number): number
    pcmSetParams = C.snd_pcm_set_params,

    ---@type fun(pcm: userdata, buffer: userdata, size: number): number
    pcmWritei = C.snd_pcm_writei,

    ---@type fun(pcm: userdata): number
    pcmDrain = C.snd_pcm_drain,

    ---@type fun(errnum: number): string
    strError = function(errnum)
        return ffi.string(C.snd_strerror(errnum))
    end
}
