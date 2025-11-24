#version 430 core

layout(location = 0) uniform sampler2DArray uTextureArray;

in vec4 vertexColor;
in vec2 texCoord;
flat in int texIndex;

out vec4 fragColor;

void main() {
    // fragColor = vertexColor;
    vec4 texColor = texture(uTextureArray, vec3(texCoord, texIndex));
    fragColor = vertexColor * texColor;
}
