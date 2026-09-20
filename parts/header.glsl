#version 300 es
precision highp float;

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;

uniform sampler2D tex;
uniform float time;
uniform vec2 fullSize;
uniform vec2 pointer_position;
uniform float pointer_last_active;
uniform int pointer_hidden;
uniform vec2 pointer_pressed_positions[32];
uniform float pointer_pressed_times[32];

float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

float hash22(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

vec2 hash2(vec2 p) {
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453123);
}
