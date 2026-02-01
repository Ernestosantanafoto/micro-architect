# 📚 Documentación - Micro Architect

Índice de todos los documentos del proyecto. **Última revisión:** 2025-01-31

---

## 🗺️ Planificación y estado

| Documento | Para qué |
|-----------|----------|
| **ROADMAP.md** | Lista de tareas por bloques (bugs → UX → técnico → Electrones). Fuente principal de "qué hacer ahora". |
| **PROJECT_STATE.md** | Estado actual del juego: versión, bugs conocidos, sistemas funcionando, próximo paso. |
| **FUTURE_PLAN.md** | Visión a largo plazo: fases (Electrones, Protones, Átomos, ADN). |
| **NOTAS_DESARROLLO.md** | Convenciones: commit + push cuando el usuario diga "hasta mañana". |

---

## 🏗️ Arquitectura y sistemas

| Documento | Para qué |
|-----------|----------|
| **ARCHITECTURE.md** | Principios: simulación vs visual, managers, flujo de energía numérico. |
| **ENERGY_SYSTEM.md** | Sistema de energía: EnergyManager, EnergyFlow, tipos de recurso, deprecado eliminado. |
| **API_MANAGERS.md** | API de GridManager, EnergyManager, BuildingManager (funciones y parámetros). |
| **FILE_PROTOCOL.md** | Convenciones de nombres y carpetas (snake_case, scripts/, scenes/). |

---

## 🎨 UX y contenido

| Documento | Para qué |
|-----------|----------|
| **POLISH_PLAN.md** | Plan de pulido UI/UX: tareas por áreas (HUD, menús, F1, tutorial). Muchas ya hechas. |
| **REFACTORING_PLAN.md** | Plan de migración a sistema numérico (✅ completado). Referencia histórica. |
| **UI_MOCKUPS.md** | Mockups y ideas de interfaz. |
| **TUTORIAL_SCRIPT.md** | Guion del tutorial para nuevos jugadores. |

---

## 🧪 Calidad

| Documento | Para qué |
|-----------|----------|
| **TEST_CHECKLIST.md** | Checklist de pruebas manuales (controles, HUD, F1, colocación, guardado). |

---

## Orden sugerido al leer

1. **ROADMAP.md** → qué está hecho y qué sigue.
2. **PROJECT_STATE.md** → estado actual y bugs.
3. **ARCHITECTURE.md** + **ENERGY_SYSTEM.md** → cómo funciona el juego por dentro.
