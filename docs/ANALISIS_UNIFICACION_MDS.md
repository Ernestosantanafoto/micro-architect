# Análisis y unificación: MDs actuales vs Nuevos MDs

**Fecha:** 2025-02-02  
**Objetivo:** Comparar documentación en `docs/` y `docs/Nuevos MDs/`, identificar duplicados, redefiniciones e inconsistencias, y producir una visión unificada.

---

## 1. Resumen ejecutivo

| Documento       | En Nuevos MDs | Duplicados | Redefiniciones | Novedades principales | Decisión   |
|----------------|---------------|------------|----------------|------------------------|------------|
| README.md      | Sí            | Estructura índice | ROADMAP/FUTURE/ARCH descripciones | Fecha 2025-02-02, orden lectura con FUTURE_PLAN | Fusionar   |
| ARCHITECTURE.md| Sí            | Principios 1-3 | Estado actual vs objetivo (tabla T1/T2) | LOD semántico, Velocidad global, Grids anidados, “Al añadir tier” | Fusionar   |
| PROJECT_STATE.md | Sí          | Concepto, sistemas, bugs | Era “Tier 1”, bloques reorganizados | 4 Eras, save/load, prismas, Void, null-safety, próximo en 3 pasos | Fusionar   |
| ROADMAP.md     | Sí            | Bloques 1-4 completados | Base v0.5, título v0.6+ | Bloques 5-8 (estabilización, prep T2, contenido T2, polish T2) | Sustituir  |
| FUTURE_PLAN.md | Sí            | Progresión energía→ADN | Fases cortas → 4 tiers/eras | Escalas 1→3→9→27, LOD, velocidad global, referentes, riesgos, prestige | Sustituir  |
| API_MANAGERS.md| Sí            | Contenido API igual | Formato (espacios, negritas) | “Fabricador Hadrónico” en implementados | Fusionar   |
| ENERGY_SYSTEM.md | Sí          | Arquitectura, componentes, tipos | Ninguna sustancial | Sección “Extensión futura (Tier 2+)” | Fusionar   |
| FILE_PROTOCOL.md | Sí           | Idéntico en contenido | Ninguna | Formato ligeramente distinto | Mantener   |
| NOTAS_DESARROLLO.md | Sí       | Idéntico | Ninguna | Sin negritas en nuevo | Mantener   |

---

## 2. Conceptos duplicados

- **Índice de documentación:** Misma estructura en README (Planificación, Arquitectura, UX, Calidad) en ambos.
- **Principios de arquitectura:** Separación simulación/visual, managers centrales, energía numérica (ARCHITECTURE).
- **API de managers:** GridManager, EnergyManager, EnergyFlow, BuildingManager con las mismas funciones (API_MANAGERS).
- **Sistema de energía:** Mismo flujo Emisor → register_flow → EnergyFlow → recibir_energia_numerica (ENERGY_SYSTEM).
- **Protocolo de archivos:** Nomenclatura snake_case y estructura scripts/scenes (FILE_PROTOCOL).
- **Flujo “hasta mañana”:** Commit + push al cerrar sesión (NOTAS_DESARROLLO).

---

## 3. Conceptos redefinidos

- **ROADMAP:** De “v0.4 → v0.5+” y foco “Electrones” a “v0.5 → v0.6+” y foco en “T2” (estabilización, demo, Tier 2).
- **FUTURE_PLAN:** De fases cortas (Estabilización, Electrones, Protones, Átomos) a **4 eras/tiers** (Cuántica, Subatómica, Atómica, Molecular) con escalas 1→3→9→27 y LOD.
- **ARCHITECTURE:** “Modelo objetivo” y “Estado actual vs objetivo” pasan a “Modelo implementado” y tabla “Actual (T1) vs Objetivo (T2+)” con velocidad, LOD, MultiMesh.
- **PROJECT_STATE:** “Próximo paso” de “Bloque 4.2 Edificio Electrón” a “Estabilizar T1 → demo itch → Tier 2 foundation”; “Fabricador Hadrón” → “Fabricador Hadrónico” en nuevo.
- **README:** Descripción de FUTURE_PLAN de “fases (Electrones, Protones…)” a “4 tiers/eras, escalas 1→3→9→27, LOD semántico, análisis de referentes”.

---

## 4. Inconsistencias detectadas

- **Nombre del edificio:** “Fabricador Hadrón” (docs actuales, código) vs “Fabricador Hadrónico” (Nuevos MDs). **Decisión:** Unificar en **“Fabricador Hadrón”** en docs (coherente con `hadron_factory`, RECETAS y HUD) y dejar claro que es el mismo edificio; en ANALISIS se acepta “Hadrónico” como variante narrativa si se prefiere en texto largo.
- **Estado de bugs:** En actual, “Crítico” con ítem “Estado visual ≠ estado lógico”; en nuevo ese ítem no aparece y bugs se agrupan en “Menor” y “Pendiente de verificar”. **Decisión:** Mantener ítem de “visual opcional pendiente” en sección menor/pendiente para no perder la idea.
- **Referencias a EnergyManager:** En ARCHITECTURE antiguo se cita “EnergyManager.spawn_pulse_visual()”; en nuevo a veces solo “register_flow”. Misma API; unificar redacción a “register_flow + opcional spawn_pulse_visual”.

---

## 5. Nuevas ideas o enfoques (solo en Nuevos MDs)

- **4 tiers/eras:** Cuántica (T1), Subatómica (T2), Atómica (T3), Molecular (T4) con escalas 1×1, 3×3, 9×9, 27×27.
- **LOD semántico:** Misma simulación; representación según zoom (nodos reales → bloques compactos → puntos de luz → invisibles).
- **Velocidad global:** ×1/×4/×16/×40 con accumulator; afecta a todo el juego; Condensador de Tiempo desbloquea velocidades.
- **Grids anidados:** Cada celda de tier N = 3×3 celdas del tier N-1; GridManager multi-escala.
- **FUTURE_PLAN ampliado:** Referentes (Factorio, DSP, Shapez 2, etc.), riesgos técnicos/diseño, sistema de prestige (Quantum Seeds, Nucleon Cores, Atomic Bonds), roadmap de implementación por fases v0.5–v1.0.
- **ROADMAP en bloques 5–8:** Estabilización v0.5 (save/load, colocación, testing, demo itch.io), preparación técnica T2 (SimulationManager, LOD prototipo, UI velocidad), contenido T2 (Electrón, Condensador, Acelerador), polish T2 (LOD, blueprints).
- **PROJECT_STATE:** “Era actual: Tier 1 — Fase Cuántica”, mejoras recientes (save/load, prismas, Void Generator, null-safety), próximo paso en 3 puntos.
- **ENERGY_SYSTEM:** Párrafo “Extensión futura (Tier 2+)” (speed_multiplier, nuevos tipos de recurso).
- **API_MANAGERS:** Fabricador Hadrónico en la lista de implementantes de `recibir_energia_numerica`.

---

## 6. Criterios de unificación aplicados

1. **No eliminar** los MDs antiguos como referencia: `docs/Nuevos MDs/` se conserva.
2. **Unificación en `docs/`:** Los archivos en la raíz de `docs/` pasan a ser la versión consolidada (visión unificada).
3. **Terminología:** Se mantiene “Fabricador Hadrón” en títulos y listas de edificios para alineación con código/HUD; en prosa se puede usar “Fabricador Hadrónico” si se desea.
4. **Fusionar** cuando ambos aportan: README, ARCHITECTURE, PROJECT_STATE, API_MANAGERS, ENERGY_SYSTEM.
5. **Sustituir** cuando el nuevo es evolución clara y completa: ROADMAP, FUTURE_PLAN.
6. **Mantener** cuando son idénticos o casi: FILE_PROTOCOL, NOTAS_DESARROLLO.

---

## 7. Documentos sin versión en Nuevos MDs

Estos archivos **no** tienen equivalente en `docs/Nuevos MDs/` y se dejan como están en `docs/`:

- POLISH_PLAN.md  
- REFACTORING_PLAN.md  
- TEST_CHECKLIST.md  
- TUTORIAL_SCRIPT.md  
- UI_MOCKUPS.md  

No se ha aplicado ningún cambio por este análisis; si en el futuro se añaden versiones “nuevas” de estos, se puede repetir el mismo proceso de comparación y unificación.

---

*Este análisis sirve como registro de la comparación y de las decisiones de unificación. La documentación unificada está en los archivos correspondientes de `docs/`.*
