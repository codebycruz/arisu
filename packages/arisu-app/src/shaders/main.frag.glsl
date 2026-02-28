#version 450

#ifdef VULKAN
#define BINDING(s, b) layout(set = s, binding = b)
#define BUFFER_BINDING(s, b) layout(set = s, binding = b, std430)
#else
#define BINDING(s, b) layout(binding = b)
#define BUFFER_BINDING(s, b) layout(binding = b, std430)
#endif

BINDING(0, 0)uniform sampler2DArray uTextureArray;
BUFFER_BINDING(0, 1)readonly buffer TextureUVs {
    vec2 textureUVScale[];
};

layout(location = 0) in vec4 vertexColor;
layout(location = 1) in vec2 texCoord;
layout(location = 2) flat in int texIndex;

layout(location = 0) out vec4 fragColor;

void main() {
    vec4 texColor = texture(uTextureArray, vec3(texCoord * textureUVScale[texIndex], texIndex));
    fragColor = texColor * vertexColor;
}
