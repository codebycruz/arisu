#version 430 core

layout(local_size_x = 16, local_size_y = 16) in;

layout(rgba8, binding = 0) uniform image2DArray imgOutput;

layout(location = 0) uniform ivec2 center;
layout(location = 1) uniform float radius;
layout(location = 2) uniform float layer;
layout(location = 3) uniform vec4 color;

void main() {
    ivec2 pixelCoords = ivec2(gl_GlobalInvocationID.xy);

    // float dist = distance(vec2(pixelCoords), center);
    // if (dist > radius) return;

    // // Calculate alpha based on distance
    // float alpha = 1.0 - smoothstep(radius * 1, radius, dist);

    // // Read current pixel
    // vec4 current = imageLoad(imgOutput, ivec3(pixelCoords, layer));

    // // Blend
    // vec4 brushColor = vec4(color.rgb, color.a * alpha);
    // vec4 blended = mix(current, brushColor, brushColor.a);

    imageStore(imgOutput, ivec3(pixelCoords, layer), vec4(1.0, 0.0, 0.0, 1.0));
}
