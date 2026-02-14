#version 450

layout(set = 0, binding = 0) uniform sampler2DArray uTextureArray;
layout(set = 0, binding = 1, std430) readonly buffer TextureUVs {
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
