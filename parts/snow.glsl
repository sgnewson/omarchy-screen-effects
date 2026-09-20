vec4 effect_snow(vec4 pix) {
    float fade = max(1.0 - smoothstep(1.0, 1.8, pointer_last_active),
                     pointer_hidden != 0 ? 1.0 : 0.0);
    if (fade < 0.01) {
        return pix;
    }

    float aspect = fullSize.x / max(fullSize.y, 1.0);
    vec2 uv = vec2(v_texcoord.x * aspect, v_texcoord.y);
    vec3 acc = vec3(0.0);

    for (int i = 0; i < 36; i++) {
        float id = float(i) + 1.0;
        float speed = 0.08 + hash(id) * 0.14;
        float x = fract(hash(id) + time * 0.02 * (hash(id + 1.0) - 0.5)) * aspect;
        // Enter from the top; skip until this flake's delayed start.
        float fallen = time * speed - hash(id + 2.0) * 1.8;
        if (fallen < 0.0) {
            continue;
        }
        float y = fract(fallen);
        float d = length(uv - vec2(x, y));
        float sz = (i < 12) ? 0.0075 : 0.0032;
        sz *= 0.7 + hash(id + 4.0) * 0.8;
        float flake = smoothstep(sz, 0.0, d);
        if (i < 12) {
            flake += 0.35 * smoothstep(sz * 2.8, 0.0, d);
        }
        acc += vec3(0.92, 0.96, 1.00) * flake;
    }

    pix.rgb += acc * fade * 0.85;
    return pix;
}
