vec4 effect_fireflies(vec4 pix) {
    float fade = max(1.0 - smoothstep(1.2, 2.2, pointer_last_active),
                     pointer_hidden != 0 ? 1.0 : 0.0);
    if (fade < 0.01) {
        return pix;
    }

    float aspect = fullSize.x / max(fullSize.y, 1.0);
    vec2 uv = vec2(v_texcoord.x * aspect, v_texcoord.y);
    vec3 acc = vec3(0.0);

    for (int i = 0; i < 18; i++) {
        float id = float(i) + 1.0;
        vec2 home = vec2((0.06 + hash(id) * 0.88) * aspect, 0.08 + hash(id + 3.0) * 0.84);
        vec2 pos = home;
        pos.x += sin(time * (0.35 + hash(id + 5.0) * 0.45) + id) * 0.07 * aspect;
        pos.y += cos(time * (0.28 + hash(id + 7.0) * 0.40) + id * 1.7) * 0.06;
        float pulse = pow(0.5 + 0.5 * sin(time * (1.6 + hash(id + 9.0) * 2.2) + id * 4.0), 8.0);
        pulse = mix(0.08, 1.0, pulse);
        float d = length(uv - pos);
        acc += vec3(0.72, 1.00, 0.38) * smoothstep(0.018, 0.0, d) * pulse * 0.55;
        acc += vec3(1.00, 0.95, 0.45) * smoothstep(0.0055, 0.0, d) * pulse;
    }

    pix.rgb += acc * fade;
    return pix;
}
