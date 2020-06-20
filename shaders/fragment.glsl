#version 460 core

in vec4 colour;
out vec4 fb_colour;

void main() {
    fb_colour = colour;
}