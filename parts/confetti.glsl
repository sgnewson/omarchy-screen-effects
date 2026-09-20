vec3 confettiColor(float seed) {
    float h = hash(seed);
    if (h < 0.2) return vec3(1.00, 0.28, 0.38);
    if (h < 0.4) return vec3(1.00, 0.82, 0.18);
    if (h < 0.6) return vec3(0.28, 0.78, 1.00);
    if (h < 0.8) return vec3(0.45, 0.95, 0.42);
    return vec3(0.92, 0.38, 0.95);
}

float confettiFlake(vec2 uv, vec2 pos, float ang, vec2 size) {
    vec2 p = uv - pos;
    float c = cos(ang);
    float s = sin(ang);
    p = vec2(c * p.x - s * p.y, s * p.x + c * p.y);
    vec2 d = abs(p) - size;
    return 1.0 - smoothstep(0.0, 0.002, max(d.x, d.y));
}

vec4 effect_confetti(vec4 pix) {
    bool live = pointer_hidden != 0 || pointer_last_active < 0.08;
    float fade = max(1.0 - smoothstep(0.9, 1.7, pointer_last_active), live ? 1.0 : 0.0);
    if (fade < 0.01) {
        return pix;
    }

    float aspect = fullSize.x / max(fullSize.y, 1.0);
    vec2 uv = vec2(v_texcoord.x * aspect, v_texcoord.y);
    vec3 acc = vec3(0.0);

    for (int i = 0; i < 22; i++) {
        float id = float(i) + 1.0;
        float life = 2.4 + hash(id) * 1.8;
        float timed = time / life + hash(id * 6.3);
        float t = fract(timed);
        if (!live && t * life < pointer_last_active) {
            continue;
        }
        float seed = id + floor(timed) * 17.0;
        float x = (hash(seed) * 1.05 - 0.02) * aspect + sin(t * 8.0 + seed) * 0.03 * aspect;
        float y = -0.05 + t * 1.15;
        float ang = t * (6.0 + hash(seed + 2.0) * 8.0) + seed;
        vec2 sz = vec2(0.010, 0.0045) * (0.7 + hash(seed + 4.0));
        acc += confettiColor(seed) * confettiFlake(uv, vec2(x, y), ang, sz);
    }

    for (int k = 0; k < 6; k++) {
        float age = pointer_pressed_times[k];
        if (age <= 0.0 || age >= 1.1) {
            continue;
        }
        vec2 center = vec2(pointer_pressed_positions[k].x * aspect, pointer_pressed_positions[k].y);
        for (int j = 0; j < 8; j++) {
            float p = float(j);
            float ang0 = hash(p + 4.0 + float(k)) * 6.28318;
            vec2 pos = center + vec2(cos(ang0), sin(ang0) + 0.9 * age) * (0.04 + age * 0.18);
            acc += confettiColor(p + 20.0 + float(k)) * confettiFlake(uv, pos, age * 10.0 + p, vec2(0.009, 0.004)) * (1.0 - age);
        }
    }

    pix.rgb += acc * fade * 0.55;
    return pix;
}
