# Documentación – Micro Architect

**Última revisión:** 2025-01-31

---

## Empieza aquí

| Objetivo | Documento |
|----------|------------|
| **Reglas universales y puntos no tocar** (asistente y equipo) | [**0_REGLAS_UNIVERSALES.md**](0_REGLAS_UNIVERSALES.md) |
| **Seguir el progreso** (estado, criterios T1, próximo paso) | [**1_PROGRESO.md**](1_PROGRESO.md) |
| **Ver qué hacer ahora** (tasklist concreta) | [**2_TASKLIST.md**](2_TASKLIST.md) |

Con 0 (reglas), 1 y 2 tienes claro qué respetar, el estado y las tareas. El resto es referencia o detalle.

**Convención de nombres:** Los MD llevan prefijo numérico (1_, 2_, …) para verse en orden de prioridad en GitHub: primero lo que miras cada día, luego cuando toque, al final referencia para el asistente. **Mantener este estilo** en cualquier MD nuevo que se añada a `docs/`.

---

## Estructura en 3 niveles (orden = número del archivo)

### Nivel 0 – Referencia obligatoria (asistente)
- [0_REGLAS_UNIVERSALES.md](0_REGLAS_UNIVERSALES.md) — Reglas universales (colores, unidades, "todos los…") y puntos no tocar (save/load, UI, menú INFRAESTRUCTURA)

### Nivel 1 – Mirar a diario
- [1_PROGRESO.md](1_PROGRESO.md) — Estado y próximo paso
- [2_TASKLIST.md](2_TASKLIST.md) — Qué hacer ahora (to-do)

### Nivel 2 – Cuando toque
- [4_ROADMAP.md](4_ROADMAP.md) — Plan por bloques (5 → 6 → 7 → 8)
- [5_PROJECT_STATE.md](5_PROJECT_STATE.md) — Bugs, sistemas funcionando, versión
- [6_TEST_CHECKLIST.md](6_TEST_CHECKLIST.md) — Pruebas manuales T1
- [7_COSAS_POR_HACER.md](7_COSAS_POR_HACER.md) — Backlog (opciones, guardado, UX, audio)

### Nivel 3 – Referencia (para el asistente / consulta)
- [8_FUTURE_PLAN.md](8_FUTURE_PLAN.md) — Visión 4 tiers, escalas, referentes
- [9_RECETAS.md](9_RECETAS.md) — Costes y desbloqueos de edificios
- [10_ARCHITECTURE.md](10_ARCHITECTURE.md) — Principios (simulación vs visual, managers)
- [11_ENERGY_SYSTEM.md](11_ENERGY_SYSTEM.md) — Flujos numéricos, EnergyManager
- [12_API_MANAGERS.md](12_API_MANAGERS.md) — API GridManager, EnergyManager, BuildingManager
- [13_FILE_PROTOCOL.md](13_FILE_PROTOCOL.md) — Nombres y carpetas (snake_case, scripts/, scenes/)
- [14_NOTAS_DESARROLLO.md](14_NOTAS_DESARROLLO.md) — Commit + push al decir "hasta mañana"
- [15_POLISH_PLAN.md](15_POLISH_PLAN.md) — Plan de pulido UI/UX (referencia)
- [16_REFACTORING_PLAN.md](16_REFACTORING_PLAN.md) — Migración numérica (histórico)
- [17_UI_MOCKUPS.md](17_UI_MOCKUPS.md) — Mockups e ideas de interfaz
- [18_TUTORIAL_SCRIPT.md](18_TUTORIAL_SCRIPT.md) — Guion del tutorial

---

## Documentos archivados

En [docs/archive/](archive/) están los documentos que ya no se usan como referencia activa:
- **Nuevos MDs/** — Versión anterior unificada (la canónica está en la raíz de `docs/`)
- **ANALISIS_UNIFICACION_MDS.md** — Análisis de la unificación (registro)
- **MD_ACTUALIZADO.md** — Registro por sesión de MDs actualizados
