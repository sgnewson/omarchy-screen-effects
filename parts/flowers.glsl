const float LAYOUT_SEED = 1.0;
const float DECAY_SECS = 12.0;

float hseed(float n) {
    return hash(n + LAYOUT_SEED * 17.13);
}

float grown(float t) {
    return 1.0 - exp(-max(t, 0.0) / 22.0);
}

float coverage() {
    bool live = pointer_hidden != 0 || pointer_last_active < 0.12;
    if (live) {
        return grown(time);
    }
    float frozen = grown(time - pointer_last_active);
    float melt = 1.0 - smoothstep(0.5, DECAY_SECS, pointer_last_active);
    return frozen * melt;
}

mat2 rot(float a) {
    float c = cos(a);
    float s = sin(a);
    return mat2(c, -s, s, c);
}

float vineX(float t, float id, float aspect) {
    float sway = sin(time * 0.35 + id * 1.7) * 0.01;
    float base = fract(hseed(id) + hseed(id * 3.71) * 0.37);
    return (0.02 + base * 0.96) * aspect
        + sin(t * (3.2 + hseed(id + 2.0) * 2.4) + id * 2.1) * 0.055 * t * aspect
        + sin(t * 8.0 + time * 0.45 + id) * 0.012 * t * aspect
        + sway * t * aspect;
}

void flower(inout vec3 col, inout float alpha, vec2 uv, vec2 center, float size, float seed) {
    vec2 p = (uv - center) / size;
    p = rot(hash(seed) * 6.28318 + time * 0.08) * p;
    float r = length(p);
    float a = atan(p.y, p.x);
    float petals = 0.42 + 0.58 * pow(0.5 + 0.5 * cos(a * 5.0), 1.15);
    float fill = smoothstep(petals, petals - 0.22, r);
    if (fill < 0.01) {
        return;
    }

    vec3 petalA = vec3(0.95, 0.42, 0.62);
    vec3 petalB = vec3(1.00, 0.82, 0.35);
    vec3 petalC = vec3(0.72, 0.38, 0.92);
    vec3 petal = mix(petalA, mix(petalB, petalC, step(0.66, hash(seed + 3.0))), step(0.33, hash(seed + 1.0)));
    petal = mix(petal, vec3(1.0, 0.92, 0.95), 0.12 * (1.0 - r));

    float centerBloom = smoothstep(0.22, 0.0, r);
    vec3 rgb = mix(petal, vec3(1.0, 0.85, 0.25), centerBloom);
    float aOut = fill * 0.92;
    col = mix(col, rgb, aOut);
    alpha = max(alpha, aOut);
}

void leaf(inout vec3 col, inout float alpha, vec2 uv, vec2 center, float ang, float size, float seed) {
    vec2 p = rot(-ang) * (uv - center);
    p.x /= size * 1.15;
    p.y /= size * 0.38;
    float body = smoothstep(1.0, 0.45, length(p));
    float tip = smoothstep(0.15, -0.05, p.x);
    float fill = body * (0.35 + 0.65 * (1.0 - abs(p.y)));
    fill *= 1.0 - 0.25 * tip;
    if (fill < 0.02) {
        return;
    }
    vec3 green = mix(vec3(0.16, 0.42, 0.18), vec3(0.34, 0.62, 0.24), hash(seed));
    green = mix(green, vec3(0.10, 0.28, 0.12), abs(p.y));
    float aOut = fill * 0.88;
    col = mix(col, green, aOut);
    alpha = max(alpha, aOut);
}

vec4 effect_flowers(vec4 pix) {
    float cover = coverage();
    if (cover < 0.004) {
        return pix;
    }

    float aspect = fullSize.x / max(fullSize.y, 1.0);
    vec2 uv = vec2(v_texcoord.x * aspect, v_texcoord.y);

    vec3 plant = vec3(0.0);
    float alpha = 0.0;

    int grassN = int(mix(10.0, 24.0, cover));
    for (int g = 0; g < 24; g++) {
        if (g >= grassN) {
            break;
        }
        float id = float(g) + 30.0;
        float gx = (0.01 + hseed(id) * 0.98) * aspect;
        float gh = (0.06 + hash(id + 1.0) * 0.12) * mix(0.55, 1.0, cover);
        float tipY = 1.0 - gh;
        float t = clamp((1.0 - uv.y) / max(gh, 0.001), 0.0, 1.0);
        float bx = gx + sin(t * 3.5 + time * 0.6 + id) * 0.012 * t * aspect;
        float blade = 0.0;
        if (uv.y <= 1.0 && uv.y >= tipY) {
            float thick = mix(0.007, 0.0018, t) * aspect;
            blade = smoothstep(thick, 0.0, abs(uv.x - bx));
        }
        plant = mix(plant, vec3(0.18, 0.46, 0.20), blade * 0.8);
        alpha = max(alpha, blade * 0.8);
    }

    for (int i = 0; i < 14; i++) {
        float id = float(i) + 1.0;
        float appear = float(i) / 14.0;
        if (cover < appear * 0.62 + 0.05) {
            continue;
        }
        float local = smoothstep(appear * 0.62, appear * 0.62 + 0.18, cover);
        float reach = local * mix(0.62, 1.0, hash(id + 4.0)) * mix(0.72, 1.0, cover);
        float tipY = 1.0 - reach;
        if (uv.y < tipY - 0.08) {
            continue;
        }

        float t = clamp((1.0 - uv.y) / max(reach, 0.001), 0.0, 1.0);
        float vx = vineX(t, id, aspect);
        float thick = mix(0.011, 0.0035, t) * aspect;
        float vine = 0.0;
        if (uv.y >= tipY && uv.y <= 1.0) {
            vine = smoothstep(thick, thick * 0.15, abs(uv.x - vx));
        }
        vec3 vineCol = mix(vec3(0.22, 0.38, 0.16), vec3(0.12, 0.28, 0.12), t);
        plant = mix(plant, vineCol, vine * 0.95);
        alpha = max(alpha, vine * 0.95);

        int leafN = int(mix(4.0, 9.0, cover));
        for (int k = 0; k < 9; k++) {
            if (k >= leafN) {
                break;
            }
            float lt = 0.10 + float(k) * 0.09;
            if (lt > t + 0.02 || reach * lt > reach - 0.02) {
                continue;
            }
            float ly = 1.0 - reach * lt;
            float lx = vineX(lt, id, aspect);
            float side = (hash(id * 10.0 + float(k)) > 0.5) ? 1.0 : -1.0;
            float ang = side * (0.55 + hash(id + float(k)) * 0.5) + sin(time * 0.5 + id) * 0.08;
            vec2 lpos = vec2(lx + side * 0.028 * aspect, ly);
            leaf(plant, alpha, uv, lpos, ang, 0.034 + hash(id + float(k) * 3.0) * 0.02, id * 8.0 + float(k));
        }

        vec2 fpos = vec2(vineX(1.0, id, aspect), tipY);
        flower(plant, alpha, uv, fpos, (0.026 + hash(id + 9.0) * 0.016) * mix(0.65, 1.0, local), id * 5.3);

        if (cover > 0.28) {
            float mt = 0.58;
            vec2 mpos = vec2(vineX(mt, id, aspect), 1.0 - reach * mt);
            flower(plant, alpha, uv, mpos, 0.018 + hash(id + 11.0) * 0.01, id * 9.1);
        }
        if (cover > 0.55) {
            float mt = 0.34;
            vec2 mpos = vec2(vineX(mt, id, aspect), 1.0 - reach * mt);
            flower(plant, alpha, uv, mpos, 0.016 + hash(id + 13.0) * 0.01, id * 12.4);
        }
        if (cover > 0.78) {
            float mt = 0.78;
            vec2 mpos = vec2(vineX(mt, id, aspect), 1.0 - reach * mt);
            flower(plant, alpha, uv, mpos, 0.015 + hash(id + 15.0) * 0.008, id * 16.0);
        }
    }

    // Fill blossoms that pop in as coverage rises, until the screen is packed.
    for (int f = 0; f < 22; f++) {
        float id = float(f) + 80.0;
        float need = 0.22 + hseed(id) * 0.75;
        if (cover < need) {
            continue;
        }
        float bloom = smoothstep(need, need + 0.12, cover);
        vec2 pos = vec2((0.04 + hseed(id + 1.0) * 0.92) * aspect,
                        1.0 - hseed(id + 2.0) * mix(0.35, 0.96, cover));
        float sz = (0.014 + hash(id + 3.0) * 0.018) * bloom;
        flower(plant, alpha, uv, pos, sz, id);
    }

    pix.rgb = mix(pix.rgb, plant, clamp(alpha, 0.0, 0.92));
    return pix;
}
