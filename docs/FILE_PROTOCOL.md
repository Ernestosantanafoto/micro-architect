# Protocolo de Archivos

Convenciones de organización y nombres para el proyecto MicroArchitect.

## Nomenclatura

| Tipo | Regla | Ejemplo |
|------|-------|---------|
| Scripts (.gd) | snake_case | `constructor_ui.gd`, `main_game_3d.gd` |
| Escenas (.tscn) | snake_case | `constructor_ui.tscn`, `main_game_3d.tscn` |
| Carpetas | snake_case | `scripts/`, `scenes/` |
| Recursos | snake_case | `tileset_resources.tres` |

## Estructura de carpetas

```
scripts/          # Todos los scripts GDScript
├── autoload/     # Singletons (game_constants, save_system...)
├── buildings/    # Lógica de edificios
├── components/   # Componentes reutilizables (beam_emitter)
├── managers/     # Managers globales
├── ui/           # Scripts de interfaz
├── visual/       # Feedback visual (pulse_visual)
└── world/        # Cámara, generador, escena principal

scenes/           # Solo escenas .tscn
├── buildings/
├── ui/
└── world/

scenes/deprecated/   # Escenas obsoletas (energy_pulse.tscn)
scripts/deprecated/  # Scripts obsoletos (energy_pulse.gd)
```

## Reglas

1. **Scripts siempre en scripts/**: Las escenas referencian scripts por `res://scripts/...`. No hay scripts dentro de `scenes/`.
2. **Escenas en scenes/**: Solo archivos .tscn y recursos de escena.
3. **Deprecados**: Archivos que ya no se usan van a `*_deprecated/` para conservarlos sin romper referencias.
4. **Consistencia**: Nombre de escena = nombre de script principal. `constructor_ui.tscn` → `constructor_ui.gd`.
