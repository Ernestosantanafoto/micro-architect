shader_type canvas_item;

// Radio interior/exterior: actualizados por script según zoom (cercano = solo márgenes; lejano = más amplia).
uniform float radius_inner : hint_range(0.0, 1.0) = 0.5;
uniform float radius_outer : hint_range(0.0, 1.5) = 1.0;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	// Compensar aspect ratio para que el degradado sea radial en pantalla
	vec2 size = 1.0 / TEXTURE_PIXEL_SIZE;
	float aspect = size.x / size.y;
	uv.x *= aspect;
	float d = length(uv) * 2.0;
	float alpha = smoothstep(radius_inner, radius_outer, d);
	COLOR = vec4(0.0, 0.0, 0.0, alpha);
}
