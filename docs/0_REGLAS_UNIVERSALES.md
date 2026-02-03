# Reglas universales y puntos no tocar

**Documento de referencia para el asistente y el equipo.**  
Última actualización: 2025-01-31

---

## Reglas universales (siempre tener en cuenta)

Estas reglas aplican a **todo** el proyecto. Cualquier cambio (UI, texto, balance, docs) debe respetarlas salvo que el usuario pida explícitamente lo contrario.

### UI y texto
- **Colores de letras/etiquetas:** Mantener coherencia por tipo de recurso (p. ej. Stability/Charge, quarks Down/Up con sus colores asignados). No cambiar paletas sin petición.
- **Unidades y formato:** Expresar cantidades y unidades de forma consistente (p. ej. "E: 7 / 10", "C: x", "x%d", etc.). No mezclar estilos (un lugar "7/10", otro "7 de 10").
- **Títulos centrados:** Los títulos de paneles de edificios (CONSTRUCTOR, FUSIONADOR, etc.) van centrados en el panel (CenterContainer + horizontal_alignment según corresponda).
- **Botón menú recursos:** El botón que abre el dropdown de categorías de edificios (SIFONES, PRISMAS, etc.) se llama **INFRAESTRUCTURA** en la UI (texto del botón). Los nodos pueden seguir llamándose BtnRecursos/RecursosDropdownPanel por compatibilidad.

### Comportamiento "todos los…"
- Cuando el usuario pida algo del tipo **"todos los X"** o **"todas las UIs"** (p. ej. quitar Rotar 90°, centrar títulos, mismo estilo de purga), aplicar el cambio de forma **uniforme** a todos los elementos del mismo tipo (todas las UIs de edificios, todos los botones de una barra, etc.).

### Save/Load y escena
- **Reconstrucción de edificios al cargar:** Los edificios se reconstruyen por referencia (lista de instancias), no por búsqueda en el árbol; la reconstrucción se difiere desde WorldGenerator para no llamar `add_child` durante `_ready`. No alterar este flujo sin necesidad.
- **BuildingManager:** Es la fuente fiable del conteo de edificios colocados (menú INFRAESTRUCTURA, TechTree, etc.). Mantener el registro al colocar/activar y usarlo para get_placed_building_count.

### Menú INFRAESTRUCTURA (ex RECURSOS) y dim
- Al abrir el panel **INFRAESTRUCTURA** (o el menú de categorías en la barra inferior): oscurecer todo el mundo, ocultar la **red** (plano de la cámara) y los **tiles** (GridMap). Los tiles y la red deben permanecer ocultos mientras el panel esté abierto, también al pulsar un ítem del dropdown (no restaurar visibilidad hasta cerrar el panel).
- Al cerrar el panel (clic en INFRAESTRUCTURA de nuevo o clic fuera): restaurar materiales y visibilidad de red/tiles.

---

## Puntos NO TOCAR (resueltos y estables)

**No modificar estos comportamientos ni refactorizar su lógica salvo que el usuario lo pida explícitamente.** Evitan regresiones en lo que ya funciona.

### Save/Load
- Guardado/carga de edificios (lista, posición, rotación, estado interno).
- Reconstrucción de edificios al cargar partida (incl. desde menú principal): uso de `instancias_recien_anadidas`, `_activar_lista_edificios`, registro en GridManager y BuildingManager.
- Reconstrucción diferida desde WorldGenerator (`_reconstruir_edificios_deferred`) para no hacer `add_child` durante `_ready`.
- Restauración de mapa (GridMap), cámara y TechTree en la carga.

### UI de edificios (Constructor, Merger, God Siphon, etc.)
- Eliminación de "Rotar 90°" y texto "Abrir: clic derecho" en las UIs de edificios (ya aplicado de forma uniforme).
- Constructor: título CONSTRUCTOR centrado; botón X junto a E/C; Purga todo centrado; requisitos de receta visibles.
- Merger: botones Down/Up para quarks con colores; Purga por fila (X) y Purga todo centrado; título FUSIONADOR centrado.
- Cierre de UIs (clic fuera, etc.) y no rotar edificio al abrir UI (AbreUIClicDerecho).

### Menú INFRAESTRUCTURA y dim
- Oscurecimiento completo + ocultar red y tiles al abrir el panel INFRAESTRUCTURA o el menú de categorías (SIFONES, PRISMAS, etc.).
- Tiles y red siguen ocultos al elegir un ítem del dropdown (no restaurar hasta cerrar).
- Conteo de edificios colocados desde BuildingManager para el menú INFRAESTRUCTURA (y TechTree).
- Restauración de visibilidad y materiales solo al cerrar el panel / menú.

### Edificios en mano (fantasma)
- Sin escala: el fantasma usa `scale = 1.0` (mismo tamaño que en suelo).
- Posición: solo X y Z se actualizan desde el mapa; la **Y** se mantiene como en la escena del edificio (no sobrescribir; respetar la posición del .tscn).

### Otros
- Constructor: `_recuperar_estado_guardado` con guarda `is_inside_tree()`; `check_ground` llamado de forma diferida desde save_system al activar edificios reconstruidos.
- Main menu / main_game_3d: cambio de escena sin acumular escenas (quitar del árbol y queue_free antes de añadir la nueva).

---

## Dónde se aplican

- **Asistente:** Consultar este documento antes de cambiar flujos de save/load, UI de edificios, menú INFRAESTRUCTURA o dim.
- **Desarrollador:** Tener en cuenta las reglas universales en nuevas features; respetar "no tocar" a menos que se pida un cambio concreto.

Si el usuario pide explícitamente cambiar algo que está en "no tocar", se puede modificar; en ese caso conviene actualizar este documento tras el cambio.
