#version 460 core

#extension GL_ARB_bindless_texture : require

in vec4 colour;
in vec2 tex_coords;
in flat uint material;

layout (std140) uniform TEXTURE_BLOCK {
    sampler2D textures[128];
};

out vec4 out_colour;

float rand(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123);
}

void main() {
    const float r = rand(gl_FragCoord.xy) * 0.015;
    const vec4 sampled = vec4(1.0, 1.0, 1.0, texture(textures[0], tex_coords).r);

    if (material == 0) {
        out_colour = colour;
    } else if (material == 1) {
        out_colour = vec4(colour.xyz - r * 1.25, colour.w);
    } else {
        out_colour = colour * sampled;
    }
}