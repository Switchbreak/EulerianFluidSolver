shader_type fog;

uniform sampler2D fog_texture;
uniform vec3 albedo: source_color = vec3(1.0);
uniform vec3 emission: source_color = vec3(0.5);

void fog() {
    vec4 color = texture(fog_texture, UVW.xz);
    ALBEDO = vec3(1.0, 1.0, 1.0);
    EMISSION = vec3(0.5, 0.5, 0.5);
    DENSITY = (UVW.y < color.b / 10.0) ? color.b / 10.0 : 0.0;
}
