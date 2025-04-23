shader_type canvas_item;

uniform float shake: hint_range(0, 10) = 0.0;
uniform float noiseQuality: hint_range(0.1, 250, 0.1) = 250;
uniform float noiseIntensity: hint_range(0, 0.05, 0.001) = 0.000;
uniform float offsetIntensity: hint_range(0, 0.05, 0.0001) = 0.0045;
uniform float colorOffsetIntensity: hint_range(0.1, 1.5, 0.001) = 0.2;
uniform float pixelSize: hint_range(1, 1024) = 200.0;
uniform float grainIntensity: hint_range(0, 1) = 0.04;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D overlay_texture : hint_default_transparent;
uniform bool use_overlay = true;
uniform bool use_lens_distortion = true;

uniform vec4 overlay_color : source_color = vec4(1.0, 1.0, 1.0, 10.0);
uniform float lens_distortion_strength: hint_range(0, 0.1) = 0.05;

varying vec2 previous_pos;

float rand(vec2 co)
{
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 iResolution = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 uv = FRAGCOORD.xy / iResolution.xy;

    vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 pixel_dims = pixelSize / resolution;
    uv = floor(uv / pixel_dims) * pixel_dims;

    // Noise distortion (static seed using uv only)
    float uvY = uv.y * noiseQuality;
    uvY = float(int(uvY)) * (1.0 / noiseQuality);
    float noise = rand(vec2(42.0, uvY)); // Static seed
    uv.x += noise * noiseIntensity;

    // Static color channel offsets
    vec2 offsetR = vec2(0.002, 0.0) * colorOffsetIntensity;
    vec2 offsetG = vec2(-0.002, 0.0) * colorOffsetIntensity;

    float r = texture(screen_texture, uv + offsetR).r;
    float g = texture(screen_texture, uv + offsetG).g;
    float b = texture(screen_texture, uv).b;
    vec4 tex = vec4(r, g, b, 1.0);

    // Overlay (optional)
    if (use_overlay) {
        vec4 overlayColor = texture(overlay_texture, uv) * overlay_color;
        tex = mix(tex, overlayColor, overlayColor.a);
    }

    // Film grain (static UV-seeded)
    float grain = rand(uv * 100.0) * 2.0 - 1.0; // Extra scaling for more variation
    tex.rgb += grainIntensity * grain;

    // Lens distortion (static effect based on UV only)
    if (use_lens_distortion) {
        vec2 distortion = uv * lens_distortion_strength * (uv - 1.0);
        vec4 distorted_tex = texture(screen_texture, uv + distortion);
        tex = mix(tex, distorted_tex, 0.5);
    }

    COLOR = tex;
    previous_pos = uv;
}
