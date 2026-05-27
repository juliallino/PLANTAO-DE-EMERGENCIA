shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 1.0;
uniform float blink : hint_range(0.0, 1.0) = 1.0;
uniform float glitch : hint_range(0.0, 1.0) = 0.0;
uniform float noise_amount : hint_range(0.0, 1.0) = 0.1;
uniform float blur_amount : hint_range(0.0, 1.0) = 0.0;

float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    vec2 uv = UV;
    
    // Blur/Distorção de sinal
    if (blur_amount > 0.0) {
        uv.x += (random(vec2(TIME, uv.y)) - 0.5) * blur_amount * 0.05;
        uv.y += (random(vec2(uv.x, TIME)) - 0.5) * blur_amount * 0.02;
    }

    // Glitch horizontal
    if (glitch > 0.0) {
        float glitch_time = floor(TIME * 20.0);
        float glitch_strength = glitch * 0.15;
        if (random(vec2(glitch_time)) > 0.7) {
            uv.x += (random(vec2(uv.y, glitch_time)) - 0.5) * glitch_strength;
        }
    }

    vec4 color = texture(TEXTURE, uv);
    
    // Simular o ligar de um monitor
    float line = step(0.5, abs(uv.y - 0.5) + (1.0 - intensity) * 0.5);
    color.rgb *= (1.0 - line);
    
    // Piscadas rápidas (tipo fluorescente / falha de energia)
    color.rgb *= blink;
    
    // Ruído visual cinematográfico
    float n = random(uv + TIME);
    color.rgb += (n - 0.5) * noise_amount;
    
    // Vinheta simples
    float dist = distance(uv, vec2(0.5));
    color.rgb *= (1.0 - dist * 0.6);
    
    COLOR = color;
}
