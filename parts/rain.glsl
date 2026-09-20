vec4 effect_rain(vec4 pix) {
    float fade = max(1.0 - smoothstep(0.7, 1.4, pointer_last_active),
                     pointer_hidden != 0 ? 1.0 : 0.0);
    if (fade < 0.01) {
        return pix;
    }

    float aspect = fullSize.x / max(fullSize.y, 1.0);
    vec2 uv = vec2(v_texcoord.x * aspect, v_texcoord.y);
    vec3 acc = vec3(0.0);

    for (int i = 0; i < 30; i++) {
        float id = float(i) + 1.0;
        float speed = 0.55 + hash(id) * 0.55;
        float x = (hash(id) * 0.98 + 0.01) * aspect;
        float y = fract(hash(id + 3.0) + time * speed);
        vec2 p = uv - vec2(x, y);
        float streak = max(0.0, 1.0 - abs(p.x) / 0.0018) * max(0.0, 1.0 - abs(p.y) / 0.045);
        acc += vec3(0.70, 0.82, 1.00) * streak * 0.55;
    }

    for (int j = 0; j < 10; j++) {
        float id = float(j) + 40.0;
        vec2 drop = vec2((0.08 + hash(id) * 0.84) * aspect, 0.12 + hash(id + 2.0) * 0.76);
        drop.y = fract(drop.y + time * 0.03);
        float d = length(uv - drop);
        float glint = smoothstep(0.007, 0.0, d) * (0.4 + 0.6 * abs(sin(time * 3.0 + id)));
        acc += vec3(0.85, 0.92, 1.00) * glint;
    }

    pix.rgb += acc * fade;
    return pix;
}
