#version 430 core

in vec4 vertexColor;
in vec2 texCoord;

out vec4 fragColor;

// For marching ants
uniform float time;

#define PATTERN_SOLID 0
#define PATTERN_DASHED 1
#define PATTERN_MARCHING_ANTS 2
uniform int patternType;

void main() {
    if (patternType == PATTERN_SOLID) {
        fragColor = vertexColor;
    } else if (patternType == PATTERN_DASHED) {
        float dash = mod(texCoord.x * 10.0, 2.0);
        if (dash > 1.0) discard;
        fragColor = vertexColor;
    }
    else if (patternType == PATTERN_MARCHING_ANTS) {
        float pattern = mod(texCoord.x * 20.0 - time * 5.0, 2.0);
        if (pattern > 1.0) discard;
        fragColor = vertexColor;
    }
}
