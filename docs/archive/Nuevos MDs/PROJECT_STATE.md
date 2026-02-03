# 🎮 Micro Architect - Estado del Proyecto

**Última actualización**: 2025-02-02  
**Versión**: 0.5-alpha  
**Godot**: 4.x  
**Era actual**: Tier 1 — Fase Cuántica

---

## 🎯 Concepto del Juego

Juego de gestión de recursos y fábrica que simula la construcción de materia
desde su forma más fundamental:

**Progresión**:
```
energía → quarks → protones/neutrones → átomos → moléculas → ADN
```

**4 Eras de juego** con escala creciente (ver `FUTURE_PLAN.md`):
- Tier 1 — Cuántica (1×1, ×1) ← **ACTUAL**
- Tier 2 — Subatómica (3×3, ×4)
- Tier 3 — Atómica (9×9, ×16)
- Tier 4 — Molecular (27×27, ×40)

---

## ✅ Sistemas Funcionando

### Core
- Grid / Rejilla procedural con losetas especiales
- Colocación de estructuras con restricciones por loseta
- Sistema de energía numérico (EnergyManager + EnergyFlow)
- Cadena completa: Energía → Quarks → Protones / Neutrones
- Inventario (GlobalInventory)
- Save / Load (edificios, inventario, cámara)

### Edificios (8 tipos)
- Sifón (extractor de energía)
- Compresor (10:1)
- Prisma recto y angular (redirección de haces)
- Merger (fusión de energías → quarks)
- Fabricador Hadrónico (quarks → protones/neutrones)
- Constructor (crafteo de edificios)
- Void Generator (eliminar terreno)

### UI / UX
- HUD categorizado (ENERGÍA | QUARKS | EDIFICIOS) con colores
- Barra de categorías (SIFONES, PRISMAS, MANIPULA, CONSTR)
- God Siphon UI (sliders energía/frecuencia, vista previa)
- Constructor UI (grid de iconos, hotkeys 1-9)
- Panel de Ayuda F1 (4 pestañas: Recursos, Edificios, Controles, Objetivos)
- Recetario F2 (tech tree con desbloqueos)
- Tutorial básico (5 pasos)
- Menú principal (nuevo, cargar, salir)
- Hotkeys (R rotar, ESC cancelar, 0 God Siphon DEV, 1-9 edificios)
- Clic central (copiar edificio / colocar y mantener)
- Selección múltiple por arrastre
- Grid guía (pulso 50-100% + desvanecimiento por zoom)
- Feedback al colocar (pop/shake)

### Visual
- Haces de luz entre edificios
- Pulsos visuales opcionales (PulseVisual)
- Música de fondo

---

## ✅ Mejoras Recientes (v0.5)

- **Fabricador Hadrónico**: Quarks → Protones/Neutrones (2U+1D, 1U+2D)
- **Save/Load corregido**: Edificios se guardan/cargan correctamente
  - Búsqueda recursiva de Area3D en save_system
  - Zoom de cámara se restaura
  - Sifones se reactivan tras cargar (game_tick reconectado)
- **Prismas corregidos**: Solo se colocan en vacío (TILE_VACIO)
  - placement_logic separado por grupo
  - Eliminada función duplicada en prism_logic
- **Void Generator**: Implementado con lógica real de borrado de tiles
- **Pulido estético**: StyleBox en HUD, paneles unificados, tooltips
- **F1/F2 actualizados**: Fabricador Hadrónico, Protón, Neutrón añadidos
- **Análisis null-safety**: beam_emitter, god_siphon, save_system, etc.

---

## 🐛 Bugs Conocidos

### Menor
- Haces visuales ligeramente cortados en prismas (HAZ_OFFSET_ORIGEN 0.25)
- Salidas de mergers: from_pos con offset ajustable
- Menús popup: recuadro gris en algunos entornos (dejado como mejora futura)

### Pendiente de verificar
- Merger buffer al levantar/soltar (dejado en pausa, revisar más adelante)

---

## 📌 Pausa / Recordar para Futuro

- Merger buffer: se mantiene al mover (no se resetea en desconectar_sifon)
- God Siphon: solo disponible en DEBUG_MODE
- Menús popup recuadro gris: mejora futura dev/test

---

## 📊 Métricas

| Métrica | Valor |
|---------|-------|
| Tiempo desarrollo | ~2 semanas |
| Archivos | ~95 |
| Líneas código | ~4,800+ |
| Edificios | 8 tipos |
| Versión | v0.5-alpha |

---

## 🎯 Próximo Paso

1. **Estabilizar Tier 1**: Arreglar bugs restantes, testing completo
2. **Demo en itch.io**: Publicar Tier 1 jugable para feedback real
3. **Tier 2 foundation**: Escala 3×3, accumulator de tiempo, electrones

Ver `docs/ROADMAP.md` para tareas detalladas.  
Ver `docs/FUTURE_PLAN.md` para visión completa de 4 tiers.  
Índice de docs: `docs/README.md`.
