shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 1.0;
uniform float blink : hint_range(0.0, 1.0) = 1.0;
uniform float glitch : hint_range(0.0, 1.0) = 0.0;
uniform float noise_amount : hint_range(0.0, 1.0) = 0.1;

float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    vec2 uv = UV;
    
    // Glitch horizontal
    if (glitch > 0.0) {
        float glitch_time = floor(TIME * 10.0);
        float glitch_strength = glitch * 0.1;
        if (random(vec2(glitch_time)) > 0.8) {
            uv.x += (random(vec2(uv.y, glitch_time)) - 0.5) * glitch_strength;
        }
    }

    vec4 color = texture(TEXTURE, uv);
    
    // Simular o ligar de um monitor
    float line = step(0.5, abs(uv.y - 0.5) + (1.0 - intensity) * 0.5);
    color.rgb *= (1.0 - line);
    
    // Piscadas rápidas (tipo fluorescente)
    color.rgb *= blink;
    
    // Ruído visual
    float n = random(uv + TIME);
    color.rgb += (n - 0.5) * noise_amount;
    
    // Vinheta simples
    float dist = distance(uv, vec2(0.5));
    color.rgb *= (1.0 - dist * 0.5);
    
    COLOR = color;
}
