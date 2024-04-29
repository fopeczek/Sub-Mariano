shader_type canvas_item;

uniform vec4 background_color: source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 foreground_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float grid_size: hint_range(0.0, 200, 0.1) = 50;
uniform float dot_size: hint_range(0.0, 1.0, 0.01) = 0.1;

void fragment() {
	vec2 tile_coord = mod(FRAGCOORD.xy * SCREEN_PIXEL_SIZE.x, vec2(1.0 / grid_size));
	vec2 uv =  tile_coord * grid_size - vec2(0.5);
	float len = clamp(length(uv) / dot_size, 0, 1);
	COLOR = mix(foreground_color, background_color, len);
}