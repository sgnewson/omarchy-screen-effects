vec4 effect_embers(vec4 pix) {
    bool live = pointer_hidden != 0 || pointer_last_active < 0.08;
    float fade = max(1.0 - smoothstep(0.8, 1.6, pointer_last_active), live ? 1.0 : 0.0);
    if (fade < 0.01) {
        return pix;
    }

    float aspect = fullSize.x / max(fullSize.y, 1.0);
    vec2 uv = vec2(v_texcoord.x * aspect, v_texcoord.y);
    vec3 acc = vec3(0.0);

    for (int i = 0; i < 28; i++) {
        float id = float(i) + 1.0;
        float life = 2.2 + hash(id) * 2.4;
        // Enter from the bottom; skip until this ember's delayed start.
        float risen = time / life - hash(id * 4.1) * 1.6;
        if (risen < 0.0) {
            continue;
        }
        float launch = floor(risen);
        float t = fract(risen);
        if (!live && t * life < pointer_last_active) {
            continue;
        }

        float seed = id + launch * 19.7;
        float x = (0.03 + hash(seed) * 0.94) * aspect + sin(t * 6.2 + seed) * 0.04 * aspect;
        float y = 1.02 - t * (0.45 + hash(seed + 2.0) * 0.55);
        float d = length(uv - vec2(x, y));
        float sz = mix(0.010, 0.0025, t);
        float glow = smoothstep(sz * 3.2, 0.0, d);
        float core = smoothstep(sz, 0.0, d);
        float age = 1.0 - smoothstep(0.65, 1.0, t);
        vec3 col = mix(vec3(1.00, 0.42, 0.10), vec3(1.00, 0.82, 0.28), hash(seed + 5.0));
        acc += col * (glow * 0.35 + core) * age;
    }

    pix.rgb += acc * fade * 0.85;
    return pix;
}
