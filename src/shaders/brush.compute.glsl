#version 430 core

layout(local_size_x = 16, local_size_y = 16) in;

layout(rgba8, binding = 0) uniform image2DArray imgOutput;

layout(location = 0) uniform ivec2 center;
layout(location = 1) uniform float radius;
layout(location = 2) uniform int writeLayer;
layout(location = 3) uniform vec4 color;

// 0 - Brush
// 1 - Eraser
// 2 - Fill
layout(location = 4) uniform int tool;

layout(location = 5) uniform int readLayer;

float colorDistance(vec3 color1, vec3 color2) {
    vec3 diff = color1 - color2;
    return length(diff); // Euclidean distance
}

void main() {
    ivec2 pixelCoords;

    if (tool == 2) {
        // Fill uses direct coordinates
        pixelCoords = ivec2(gl_GlobalInvocationID.xy);
    } else {
        // Brush/eraser use radius-based coords
        ivec2 localCoords = ivec2(gl_GlobalInvocationID.xy);
        pixelCoords = center + localCoords - ivec2(radius);

        float dist = distance(vec2(localCoords), vec2(radius));
        if (dist > radius) return;
    }

    if (tool == 0) {
        imageStore(imgOutput, ivec3(pixelCoords, writeLayer), color);
    } else if (tool == 1) {
        imageStore(imgOutput, ivec3(pixelCoords, writeLayer), vec4(0.0, 0.0, 0.0, 0.0));
    } else if (tool == 2) {
        // At the origin - mark as filled
        if (center == pixelCoords) {
            vec4 fillColor = color;
            fillColor.a = 1.0; // Mark as filled
            imageStore(imgOutput, ivec3(pixelCoords, writeLayer), fillColor);
        } else {
            vec4 targetColor = imageLoad(imgOutput, ivec3(center, readLayer));
            vec4 currentColor = imageLoad(imgOutput, ivec3(pixelCoords, readLayer));

            // Check if any neighbor is filled (alpha == 1)
            vec4 north = imageLoad(imgOutput, ivec3(pixelCoords + ivec2(0, 1), readLayer));
            vec4 south = imageLoad(imgOutput, ivec3(pixelCoords + ivec2(0, -1), readLayer));
            vec4 east = imageLoad(imgOutput, ivec3(pixelCoords + ivec2(1, 0), readLayer));
            vec4 west = imageLoad(imgOutput, ivec3(pixelCoords + ivec2(-1, 0), readLayer));

            bool neighborFilled = (north.a == 1.0) || (south.a == 1.0) ||
                    (east.a == 1.0) || (west.a == 1.0);

            if (neighborFilled && colorDistance(currentColor.rgb, targetColor.rgb) < 0.9) {
                vec4 fillColor = color;
                fillColor.a = 1.0;
                imageStore(imgOutput, ivec3(pixelCoords, writeLayer), fillColor);
            }
        }
    }
}
