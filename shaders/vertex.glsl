#version 460 core

uniform float window_height;
uniform vec2 res_multi;

out vec4 colour;

void main() {
    const float x = 5.0 * res_multi.x;
    const float y = 5.0 * res_multi.y;
    colour = vec4(x, y, 0.75, 1.0) * window_height;
}