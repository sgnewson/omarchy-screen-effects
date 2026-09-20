vec4 effect_heat(vec4 pix) {
    vec2 uv = v_texcoord;
    float loft = pow(clamp(1.0 - uv.y, 0.0, 1.0), 1.45);
    loft *= loft * 0.35 + loft * 0.65;

    float activity = max(1.0 - smoothstep(0.6, 2.0, pointer_last_active),
                         pointer_hidden != 0 ? 1.0 : 0.0);
    float gain = mix(0.22, 1.0, activity);

    float n = sin(uv.y * 42.0 + time * 3.4) * sin(uv.x * 18.0 + time * 1.6);
    n += 0.45 * sin(uv.y * 90.0 - time * 5.0);
    n += 0.25 * sin(uv.x * 55.0 + uv.y * 31.0 + time * 2.2);
    float amp = mix(0.0016, 0.0034, activity);
    vec2 off = vec2(n * amp, n * amp * 0.32) * loft * gain;

    vec4 r = texture(tex, uv + off * vec2(1.15, 1.0));
    vec4 g = texture(tex, uv + off);
    vec4 b = texture(tex, uv - off * vec2(0.85, 1.0));
    return vec4(r.r, g.g, b.b, g.a);
}
