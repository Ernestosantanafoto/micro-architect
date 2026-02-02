# 📚 Documentación - Micro Architect

Índice de todos los documentos del proyecto.  
**Última revisión:** 2025-01-31

---

## 🗺️ Planificación y estado

| Documento | Para qué |
|-----------|----------|
| **ROADMAP.md** | Lista de tareas por bloques (bugs → UX → técnico → T2). Fuente principal de "qué hacer ahora". |
| **PROJECT_STATE.md** | Estado actual: versión, bugs, sistemas funcionando, próximo paso. |
| **FUTURE_PLAN.md** | Visión completa: 4 tiers/eras (Cuántica → Subatómica → Atómica → Molecular), escalas 1→3→9→27, LOD semántico, análisis de referentes, roadmap largo plazo. |
| **RECETAS.md** | Coste de fabricación (recursos + tiempo) y cómo desbloquear cada edificio. |
| **COSAS_POR_HACER.md** | Checklist proactiva: tareas típicas de juegos de gestión/fábrica que aún no están en el ROADMAP. |
| **NOTAS_DESARROLLO.md** | Convenciones: commit + push cuando el usuario diga "hasta mañana". |

---

## 🏗️ Arquitectura y sistemas

| Documento | Para qué |
|-----------|----------|
| **ARCHITECTURE.md** | Principios: simulación vs visual, managers, flujo numérico, LOD semántico, grids anidados, arquitectura multi-tier. |
| **ENERGY_SYSTEM.md** | Sistema de energía: EnergyManager, EnergyFlow, tipos de recurso. |
| **API_MANAGERS.md** | API de GridManager, EnergyManager, BuildingManager. |
| **FILE_PROTOCOL.md** | Convenciones de nombres y carpetas (snake_case, scripts/, scenes/). |

---

## 🎨 UX y contenido

| Documento | Para qué |
|-----------|----------|
| **POLISH_PLAN.md** | Plan de pulido UI/UX (mayormente completado). |
| **REFACTORING_PLAN.md** | Migración a sistema numérico (✅ completado, referencia histórica). |
| **UI_MOCKUPS.md** | Mockups e ideas de interfaz. |
| **TUTORIAL_SCRIPT.md** | Guion del tutorial para nuevos jugadores. |

---

## 🧪 Calidad y registro

| Documento | Para qué |
|-----------|----------|
| **TEST_CHECKLIST.md** | Checklist de pruebas manuales (T1 funcional). |
| **MD_ACTUALIZADO.md** | Registro por sesión de MDs actualizados; ver "Últimos actualizados". |

---

## 📖 Orden sugerido al leer

1. **ROADMAP.md** → Qué está hecho y qué sigue.
2. **PROJECT_STATE.md** → Estado actual y bugs.
3. **FUTURE_PLAN.md** → Visión de 4 tiers y análisis de referentes.
4. **ARCHITECTURE.md** + **ENERGY_SYSTEM.md** → Cómo funciona por dentro.

---

## Nota sobre unificación

La documentación en esta carpeta es la **versión unificada** (feb 2025) entre los MDs que había aquí y los de `docs/Nuevos MDs/`. El análisis detallado (duplicados, redefiniciones, decisiones) está en **ANALISIS_UNIFICACION_MDS.md**. La carpeta `Nuevos MDs` se conserva como referencia de la evolución del proyecto.
