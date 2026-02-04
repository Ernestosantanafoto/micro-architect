# Cambios DEBUG_MODE - 2025-02-03

## Resumen

Todos los logs de desarrollo (`print`, `_void_dbg`, `_debug_log`, `_agent_log`) están condicionados a `GameConstants.DEBUG_MODE`.

**Excepciones:** Errores críticos → `push_error`, advertencias → `push_warning` (siempre visibles).

---

## Lista de archivos modificados

| Archivo | Cambios |
|---------|---------|
| `scripts/autoload/game_constants.gd` | Comentario en DEBUG_MODE (var se mantiene por toggle en runtime) |
| `scripts/buildings/void_generator.gd` | _void_dbg con early return; print DESTRUCCIÓN envuelto |
| `scripts/autoload/save_system.gd` | _debug_log con early return; prints envueltos; 6 push_error, 1 push_warning |
| `scripts/managers/construction_manager.gd` | 6 prints envueltos en DEBUG_MODE |
| `scripts/autoload/tech_tree.gd` | 2 prints envueltos |
| `scripts/world/main_game_3d.gd` | 10 prints envueltos; 3 push_error (SaveSystem no encontrado, ruta inexistente) |
| `scripts/ui/system_hud.gd` | 2 prints DEBUG-SAVE envueltos |
| `scripts/managers/hud_manager.gd` | 1 print envuelto |
| `scripts/world/world_generator.gd` | 1 print envuelto |
| `scripts/ui/god_siphon_ui.gd` | _agent_log con early return |
| `scripts/buildings/god_siphon.gd` | print ERROR → push_error |
| `scripts/ui/recipe_book.gd` | 1 print envuelto |

---

## push_error aplicados (siempre visibles)

- `[SAVE] No se pudo abrir el archivo para escritura`
- `[SAVE] No se pudo abrir el archivo` (cargar)
- `[SAVE] JSON inválido`
- `[SAVE] No se pudo obtener raíz de escena de juego`
- `[SAVE] No se encontró GridMap` (partida test)
- `[SAVE] No se pudo abrir archivo para escribir partida test`
- `[MAIN] SaveSystem no encontrado` (2 lugares)
- `[MAIN] No existe la ruta` (main_menu)
- `GodSiphon: No se encontró 'GodSiphonUI' en la escena`

## push_warning aplicado

- `[SAVE] Escena no encontrada: <ruta>` (al reconstruir edificios)

---

## Nota

`DEBUG_MODE` sigue siendo `var` (no `const`) para permitir el toggle con el botón DEBUG del panel sistema durante el juego.
