shader_type spatial;
render_mode unshaded, blend_add, cull_disabled;

uniform vec3 grid_color : source_color = vec3(0.0, 0.0, 0.0);
uniform float grid_density = 1.0;
uniform float line_thickness = 0.02;

void fragment() {
    // Obtenemos la posición real en el mundo
    vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;

    // AJUSTE DE FASE: Restamos 0.5 para que el "cero" del shader
    // coincida con el borde de la celda del GridMap y no con su centro.
    vec2 grid_uv = (world_pos.xz - vec2(0.5)) * grid_density;

    // Calculamos la rejilla
    vec2 grid = abs(fract(grid_uv) - 0.5) / (line_thickness * grid_density);
    float line = 1.0 - min(min(grid.x, grid.y), 1.0);

    ALBEDO = grid_color;

    // Efecto de desvanecimiento suave para que no haya aliasing (puntos feos)
    ALPHA = line * 0.8;
}