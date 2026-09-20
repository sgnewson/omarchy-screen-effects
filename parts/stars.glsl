float star_sparkle(vec2 uv, vec2 center, float size) {
    vec2 d = abs(uv - center);
    float h = max(0.0, 1.0 - d.x / size) * max(0.0, 1.0 - d.y / (size * 0.11));
    float v = max(0.0, 1.0 - d.y / size) * max(0.0, 1.0 - d.x / (size * 0.11));
    float diag = max(0.0, 1.0 - abs(d.x - d.y) / (size * 0.12)) * max(0.0, 1.0 - (d.x + d.y) / (size * 1.35));
    float core = max(0.0, 1.0 - length(uv - center) / (size * 0.26));
    return h + v + diag * 0.55 + core * 1.5;
}

vec4 effect_stars(vec4 pix) {
    float motion = max(1.0 - smoothstep(0.55, 1.1, pointer_last_active),
                       pointer_hidden != 0 ? 1.0 : 0.0);
    if (motion < 0.01) {
        return pix;
    }

    vec2 pixCoord = v_texcoord * fullSize;
    vec2 pointerPx = pointer_position * fullSize;
    float spark = 0.0;
    vec3 tint = vec3(0.0);
    const float CELL = 46.0;
    vec2 cell = floor(pixCoord / CELL);

    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 id = cell + vec2(float(x), float(y));
            float spawn = hash22(id);
            if (spawn > 0.14) {
                continue;
            }

            vec2 pos = (id + hash2(id * 1.7)) * CELL;
            float phase = hash22(id + 17.0) * 6.2831853;
            float speed = 1.4 + hash22(id + 9.0) * 2.6;
            float twinkle = pow(max(0.0, sin(time * speed + phase)), 14.0);
            if (twinkle < 0.02) {
                continue;
            }

            float size = 2.8 + hash22(id + 3.0) * 5.0;
            float s = star_sparkle(pixCoord, pos, size) * twinkle;
            vec3 color = mix(vec3(1.00, 0.96, 0.84), vec3(0.74, 0.92, 1.00), hash22(id + 5.0));
            color = mix(color, vec3(1.00, 0.80, 0.94), hash22(id + 11.0) * 0.4);
            spark += s;
            tint += color * s;
        }
    }

    float luma = dot(pix.rgb, vec3(0.299, 0.587, 0.114));
    float nearPointer = exp(-distance(pixCoord, pointerPx) / 220.0);
    float amount = clamp(spark, 0.0, 2.2) * mix(0.28, 0.95, 1.0 - luma) * motion;
    amount *= 0.55 + 0.45 * nearPointer;
    vec3 sparkColor = spark > 0.0 ? tint / max(spark, 0.001) : vec3(1.0);
    pix.rgb += sparkColor * amount * 0.9;
    return pix;
}
