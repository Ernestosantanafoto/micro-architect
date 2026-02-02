shader_type spatial;
render_mode unshaded, blend_add, cull_disabled;

uniform vec3 grid_color : source_color = vec3(0.0, 0.0, 0.0);
uniform float grid_density = 1.0;
uniform float line_thickness = 0.02;
// 0 = grid visible, 1 = grid desvanecido (zoom lejano). Lo pasa el script desde la cámara.
uniform float zoom_fade = 0.0;

varying vec3 world_pos_xz;

void vertex() {
	// Posición en mundo para que la grilla coincida con el GridMap (centros en n.5, bordes en enteros)
	world_pos_xz = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// AJUSTE DE FASE: Restamos 0.5 para que el "cero" coincida con el borde de la celda (centros en n.5)
	vec2 grid_uv = (world_pos_xz.xz - vec2(0.5)) * grid_density;

	// Calculamos la rejilla
	vec2 grid = abs(fract(grid_uv) - 0.5) / (line_thickness * grid_density);
	float line = 1.0 - min(min(grid.x, grid.y), 1.0);

	ALBEDO = grid_color;

	// Pulso 50%–100% de opacidad
	float pulse = 0.5 + 0.5 * sin(TIME * 1.0);
	ALPHA = line * 0.8 * pulse * (1.0 - zoom_fade);
}