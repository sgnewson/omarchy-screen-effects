vec4 effect_meteors(vec4 pix) {
    bool live = pointer_hidden != 0 || pointer_last_active < 0.08;
    float fade = max(1.0 - smoothstep(0.9, 1.8, pointer_last_active), live ? 1.0 : 0.0);
    if (fade < 0.01) {
        return pix;
    }

    float aspect = fullSize.x / max(fullSize.y, 1.0);
    vec2 uv = vec2(v_texcoord.x * aspect, v_texcoord.y);
    vec3 acc = vec3(0.0);

    for (int i = 0; i < 4; i++) {
        float id = float(i) + 1.0;
        float rate = 0.11 + hash(id) * 0.05;
        float timed = time * rate + hash(id * 8.2);
        float cycle = fract(timed);
        // Brief streak, then a long gap until the next one.
        if (cycle > 0.16) {
            continue;
        }
        float timeInto = cycle / rate;
        if (!live && timeInto < pointer_last_active) {
            continue;
        }

        float launch = floor(timed);
        float seed = id * 11.0 + launch * 29.3;
        if (hash(seed + 8.0) > 0.88) {
            continue;
        }
        float streak = cycle / 0.16;
        vec2 start = vec2((0.05 + hash(seed) * 1.15) * aspect, -0.05 + hash(seed + 1.0) * 0.45);
        vec2 dir = normalize(vec2(-0.55 - hash(seed + 2.0) * 0.35, 0.75 + hash(seed + 3.0) * 0.25));
        float dist = 1.35 * streak;
        vec2 head = start + dir * dist;

        for (int k = 0; k < 10; k++) {
            float kt = float(k) / 9.0;
            vec2 p = head - dir * kt * 0.22;
            float d = length(uv - p);
            float sz = mix(0.007, 0.001, kt);
            float tail = (1.0 - kt) * (1.0 - streak);
            acc += vec3(0.85, 0.93, 1.00) * smoothstep(sz, 0.0, d) * tail;
            acc += vec3(1.00, 0.78, 0.45) * smoothstep(sz * 0.45, 0.0, d) * tail * (1.0 - kt);
        }
    }

    pix.rgb += acc * fade;
    return pix;
}
