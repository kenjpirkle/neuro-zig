#version 460 core

#extension GL_ARB_bindless_texture : require

layout (location = 0) in float instance_depth;

struct Vertex {
    uvec2 position;
    uint colour_index;
    uint material;
};

layout (std430, binding = 0) buffer VERTEX_BLOCK {
    Vertex vertices[];
};

layout (std430, binding = 1) buffer COLOUR_BLOCK {
    vec4 in_colours[];
};

uniform float window_height;
uniform vec2 res_multi;
uniform vec4 font_tex_coords[128];

out vec4 colour;
out vec2 tex_coords;
out flat uint material;

const uvec2 tex_coord_multi[6] = {
    uvec2(0, 0),
    uvec2(0, 1),
    uvec2(1, 1),
    uvec2(1, 0),
    uvec2(0, 0),
    uvec2(1, 1)
};

void main() {
    const Vertex v = vertices[(gl_InstanceID * 6) + gl_VertexID];
    const float x = v.position.x * res_multi.x - 1.0;
    const float y = (window_height - v.position.y) * res_multi.y - 1.0;
    gl_Position = vec4(x, y, instance_depth, 1);
    colour = in_colours[v.colour_index];
    material = v.material;
    const vec4 c = font_tex_coords[material];
    const uint vert = gl_VertexID % 6;
    tex_coords.x = (c.x + (c.z * tex_coord_multi[vert].x));
    tex_coords.y = (c.y + (c.w * tex_coord_multi[vert].y));
}