#version 430 core

#define MAX_WIDTH 1024
#define MAX_HEIGHT 1024

layout(binding = 0) uniform sampler2DArray uTextureArray;
layout(std430, binding = 1) readonly buffer TextureUVs {
    vec2 textureUVScale[];
};

in vec4 vertexColor;
in vec2 texCoord;
flat in int texIndex;

out vec4 fragColor;

void main() {
    vec4 texColor = texture(uTextureArray, vec3(texCoord * textureUVScale[texIndex], texIndex));
    fragColor = texColor * vertexColor;
}
