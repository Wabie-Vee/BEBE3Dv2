shader_type spatial;

uniform sampler2D tex_albedo;
uniform float rotation_deg = 0.0;

void fragment() {
    float rotation = radians(rotation_deg);
    vec2 center = vec2(0.5);
    vec2 uv = UV - center;

    float c = cos(rotation);
    float s = sin(rotation);
    mat2 rot = mat2(vec2(c, -s), vec2(s, c));

    uv = rot * uv + center;
    ALBEDO = texture(tex_albedo, uv).rgb;
}
