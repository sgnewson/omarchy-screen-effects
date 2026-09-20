vec4 effect_bokeh(vec4 pix) {
    float fade = max(1.0 - smoothstep(1.6, 2.8, pointer_last_active),
                     pointer_hidden != 0 ? 1.0 : 0.0);
    float intro = smoothstep(0.0, 10.0, time);
    float gain = fade * intro;
    if (gain < 0.01) {
        return pix;
    }

    float aspect = fullSize.x / max(fullSize.y, 1.0);
    vec2 uv = vec2(v_texcoord.x * aspect, v_texcoord.y);
    vec3 acc = vec3(0.0);
    float luma = dot(pix.rgb, vec3(0.299, 0.587, 0.114));

    for (int i = 0; i < 8; i++) {
        float id = float(i) + 1.0;
        vec2 home = vec2((0.08 + hash(id) * 0.84) * aspect, 0.10 + hash(id + 2.0) * 0.80);
        vec2 pos = home;
        pos.x += sin(time * 0.04 + id) * 0.05 * aspect;
        pos.y += cos(time * 0.03 + id * 1.3) * 0.04;
        float r = 0.05 + hash(id + 4.0) * 0.08;
        float d = length(uv - pos) / r;
        float orb = smoothstep(1.0, 0.55, d) * 0.07;
        orb += smoothstep(0.35, 0.0, d) * 0.02;
        vec3 col = mix(vec3(1.00, 0.72, 0.85), vec3(0.55, 0.82, 1.00), hash(id + 6.0));
        col = mix(col, vec3(1.00, 0.92, 0.55), hash(id + 8.0) * 0.5);
        acc += col * orb;
    }

    pix.rgb += acc * gain * mix(0.35, 0.12, luma);
    return pix;
}
