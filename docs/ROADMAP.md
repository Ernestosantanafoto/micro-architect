# 🗺 ROADMAP - Micro Architect v0.5 → v0.6+

**Objetivo:** Un solo documento para ir abordando poco a poco.  
**Base:** v0.5-alpha (Tier 1 funcional, Fabricador Hadrón, save/load corregido)  
**Última actualización:** 2025-01-31 15:02

---

## 📌 Cómo usar este doc

- Trabaja por bloques en orden (o el que prefieras).
- Marca `[x]` al completar cada ítem.
- Si algo bloquea, déjalo y sigue con el siguiente.
- Actualiza "Estado actual" al final cuando termines una sección.

---

## ✅ BLOQUES COMPLETADOS

### ~~BLOQUE 1: Bugs menores (estabilidad)~~ ✅
- 1.1 Haces visuales cortados en prismas ✅
- 1.2 Salidas de mergers (posición/visual) ✅
- 1.3 Verificar que visuales NO afectan lógica ✅

### ~~BLOQUE 2: Pulido UX~~ ✅
- 2.1 Feedback visual al colocar (pop/shake) ✅
- 2.2 Mejorar menús (transiciones, versión) ✅

### ~~BLOQUE 3: Técnico / cleanup~~ ✅
- 3.1 Unificar RECETAS vs menu_data ✅
- 3.2 Limpiar deprecated (energy_pulse eliminado) ✅

### ~~BLOQUE 4: Nucleones~~ ✅
- 4.2 Fabricador Hadrón ✅
- 4.3 F1/F2 actualizados ✅

---

## 🔴 BLOQUE 5: Estabilización v0.5 (pre-demo)

Objetivo: Tier 1 sin bugs, listo para publicar demo en itch.io.

### 5.1 Bugs de save/load
- [x] Edificios no se guardaban (save_system corregido)
- [x] Zoom de cámara no se restauraba (world_generator corregido)
- [x] Sifones no funcionaban tras cargar (game_tick + esta_construido)
- [x] Tecnologías desbloqueadas persisten tras cargar (TechTree integrado en SaveSystem)
- [ ] Verificar save/load con partidas complejas (20+ edificios) — TEST_CHECKLIST Parte 10.3

### 5.2 Bugs de colocación
- [x] Prismas se colocaban como God Siphons (placement_logic corregido)
- [x] Void Generator era copia de construction_manager (reescrito)
- [ ] Verificar colocación de todos los edificios en sus tiles correctos — TEST_CHECKLIST Parte 6.5
- [ ] Test de rotación + colocación en bordes del mapa — TEST_CHECKLIST Parte 6.5

### 5.3 Testing integral
- [ ] Ejecutar TEST_CHECKLIST.md completo (v0.5: Partes 1–11, incl. 6.5 colocación y 10.3 save 20+)
- [ ] Documentar bugs encontrados
- [ ] Arreglar bugs críticos
- [ ] Re-test hasta pasar todo

### 5.4 Preparar demo
- [ ] Configurar export para web (HTML5) o Windows
- [ ] Crear página en itch.io
- [ ] Escribir descripción del juego
- [ ] Screenshots / GIF del gameplay
- [ ] Publicar como "alpha - buscando feedback"

Archivos: save_system.gd, placement_logic.gd, world_generator.gd,
siphon_logic.gd, prism_logic.gd, void_generator.gd, main_game_3d.gd.

---

## 🟠 BLOQUE 6: Preparación técnica para Tier 2

Objetivo: Sentar las bases técnicas antes de añadir contenido T2.

### 6.1 Fixed timestep con accumulator
- [ ] Crear `SimulationManager` (autoload) con accumulator pattern
- [ ] Migrar game_tick de main_game_3d a SimulationManager
- [ ] Variable `speed_multiplier` (1.0 por defecto)
- [ ] Verificar que ×1 funciona idéntico al sistema actual
- [ ] Test: cambiar a ×4 manualmente, verificar estabilidad

```gdscript
# Patrón objetivo
const DT = 1.0 / 60.0
var accumulator: float = 0.0
var speed: float = 1.0

func _process(delta):
    accumulator += delta * speed
    while accumulator >= DT:
        emit_signal("simulation_tick")
        accumulator -= DT
```

### 6.2 Sistema de escala / grids anidados
- [ ] Diseñar cómo el grid 3×3 se superpone al grid 1×1
- [ ] Prototipo: pintar grid T2 como overlay al hacer zoom out
- [ ] Definir umbrales de zoom para cambio de escala visual
- [ ] Probar snap de edificios T2 al grid de 3 unidades

### 6.3 LOD semántico — prototipo
- [ ] Crear representación "bloque compacto" para un edificio T1
- [ ] MultiMesh test: renderizar 100 bloques de color simultáneamente
- [ ] Definir umbrales de zoom para swap de representación
- [ ] Verificar que la simulación no se afecta al cambiar LOD

### 6.4 UI de velocidad GLOBAL
- [ ] Botón en HUD: ×1 (por defecto, única opción hasta Condensador)
- [ ] Al construir Condensador I: aparece botón ×1 / ×4
- [ ] Hotkey para alternar velocidad (sugerido: Tab o +/-)
- [ ] Indicador visual de velocidad actual en pantalla
- [ ] Efecto visual sutil al cambiar velocidad (flash, distorsión)
- [ ] Tooltip: "Acelera todo el juego. T1 irá a ×4, T2 a velocidad normal."

Archivos nuevos: scripts/managers/simulation_manager.gd,
scripts/managers/lod_manager.gd.

---

## 🟡 BLOQUE 7: Tier 2 — Contenido (v0.6)

Objetivo: Implementar la Fase Subatómica jugable.

### 7.1 Recurso Electrón
- [ ] Añadir "Electron" en GameConstants (tipo, color cyan, icono)
- [ ] Registrar en GlobalInventory
- [ ] Añadir al HUD (nueva categoría PARTÍCULAS o extender QUARKS)
- [ ] Actualizar F1/F2

### 7.2 Generador de Electrones
- [ ] Crear escena electron_generator.tscn
- [ ] Script electron_generator.gd (consume quarks → produce electrones)
- [ ] Registrar en RECETAS, placement_logic (TILE_VACIO)
- [ ] Visual: haz cyan, partícula pequeña
- [ ] Test: cadena completa Quarks → Electrones

### 7.3 Condensador de Tiempo I
- [ ] Crear escena time_condenser.tscn (3×3 en grid T2 = 9×9 en T1)
- [ ] Script time_condenser.gd (consume energía continua)
- [ ] Al activarse: habilita botón ×4 en UI
- [ ] Visual: efecto de distorsión temporal
- [ ] Test: alternar ×1/×4, verificar estabilidad

### 7.4 Acelerador de Partículas
- [ ] Crear escena particle_accelerator.tscn (2×2 en T2)
- [ ] Script: combina protones + neutrones + electrones → átomos
- [ ] Recetas: H (1p+1e), He (2p+2n+2e)
- [ ] UI interna para seleccionar qué átomo producir
- [ ] Nuevos recursos: Hydrogen, Helium en GameConstants

### 7.5 Integrar cadena T2 completa
- [ ] Flujo: Quarks → Electrones → Acelerador → Átomos
- [ ] Actualizar F1 (nuevos edificios, recursos, controles)
- [ ] Actualizar F2 (tech tree con Tier 2)
- [ ] Actualizar tutorial si es necesario

---

## 🟢 BLOQUE 8: Tier 2 — Polish (v0.7)

### 8.1 LOD completo T1↔T2
- [ ] Fábricas T1 → bloques compactos al alejar zoom
- [ ] Zoom continuo con transición suave
- [ ] MultiMesh para bloques compactos
- [ ] Verificar rendimiento con 200+ entidades T1

### 8.2 Blueprints básicos
- [ ] Guardar layout de edificios como blueprint
- [ ] Cargar y colocar blueprint
- [ ] Librería de blueprints del jugador

### 8.3 Balance y pacing
- [ ] Ajustar costos y tiempos de producción T2
- [ ] Playtest completo T1+T2
- [ ] Ajustar según feedback

---

## 📊 Estado actual del ROADMAP

| Bloque | Estado | Notas |
|--------|--------|-------|
| 1. Bugs menores | ✅ | HAZ_OFFSET, mergers, visuales |
| 2. Pulido UX | ✅ | Pop/shake, menús, versión |
| 3. Técnico | ✅ | RECETAS unificado, deprecated eliminado |
| 4. Nucleones | ✅ | Fabricador Hadrón completo |
| 5. Estabilización v0.5 | 🔄 En curso | Save/load y prismas corregidos |
| 6. Prep técnica T2 | ⏳ Pendiente | Accumulator, LOD, grid anidado |
| 7. Tier 2 contenido | ⏳ Pendiente | Electrones, Condensador, Acelerador |
| 8. Tier 2 polish | ⏳ Pendiente | LOD, blueprints, balance |

---

## 📁 Referencias rápidas

| Doc | Para qué |
|-----|----------|
| docs/README.md | Índice de toda la documentación |
| PROJECT_STATE.md | Estado del juego, bugs, versión |
| FUTURE_PLAN.md | Visión completa 4 tiers (1→3→9→27) |
| ARCHITECTURE.md | Reglas de arquitectura |
| ENERGY_SYSTEM.md | Flujos numéricos, EnergyManager |
| API_MANAGERS.md | API de managers |
| NOTAS_DESARROLLO.md | Commit + push al decir "hasta mañana" |

Cuando termines un bloque, actualiza la tabla "Estado actual" y el **Última actualización** arriba.

---

## 🎯 Siguiente tarea

**Bloque 5** → Estabilizar v0.5, publicar demo T1.  
Después → Bloque 6 (preparación técnica T2) → Bloque 7 (contenido T2).
