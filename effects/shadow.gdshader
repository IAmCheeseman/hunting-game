shader_type canvas_item;

uniform vec4 color : source_color = vec4(1, 1, 1, 1);
uniform float on : hint_range(0.0, 1.0, 1.0) = 1.0;
uniform float flipped : hint_range(-1.0, 1.0, 2.0) = 0.0;

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	COLOR = mix(texture_color, color, texture_color.a * on);
}

void vertex() {
	VERTEX.y *= 0.5;
}