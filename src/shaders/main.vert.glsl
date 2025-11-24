#version 430 core

#define MAX_LAYERS 256

layout(location = 0) uniform sampler2DArray uTextureArray;

layout(std140, binding = 0) uniform TextureDims {
    vec2 dims[MAX_LAYERS];
};

layout(location = 0) in vec2 aPos;
layout(location = 1) in vec4 aColor;
layout(location = 2) in vec2 aTexCoord;
layout(location = 3) in int aTexIndex;

out vec4 vertexColor;
out vec2 texCoord;
flat out int texIndex;

void main() {
    gl_Position = vec4(aPos, 0.0, 1.0);
    vertexColor = aColor;
    texCoord = aTexCoord;
    texIndex = aTexIndex;
}
