#version 460 core

#extension GL_ARB_bindless_texture : require

in vec4 colour;
in vec2 tex_coords;
in flat uint is_text;

layout (early_fragment_tests) in;
layout (pixel_center_integer, origin_upper_left) in vec4 gl_FragCoord;

// using this causes a segfault atm
layout (std140) uniform TEXTURE_BLOCK {
    sampler2D textures[128];
};

out vec4 out_colour;

float rand(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123);
}

void main() {
    const float r = rand(gl_FragCoord.xy) * 0.0125;
    const vec4 sampled = vec4(1.0, 1.0, 1.0, texture(textures[0], tex_coords).r);

    // using this causes a segfault atm
    // out_colour = is_text == 1 ? (colour * sampled) : is_text == 2 ? texture(textures[1], tex_coords) : colour - r;
    out_colour = vec4(0.3, 0.1, 0.3, 1.0);
}