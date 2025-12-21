#version 430 core

#define MAX_LAYERS 256
#define MAX_WIDTH 1024
#define MAX_HEIGHT 1024

layout(binding = 0) uniform sampler2DArray uTextureArray;
layout(std140, binding = 1) uniform TextureDims {
    uvec2 textureDims[MAX_LAYERS];
};

in vec4 vertexColor;
in vec2 texCoord;
flat in int texIndex;

out vec4 fragColor;

void main() {
    vec2 uvScale = vec2(textureDims[texIndex]) / vec2(MAX_WIDTH, MAX_HEIGHT);
    vec4 texColor = texture(uTextureArray, vec3(texCoord * uvScale, texIndex));
    fragColor = texColor * vertexColor;
}
