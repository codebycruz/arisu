#version 430 core

layout(local_size_x = 16, local_size_y = 16) in;

layout(rgba8, binding = 0) uniform image2DArray imgOutput;

layout(location = 0) uniform ivec2 center;
layout(location = 1) uniform float radius;
layout(location = 2) uniform int layer;
layout(location = 3) uniform vec4 color;

// 0 - Brush
// 1 - Eraser
layout(location = 4) uniform int tool;

void main() {
    ivec2 localCoords = ivec2(gl_GlobalInvocationID.xy);
    ivec2 pixelCoords = center + localCoords - ivec2(radius);

    float dist = distance(vec2(localCoords), vec2(radius));
    if (dist > radius) return;

    if (tool == 0) {
        imageStore(imgOutput, ivec3(pixelCoords, layer), color);
    } else if (tool == 1) {
        imageStore(imgOutput, ivec3(pixelCoords, layer), vec4(0.0, 0.0, 0.0, 0.0));
    }
}
