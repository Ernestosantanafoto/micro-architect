# Changelog

Todos los cambios notables del proyecto se documentan aquí.  
**Origen:** sesiones de desarrollo + documentos en `docs/` (PROGRESO, TASKLIST, PROJECT_STATE, ROADMAP, REFACTORING_PLAN, POLISH_PLAN, COSAS_POR_HACER, etc.).  
**Reglas:** [0_REGLAS_UNIVERSALES.md](docs/0_REGLAS_UNIVERSALES.md).

---

## [Unreleased] – 2025-02-03

### Issues resueltos (GitHub)

*(Cada issue se añade aquí con fecha y hora al cerrarlo; ver flujo en [docs/issues.md](docs/issues.md).)*

- **[#20](https://github.com/Ernestosantanafoto/micro-architect/issues/20) – UI: Add "Quark" suffix to UP and DOWN terms**  
  Cerrado: 2025-02-03  
  - GameConstants: nombres "Up-Quark"/"Down-Quark", `get_nombre_visible_recurso` y `get_nombre_visible_recurso_cantidad` (singular/plural).
  - constructor_ui, recipe_book, help_panel, god_siphon_ui, merger_ui, HUD: etiquetas y colores actualizados.

- **[#15](https://github.com/Ernestosantanafoto/micro-architect/issues/15) – Docs: Complete recipe book – Costs, times, unlock conditions**  
  Cerrado: 2025-02-03  
  - 9_RECETAS.md: costes, tiempos y condiciones de desbloqueo documentados y alineados con el código.

- **[#12](https://github.com/Ernestosantanafoto/micro-architect/issues/12) – Hadron Factory unlock: 10 factories placed**  
  Cerrado: 2025-02-03  
  - tech_tree.gd: Fabricador Hadrón desbloqueo por 10 Constructores colocados (antes 4). goal_hints y 9_RECETAS.md actualizados.

- **[#22](https://github.com/Ernestosantanafoto/micro-architect/issues/22) – UI: Constructor menu excessively tall**  
  Cerrado: 2025-02-03  
  - constructor_ui: VBoxContainer separation 6, ScrollContainer sin expandir; ALTURA_POR_FILA 26, ALTURA_MAX_LISTA 140 para menú más compacto.

- **[#18](https://github.com/Ernestosantanafoto/micro-architect/issues/18) – Simplify: Remove redundant tech unlock requirements**  
  Cerrado: 2025-02-03  
  - tech_tree: `requires` vacío para techs con solo condición (T2, Fusionador, Constructor, Fabricador Hadrón).
  - goal_hints y 9_RECETAS.md sin "Tech: X"; recipe_book ya no muestra "Disponible desde el inicio" cuando hay unlock_condition.

- **[#13](https://github.com/Ernestosantanafoto/micro-architect/issues/13) – Constructor (Producer) recipe: 5 Up-Quarks + 5 Down-Quarks**  
  Cerrado: 2025-02-03  
  - GameConstants RECETAS Constructor: inputs 40/40 → 5/5. 9_RECETAS.md actualizado.

- **[#23](https://github.com/Ernestosantanafoto/micro-architect/issues/23) – Bug: Audio briefly plays on new game start despite mute/minimum volume**  
  Cerrado: 2025-02-03  
  - MusicManager: aplicar volumen/mute antes de play_random_song(); _fade_to_track respeta mute (target_db -80 si muted).

- **[#24](https://github.com/Ernestosantanafoto/micro-architect/issues/24) – Feature: Music muffle/fade during extreme zoom out**  
  Cerrado: 2025-02-03  
  - MusicManager: bus Music con AudioEffectLowPassFilter, set_zoom_muffle(); ligera bajada de volumen con zoom.
  - camera_pivot: _actualizar_musica_muffle_zoom() con umbral 38 y smoothstep para transición progresiva.
  - GameConstants: CAMARA_ZOOM_UMBRAL_MUSICA_MUFFLE.

- **[#25](https://github.com/Ernestosantanafoto/micro-architect/issues/25) – Feature: Dual grid (detail + macro) with zoom transition**  
  Cerrado: 2025-02-03  
  - main_game_3d.tscn: nodo GridMacro (MeshInstance3D) con ShaderMaterial dorado, grid 9x9.
  - GameConstants: CAMARA_ZOOM_UMBRAL_GRID_MACRO (69), CAMARA_ZOOM_GRID_MACRO_END (88).
  - camera_pivot: _set_grid_zoom_fade() transición smoothstep entre grid detalle (1x1) y macro (9x9).
  - system_hud: ocultar/restaurar GridMacro en _oscurecer_y_ocultar_grilla_y_tiles y _restaurar_visibilidad_grilla_y_tiles.
  - main_game_3d.gdshader: pulso de rejillas entre 0.4 y 0.85 para que no desaparezcan por completo.

- **[#26](https://github.com/Ernestosantanafoto/micro-architect/issues/26) – Feature: First-time welcome popup with tutorial introduction**  
  Cerrado: 2025-02-03  
  - SaveSystem: get_value/set_value y user://game_prefs.cfg para preferencias globales (tutorial_completed).
  - main_game_3d: _mostrar_tutorial_si_nueva_partida() — muestra tutorial solo en nueva partida (sin edificios a reconstruir).
  - tutorial_manager: intro con botón "No, ya sé jugar" (persiste tutorial_completed y cierra); "Saltar tutorial" en pasos siguientes.

### Corregido

- **Issue #1 – Beams ignore building interactions except at maximum range**
  - **BeamEmitter**: la detección de edificios en el haz usaba la posición del grid (`map.map_to_local`) para el point query; la Y del grid puede no coincidir con la Y de los edificios (estos mantienen la Y de la escena). Ahora el point query usa la Y del origen del haz (`origen.y`) para comprobar a la altura de los edificios, de modo que prismas y otros receptores se detecten en cualquier celda del path.
  - **BeamEmitter**: añadido `_obtener_edificio_desde_collider()` para resolver el collider al nodo edificio (subiendo por el árbol si el collider es hijo), asegurando que `esta_construido` y los métodos de recepción se comprueban en el nodo correcto.

### Añadido

- **CHANGELOG.md**: este archivo, con historial de desarrollo según los MD del proyecto y cambios recientes.

### Cambiado (alineación con reglas universales)

- **UI – Títulos centrados en paneles de edificios**
  - **Compressor UI**: título "COMPRESOR" dentro de `CenterContainer` + `horizontal_alignment = 1`.
  - **God Siphon UI**: título "MODO DIOS" dentro de `CenterContainer` + `horizontal_alignment = 1`.

- **UI – Formato de cantidades unificado**
  - **Compressor**: buffer con estilo "x / y" (espacios). En `compressor_ui.tscn` texto por defecto "Buffer: 0 / 10"; en `compressor.gd` etiqueta 3D `"%d / 10" % buffer`.

- **Comentarios**
  - **Construction Manager**: comentario sobre clic derecho actualizado a "abrir su panel (no rotar al abrir)".

### Revisado

- Auditoría frente a reglas universales: INFRAESTRUCTURA, BuildingManager, save/load, dim, fantasma, Constructor, cambio de escena; sin cambios necesarios en esos puntos.

---

## Historial de desarrollo (según docs)

Resumen de lo realizado y registrado en los archivos MD del proyecto (PROGRESO, TASKLIST, PROJECT_STATE, ROADMAP, REFACTORING_PLAN, POLISH_PLAN, COSAS_POR_HACER).  
Fechas aproximadas según "Última actualización" en cada doc (2025-01-31 / 2025-02-01).

---

### Sistema de energía numérico (Refactorización)

- **GridManager**: registro de celdas ocupadas, `register_building` / `unregister_building` / `is_cell_occupied` / `get_building_at`; Autoload.
- **EnergyManager**: flujos numéricos (`EnergyFlow`), `register_flow` / `unregister_flow`, actualización en `_process`; energía como datos, no nodos físicos.
- **BuildingManager**: `active_buildings`, registro/desregistro; fuente fiable para conteo (menú INFRAESTRUCTURA, TechTree, save/load).
- **Migración de edificios**: Siphon, Compressor, Prisma, Merger, Constructor, God Siphon migrados a energía numérica; eliminada instanciación de `energy_pulse.tscn`.
- **PulseVisual**: visual opcional (bolas en movimiento) conectado a señales de EnergyManager; no afecta lógica.
- **Cleanup**: eliminación/deprecación de `energy_pulse.tscn` y código viejo.

---

### Save/Load y persistencia

- Guardado/carga de edificios (lista, posición, rotación, estado interno).
- Reconstrucción por referencia (`instancias_recien_anadidas`, `_activar_lista_edificios`), no por búsqueda en árbol.
- Reconstrucción diferida desde WorldGenerator (`_reconstruir_edificios_deferred`) para no hacer `add_child` durante `_ready`.
- TechTree integrado en SaveSystem: tecnologías desbloqueadas (F2) persisten al guardar/cargar.
- Zoom de cámara restaurado al cargar (world_generator).
- Sifones funcionando tras cargar (game_tick + esta_construido).
- Constructor: `_recuperar_estado_guardado` con guarda `is_inside_tree()`; `check_ground` diferido al activar edificios reconstruidos.
- Restauración de mapa (GridMap), cámara y TechTree en la carga.
- Múltiples slots de guardado (ej. save_1.json, save_2.json, etc.).

---

### Menú INFRAESTRUCTURA (ex RECURSOS) y dim

- Botón renombrado a **INFRAESTRUCTURA** en la UI (nodos internos siguen BtnRecursos/RecursosDropdownPanel).
- Al abrir panel: oscurecer todo el mundo, ocultar red (plano cámara) y tiles (GridMap).
- Tiles y red permanecen ocultos al pulsar un ítem del dropdown hasta cerrar el panel.
- Conteo de edificios colocados desde BuildingManager (menú actualizado en partida).
- Clic fuera cierra panel y restaura visibilidad y materiales.
- Mismo efecto dim al abrir menú de categorías (SIFONES, PRISMAS, etc.) en la barra inferior; HUD Manager llama `aplicar_dim_menu_edificios`.

---

### Colocación y edificios

- **Prismas**: solo se colocan en TILE_VACIO; placement_logic por grupo; corregido bug de prismas colocados como God Siphons.
- **Void Generator**: lógica real de borrado de tiles; reescrito (ya no copia de construction_manager).
- **Fabricador Hadrón**: quarks → protones/neutrones (2U+1D, 1U+2D); recibe pulsos, añade productos al inventario; forma 12×12 (get_footprint_offsets 144 celdas); doc HADRON_6x6_CSG actualizado.
- **Edificios en mano (fantasma)**: scale = 1.0 (mismo tamaño que en suelo); posición: solo X y Z desde el mapa, Y se mantiene como en la escena del edificio (.tscn).
- HUD con `mouse_filter = IGNORE` para que los clics lleguen al mapa; botón SELECCIÓN desactivado por defecto.

---

### UI/UX y pulido

- **HUD**: categorías (ENERGÍA | QUARKS | EDIFICIOS) con colores; barra SIFONES, PRISMAS, MANIPULA, CONSTR; botón INFRAESTRUCTURA (dropdown).
- **UIs de edificios**: eliminación de "Rotar 90°" y texto "Abrir: clic derecho"; títulos centrados (CONSTRUCTOR, FUSIONADOR); Purga todo centrado; Merger con selector quarks (Down/Up) y purga por fila.
- **Constructor UI**: título CONSTRUCTOR centrado; botón X junto a E/C; Purga todo centrado; requisitos de receta visibles; grid de iconos; hotkeys 1–9.
- **God Siphon UI**: sliders energía/frecuencia, vista previa, aplicar/resetear.
- **Panel Ayuda F1**: 4 pestañas (Recursos, Edificios, Controles, Objetivos); contenido actualizado (Fabricador Hadrón, Protón, Neutrón).
- **Recetario F2**: tech tree con desbloqueos; actualizado.
- **Tutorial**: 5 pasos básicos.
- **Menú principal**: nuevo, cargar, salir, opciones.
- **Opciones**: volumen música, volumen efectos, pantalla completa, guardado en user://settings.cfg.
- **Hotkeys**: R rotar, ESC cancelar, 0 God Siphon (DEBUG), 1–9 edificios.
- **Clic central**: copiar edificio / colocar y mantener otro.
- **Selección múltiple** por arrastre.
- **Grid guía**: pulso 50–100 %, desvanecimiento por zoom.
- **Feedback al colocar**: pop/shake al colocar edificio.
- **StyleBox** en HUD, paneles unificados, tooltips.

---

### Bugs y estabilidad (ROADMAP Bloques 1–4)

- **Bloque 1**: haces visuales cortados en prismas (HAZ_OFFSET_ORIGEN 0.25); salidas de mergers (posición/visual); verificación de que visuales no afectan lógica.
- **Bloque 2**: feedback visual al colocar (pop/shake); mejoras en menús (transiciones, versión).
- **Bloque 3**: unificación RECETAS vs menu_data; limpieza deprecated (energy_pulse eliminado).
- **Bloque 4**: Fabricador Hadrón completo; F1/F2 actualizados.
- **Bloque 5 (parcial)**: edificios guardan/cargan; zoom restaurado; sifones tras cargar; tech persistente; prismas y Void Generator corregidos.

---

### Documentación y organización

- Creación de **PROGRESO.md** (estado del proyecto).
- Creación de **TASKLIST.md** (qué hacer ahora).
- **README.md** reescrito con "Empieza aquí" y niveles (diario / cuando toque / referencia).
- Archivo de docs redundantes (Nuevos MDs, ANALISIS_UNIFICACION_MDS, MD_ACTUALIZADO).
- **0_REGLAS_UNIVERSALES.md**: reglas de UI, texto, "todos los…", save/load, BuildingManager, menú INFRAESTRUCTURA y dim; sección "Puntos no tocar".
- **14_NOTAS_DESARROLLO**: flujo commit/push al cerrar sesión; notas sobre fantasma (Y, scale).
- **Análisis null-safety** en beam_emitter, god_siphon, save_system, world_generator, inventory_button, hud.

---

### Pendiente (según docs)

- Verificar save/load con 20+ edificios (TEST_CHECKLIST 10.3).
- Verificar colocación de todos los edificios en tiles correctos (TEST_CHECKLIST 6.5).
- Ejecutar TEST_CHECKLIST completo; documentar y arreglar bugs críticos.
- Preparar demo: export HTML5/Windows, itch.io, descripción, screenshots/GIF.
- Opcional: persistir bolas en vuelo (PulseVisual) al cargar o quitar dim.
- Prioridad P: volumen música (UI), partida corrupta/inexistente, logs debug, export estable, texto itch.io.

---

*Formato inspirado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/).*
