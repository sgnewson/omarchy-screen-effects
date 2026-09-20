vec4 effect_aurora(vec4 pix) {
    float activity = max(1.0 - smoothstep(0.6, 2.2, pointer_last_active),
                         pointer_hidden != 0 ? 1.0 : 0.0);
    float gain = mix(0.20, 1.0, activity);

    float x = v_texcoord.x;
    float y = v_texcoord.y;
    float driftY = 0.16 * sin(time * 0.011) + 0.08 * sin(time * 0.007 + 1.4);
    float driftX = 0.18 * sin(time * 0.008 + 0.6);
    float wx = x + driftX;
    float w1 = 0.18 + driftY + 0.07 * sin(wx * 2.0 + time * 0.035);
    float w2 = 0.34 + driftY * 0.85 + 0.08 * sin(wx * 2.8 - time * 0.026 + 1.7);
    float w3 = 0.50 + driftY * 0.65 + 0.06 * sin(wx * 1.3 + time * 0.018);

    float b1 = exp(-pow((y - w1) * 5.2, 2.0));
    float b2 = exp(-pow((y - w2) * 4.4, 2.0));
    float b3 = exp(-pow((y - w3) * 5.6, 2.0));
    float veil = (1.0 - smoothstep(0.58, 0.96, y)) * 0.4 + 0.35;
    vec3 acc = vec3(0.0);
    acc += vec3(0.18, 0.95, 0.55) * b1 * 0.07;
    acc += vec3(0.42, 0.55, 1.00) * b2 * 0.055;
    acc += vec3(0.78, 0.32, 0.95) * b3 * 0.045;
    acc *= veil * (0.75 + 0.25 * (0.5 + 0.5 * sin(wx * 2.0 + time * 0.04)));
    pix.rgb += acc * gain;
    return pix;
}
