# 🗺️ Plan Futuro - Micro Architect

**Base:** v0.4-alpha (energía numérica, protocolo archivos)  
**Última actualización:** 2025-01-31

---

## 🎯 Visión de Progresión

```
energía → quarks → protones/neutrones → átomos → moléculas → ADN
   ✅        ✅              ⏳              ⏳         ⏳         ⏳
```

- **✅ Hecho:** Siphons, Prismas, Compressor, Merger → Quarks (Up/Down)
- **⏳ Pendiente:** Electrones, Protones, Neutrones, átomos...

---

## 📋 Fase 1: Estabilización (Corto plazo)
 
### Bugs menores
- [x] Haces visuales cortados en prismas (HAZ_OFFSET_ORIGEN)
- [x] Salidas de mergers (posición/visual)
- [x] Verificar que visuales NO afectan lógica (ARCHITECTURE.md)

### Pulido UX
- [x] Tutorial básico (primer Siphon → primer Quark) — hecho en v0.4 Polish
- [x] Guía F1 + Recetario F2 — hecho en v0.4 Polish
- [x] Feedback visual al colocar edificios (pop + shake)
- [x] Mejorar menús (transiciones, feedback, versión)

### Técnico
- [x] Unificar fuentes de escenas (RECETAS + HUD_CATEGORIAS en HUD)
- [x] Eliminar `scenes/deprecated/` y `scripts/deprecated/` (ROADMAP 3.2)

---

## 📋 Fase 2: Electrones (v0.5)

| Tarea | Esfuerzo | Descripción |
|-------|----------|-------------|
| Nuevo edificio "Electrón" | Medio | Consume Quarks Up/Down, produce Electrones |
| Nuevo recurso `Electron` | Bajo | Tipo en GameConstants, color, flujo |
| Integrar en cadena | Medio | Merger/Constructor → Electrón |
| Visuales | Bajo | Esfera pequeña, color distinto |

---

## 📋 Fase 3: Protones / Neutrones (v0.6)

| Tarea | Esfuerzo | Descripción |
|-------|----------|-------------|
| Fusión Up+Down+Up → Protón | Alto | Lógica de combinación |
| Fusión Up+Down+Down → Neutrón | Alto | Similar a protón |
| Nuevo edificio "Núcleo" | Alto | Acepta quarks, emite protones/neutrones |
| Balanceo | Medio | Cantidades, tiempos, recetas |

---

## 📋 Fase 4: Átomos (v0.7+)

| Tarea | Esfuerzo | Descripción |
|-------|----------|-------------|
| Combinación Protón+Neutrón+Electrón → Átomo | Muy alto | Nueva mecánica de fusión |
| Tabla periódica simplificada | Alto | H, He, C, O... |
| Objetivo final | - | Moléculas, ADN (visión larga plazo) |

---

## 📁 Referencias

| Doc | Contenido |
|-----|-----------|
| `PROJECT_STATE.md` | Estado actual, bugs, métricas |
| `ENERGY_SYSTEM.md` | Sistema de energía numérica |
| `API_MANAGERS.md` | API de managers |
| `FILE_PROTOCOL.md` | Convenciones de archivos |
| `ARCHITECTURE.md` | Principios de arquitectura |

---

## 📝 Notas

- Priorizar estabilidad antes de features nuevas
- Documentar decisiones al añadir edificios
- Mantener protocolo de archivos (`docs/FILE_PROTOCOL.md`)
