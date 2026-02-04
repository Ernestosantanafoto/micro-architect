# Auditoría de Código – Micro Architect

**Fecha:** 2025-02-03  
**Alcance:** scripts/, revisión contra 0_REGLAS_UNIVERSALES.md, 10_ARCHITECTURE.md y documentación asociada  
**Versión proyecto:** v0.5-alpha

---

## 1. CUMPLIMIENTO DE REGLAS (0_REGLAS_UNIVERSALES.md)

### UI y texto
| Regla | Estado | Notas |
|-------|--------|-------|
| Colores por tipo de recurso coherentes | [x] | GameConstants centraliza Stability/Charge/Quarks |
| Unidades y formato consistentes | [x] | "E: x", "C: x", "x / 10", etc. |
| Títulos centrados en paneles | [x] | CONSTRUCTOR, FUSIONADOR, etc. |
| Botón menú recursos = **INFRAESTRUCTURA** | [x] | system_hud, hud_manager |

### Comportamiento "todos los…"
| Regla | Estado | Notas |
|-------|--------|-------|
| Cambios uniformes por tipo | [x] | Sin Rotar 90°, títulos centrados aplicados de forma uniforme |

### Save/Load y escena
| Regla | Estado | Notas |
|-------|--------|-------|
| Reconstrucción por referencia (lista instancias) | [x] | `_activar_lista_edificios`, `instancias_recien_anadidas` |
| Reconstrucción diferida desde WorldGenerator | [x] | `_reconstruir_edificios_deferred` |
| BuildingManager = fuente fiable del conteo | [x] | `get_placed_building_count` usa BuildingManager |

### Menú INFRAESTRUCTURA y dim
| Regla | Estado | Notas |
|-------|--------|-------|
| Oscurecer + ocultar red y tiles al abrir | [x] | `aplicar_dim_menu_edificios` |
| Tiles/red ocultos al elegir ítem dropdown | [x] | `_menu_edificios_abierto` mantiene dim |
| Restaurar solo al cerrar panel | [x] | `_quitar_aislamiento_visual` |

### Puntos NO TOCAR
| Punto | Estado | Notas |
|-------|--------|-------|
| Save/Load edificios, reconstrucción | [x] | Sin modificaciones |
| UI edificios (sin Rotar 90°, etc.) | [x] | Respeta "no tocar" |
| Menú INFRAESTRUCTURA dim | [x] | Respeta "no tocar" |
| Edificios fantasma (scale 1.0, Y respetada) | [x] | construction_manager actualiza solo X/Z |

---

## 2. CUMPLIMIENTO DE ARQUITECTURA (10_ARCHITECTURE.md)

### Separación simulación ↔ visualización
| Aspecto | Estado | Evidencia |
|---------|--------|-----------|
| Lógica no depende de nodos visuales | [x] | EnergyFlow entrega numéricamente; PulseVisual es opcional |
| Flujo numérico independiente del visual | [x] | `register_flow` → `EnergyFlow._entregar` → `recibir_energia_numerica` |
| Visuales solo representan estado | [x] | `spawn_pulse_visual` solo si `MOSTRAR_VISUAL_PULSO` |

### Managers centrales
| Manager | Estado | Notas |
|---------|--------|-------|
| GridManager centralizado | [x] | Registro de celdas, validación |
| EnergyManager centralizado | [x] | Flujos, `remove_flows_from_source`, etc. |
| BuildingManager centralizado | [x] | `register/unregister_building`, usado por save/load |

### Edificios NO se comunican directamente
| Aspecto | Estado | Notas |
|---------|--------|-------|
| Building → Manager | [x] | Registro, reporte de estado |
| Building ↔ Building | [x] | No hay llamadas directas entre edificios |
| Energía vía EnergyManager | [x] | Todos los flujos pasan por EnergyManager |

### EnergyManager maneja todos los flujos
| Aspecto | Estado | Notas |
|---------|--------|-------|
| register_flow central | [x] | Siphon, Compressor, Prism, Merger, God Siphon |
| Flujo numérico | [x] | EnergyFlow entrega a `recibir_energia_numerica` |

---

## 3. CÓDIGO PROBLEMÁTICO ENCONTRADO

### 3.1 `area_entered` para grupo "Pulsos" (legacy)

| Campo | Valor |
|-------|-------|
| **Archivos** | compressor.gd, constructor.gd, merger.gd, hadron_factory.gd, prism_logic.gd |
| **Líneas** | 64-70 (compressor), 115-119 (constructor), 61-66 (merger), 53-60 (hadron_factory), 100-103 (prism) |
| **Descripción** | Handlers `area_entered` reciben energía de nodos en grupo "Pulsos". Según 11_ENERGY_SYSTEM.md deben solo "limpiar pulsos huérfanos". PulseVisual está en grupo "PulseVisual" y no tiene colisión, por lo que este código es efectivamente legacy/muerto. Compressor y Constructor además *reciben* energía del área (posible doble entrega si existieran pulsos físicos). |
| **Regla violada** | 10_ARCHITECTURE: simulación debe ser numérica; no depender de nodos físicos |
| **Severidad** | Baja (código muerto, no afecta actualmente) |
| **Solución propuesta** | Eliminar handlers `area_entered` para "Pulsos" o reducir a `area.queue_free()` sin recibir energía. Documentar como legacy si se mantiene. |

---

### 3.2 Debug logging en producción

| Campo | Valor |
|-------|-------|
| **Archivos** | void_generator.gd, save_system.gd |
| **Líneas** | void_generator: 4-17, 117-120, 131-134, 194; save_system: 7-19, 54-61, 71-96, etc. |
| **Descripción** | `_void_dbg` y `_debug_log` escriben a `res://.cursor/debug.log` cada 60 frames (void) o en cada guardado/carga. No están condicionados a `GameConstants.DEBUG_MODE`. |
| **Regla violada** | 2_TASKLIST: "Revisar logs de debug — Reducir o condicionar a DEBUG_MODE antes de demo" |
| **Severidad** | Media |
| **Solución propuesta** | Envolver todas las llamadas a `_void_dbg` y `_debug_log` en `if GameConstants.DEBUG_MODE`. |

---

### 3.3 `print()` sin condicionar a DEBUG_MODE

| Campo | Valor |
|-------|-------|
| **Archivos** | construction_manager.gd, main_game_3d.gd, save_system.gd, tech_tree.gd, etc. |
| **Líneas** | ~59 ocurrencias en 15 archivos |
| **Descripción** | Muchos `print()` de log (guardado, carga, colocación, etc.) se ejecutan siempre. 2_TASKLIST pide condicionar a DEBUG_MODE antes de demo. |
| **Regla violada** | 2_TASKLIST prioridad P |
| **Severidad** | Media |
| **Solución propuesta** | Condicionar prints informativos: `if GameConstants.DEBUG_MODE: print(...)`. Mantener solo prints de error crítico sin condicionar. |

---

### 3.4 Posible duplicación en `_procesar_clic_central`

| Campo | Valor |
|-------|-------|
| **Archivo** | construction_manager.gd |
| **Líneas** | 332-402 |
| **Descripción** | Lógica duplicada para clonar GodSiphon vs otros edificios (DEBUG_MODE vs modo normal). Tres bloques muy similares. |
| **Regla violada** | Mantenibilidad |
| **Severidad** | Baja |
| **Solución propuesta** | Extraer función auxiliar `_clonar_edificio_desde_suelo(edificio, nombre)` para reducir duplicación. |

---

### 3.5 Inconsistencia en obtención de `MapaPrincipal`

| Campo | Valor |
|-------|-------|
| **Archivos** | hadron_factory.gd, void_generator.gd, constructor.gd |
| **Líneas** | hadron: 195; void: varios; constructor: 210 |
| **Descripción** | `get_tree().get_first_node_in_group("MapaPrincipal")` vs `get_tree().current_scene.find_child("GridMap")` vs `GameConstants.get_scene_root_for(self)`. Patrones distintos para el mismo propósito. |
| **Regla violada** | Consistencia, mantenibilidad |
| **Severidad** | Baja |
| **Solución propuesta** | Unificar uso de `GameConstants.get_scene_root_for(self)` o `get_tree().get_first_node_in_group("MapaPrincipal")` según contexto. |

---

### 3.6 Función `get_placed_building_count` en TechTree vs BuildingManager

| Campo | Valor |
|-------|-------|
| **Archivo** | tech_tree.gd |
| **Líneas** | 127-159 |
| **Descripción** | TechTree implementa `get_placed_building_count` con búsqueda recursiva en el árbol. Según 0_REGLAS y 12_API_MANAGERS, BuildingManager es la fuente fiable. TechTree podría delegar en BuildingManager si este expusiera el conteo por tipo. |
| **Regla violada** | 0_REGLAS: "BuildingManager es la fuente fiable del conteo" |
| **Severidad** | Media |
| **Solución propuesta** | Añadir `BuildingManager.get_placed_building_count(building_name)` y que TechTree lo use. |

---

### 3.7 Redundancia en `spawn_pulse_visual`

| Campo | Valor |
|-------|-------|
| **Archivos** | compressor.gd, siphon_logic.gd, prism_logic.gd, merger.gd, god_siphon.gd |
| **Líneas** | Ej: compressor 94-95 |
| **Descripción** | Se comprueba `if EnergyManager.MOSTRAR_VISUAL_PULSO:` antes de llamar a `spawn_pulse_visual`, que ya comprueba lo mismo internamente. |
| **Regla violada** | DRY |
| **Severidad** | Baja |
| **Solución propuesta** | Eliminar la comprobación externa; `spawn_pulse_visual` es idempotente. |

---

## 4. OPTIMIZACIONES POSIBLES

### Rendimiento
- **PulseValidator.haces_activos**: Usa `Array`. Para muchos edificios, `has()` es O(n). Considerar `Dictionary` o `HashSet` si el número de edificios crece.
- **void_generator `_process`**: Lógica compleja cada frame; evaluar si puede ejecutarse cada N frames o solo cuando cambie estado.
- **Logs cada 60 frames** en void_generator: Deshabilitar en producción (ver 3.2).

### Mantenibilidad
- **Código duplicado** en clonado de edificios (construction_manager): Extraer helper.
- **Patrones de acceso al mapa** incoherentes: Unificar (ver 3.5).
- **Funciones largas**: `_procesar_clic_central` (~70 líneas), `_guardar_a_ruta` (~170 líneas), `_mostrar_popup_guardar` (~60 líneas). Considerar subdivisión.

### Bugs potenciales
- **Void Generator**: Si `get_tree().get_first_node_in_group("MapaPrincipal")` devuelve null en carga diferida, podría fallar. Verificar flujo de carga.
- **ConstructionManager gestionar_clic_izquierdo**: Si el edificio no tiene `desconectar_sifon`, no se desregistraría de BuildingManager. Todos los edificios actuales lo tienen; mantener en checklist al añadir nuevos.

---

## 5. MÉTRICAS

| Métrica | Valor |
|---------|-------|
| Archivos GDScript totales | 33 (excl. .uid) |
| Líneas aprox. código | ~4800+ |
| Warnings en código | No ejecutado; revisar con Godot Editor |
| Funciones > 50 líneas | ~6 (guardar/cargar, popups, void, construction clic central) |
| TODOs sin resolver | 4 (tutorial_manager.gd) |
| `print()` sin DEBUG_MODE | ~59 |
| Handlers legacy "Pulsos" | 5 edificios |

### Detalle TODOs (tutorial_manager.gd)
- Línea 96: Añadir highlight al icono de Siphon en HUD
- Línea 120: Añadir highlight al icono de Compressor en HUD
- Línea 130: Detectar cuando se crea la primera energía comprimida
- Línea 164: Verificar si está conectado al siphon

---

## 6. RESUMEN EJECUTIVO

**Cumplimiento global:** Bueno. Las reglas universales y la arquitectura se respetan en los flujos principales. Los problemas detectados son en su mayoría de mantenibilidad, legado o preparación para demo (logs).

**Prioridad de acciones sugeridas:**
1. **Alta:** Condicionar logs de debug a `DEBUG_MODE` (3.2, 3.3) antes de demo.
2. **Media:** Centralizar `get_placed_building_count` en BuildingManager (3.6).
3. **Baja:** Limpiar handlers legacy "Pulsos" (3.1), redundancia en spawn_pulse_visual (3.7), refactor de `_procesar_clic_central` (3.4).

---

## 7. PRÓXIMOS PASOS SUGERIDOS

1. Aprobar o rechazar cada cambio propuesto.
2. Ejecutar PASO 2 (Optimización) cambio por cambio tras aprobación.
3. Ejecutar TEST_CHECKLIST (6.5 colocación, 10.3 save 20+) antes de considerar T1 cerrado.
4. Antes de demo itch.io: condicionar todos los prints y logs a DEBUG_MODE.
