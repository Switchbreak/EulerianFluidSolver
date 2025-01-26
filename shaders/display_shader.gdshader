shader_type canvas_item;

render_mode unshaded;

uniform float scale_factor = 10.0;

void fragment() {
    vec4 source = texture(TEXTURE, UV);
    source.b /= scale_factor;
    COLOR = vec4(source.b, source.b, source.b, 1.0);
}
