#version 460 core

#extension GL_ARB_bindless_texture : require

in vec4 colour;
out vec4 fb_colour;

void main() {
    fb_colour = colour;
}