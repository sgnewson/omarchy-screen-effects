vec3 fireworkColor(float id) {
    float h = hash(id * 3.17);
    if (h < 0.20) return vec3(1.00, 0.28, 0.18);
    if (h < 0.40) return vec3(1.00, 0.84, 0.28);
    if (h < 0.60) return vec3(0.35, 0.88, 1.00);
    if (h < 0.80) return vec3(0.98, 0.38, 0.92);
    return vec3(0.48, 1.00, 0.42);
}

float fw_blob(vec2 uv, vec2 pos, float size) {
    return smoothstep(size, 0.0, length(uv - pos));
}

void fw_burst(inout vec3 acc, vec2 uv, vec2 center, float t, vec3 color, float seed) {
    if (t <= 0.0 || t >= 1.0) {
        return;
    }
    float fade = pow(1.0 - t, 1.45);
    acc += color * fw_blob(uv, center, mix(0.035, 0.008, t)) * fade * 0.55;
    acc += vec3(1.0, 0.95, 0.85) * fw_blob(uv, center, mix(0.012, 0.002, t)) * fade;
    for (int j = 0; j < 16; j++) {
        float p = float(j);
        float ang = (p / 16.0) * 6.2831853 + hash(seed + p) * 0.35;
        float spd = 0.10 + hash(seed * 5.1 + p) * 0.16;
        vec2 dir = vec2(cos(ang), sin(ang));
        vec2 pos = center + dir * spd * t + vec2(0.0, 0.16 * t * t);
        float sz = mix(0.0075, 0.0018, t);
        acc += color * fw_blob(uv, pos, sz) * fade * 1.9;
        acc += color * fw_blob(uv, pos, sz * 2.4) * fade * 0.25;
    }
}

vec4 effect_fireworks(vec4 pix) {
    vec3 fw = vec3(0.0);
    float aspect = fullSize.x / max(fullSize.y, 1.0);
    vec2 uv = vec2(v_texcoord.x * aspect, v_texcoord.y);
    bool moving = pointer_hidden != 0 || pointer_last_active < 0.05;

    for (int i = 0; i < 8; i++) {
        float id = float(i) + 1.0;
        float rate = 0.15 + hash(id * 2.7) * 0.12;
        float phase = hash(id * 9.1);
        float timed = time * rate + phase;
        float cycle = fract(timed);
        float timeIntoCycle = cycle / rate;
        if (!moving && timeIntoCycle < pointer_last_active) {
            continue;
        }

        float launch = floor(timed);
        float seed = id * 13.0 + launch * 47.1;
        vec2 origin = vec2((0.04 + hash(seed) * 0.92) * aspect, 0.96 + hash(seed + 1.0) * 0.04);
        vec2 peak = vec2((0.06 + hash(seed + 3.0) * 0.88) * aspect, 0.08 + hash(seed + 5.0) * 0.78);
        vec3 col = fireworkColor(seed);

        if (cycle < 0.26) {
            float rt = cycle / 0.26;
            vec2 pos = mix(origin, peak, rt);
            fw += col * fw_blob(uv, pos, 0.0045) * rt;
            fw += col * fw_blob(uv, mix(origin, peak, max(rt - 0.06, 0.0)), 0.007) * 0.35 * rt;
        } else {
            fw_burst(fw, uv, peak, (cycle - 0.26) / 0.74, col, seed);
        }
    }

    for (int k = 0; k < 8; k++) {
        float age = pointer_pressed_times[k];
        if (age <= 0.0 || age >= 1.35) {
            continue;
        }
        vec2 press = pointer_pressed_positions[k];
        vec2 center = vec2(press.x * aspect, press.y);
        fw_burst(fw, uv, center, age / 1.35, fireworkColor(20.0 + float(k)), 20.0 + float(k));
    }

    pix.rgb += fw * 0.95;
    return pix;
}
