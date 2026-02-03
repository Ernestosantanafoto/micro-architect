# 🎮 Micro Architect - Estado del Proyecto

**Última actualización:** 2025-01-31  
**Versión:** 0.5-alpha  
**Reglas y no-tocar:** Ver [0_REGLAS_UNIVERSALES.md](0_REGLAS_UNIVERSALES.md)  
**Godot:** 4.x  
**Era actual:** Tier 1 — Fase Cuántica

---

## 🎯 Concepto del Juego

Juego de gestión de recursos y fábrica que simula la construcción de materia desde su forma más fundamental:

**Progresión:**
```
energía → quarks → protones/neutrones → átomos → moléculas → ADN
```

**4 Eras de juego** con escala creciente (ver `8_FUTURE_PLAN.md`):
- Tier 1 — Cuántica (1×1, ×1) ← **ACTUAL**
- Tier 2 — Subatómica (3×3, ×4)
- Tier 3 — Atómica (9×9, ×16)
- Tier 4 — Molecular (27×27, ×40)

**Mecánicas Core:**
- Grid procedural con losetas especiales (energía/gravedad)
- Cadena de producción sin combate
- Energía como moneda y recurso de transformación

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
- Fabricador Hadrón (quarks → protones/neutrones)
- Constructor (crafteo de edificios)
- Void Generator (eliminar terreno)

### UI / UX
- HUD categorizado (ENERGÍA | QUARKS | EDIFICIOS) con colores
- Barra de categorías (SIFONES, PRISMAS, MANIPULA, CONSTR); botón **INFRAESTRUCTURA** (dropdown de categorías)
- Menú INFRAESTRUCTURA: oscurece todo, oculta red y tiles; conteo de edificios colocados desde BuildingManager; tiles/red permanecen ocultos al elegir ítem hasta cerrar
- God Siphon UI (sliders energía/frecuencia, vista previa)
- Constructor UI (título centrado, grid de iconos, hotkeys 1-9)
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

## ✅ Mejoras Recientes (v0.5) — NO TOCAR salvo petición explícita

*(Ver [0_REGLAS_UNIVERSALES.md](0_REGLAS_UNIVERSALES.md) para lista de puntos no tocar.)*

- **Fabricador Hadrón:** Quarks → Protones/Neutrones (2U+1D, 1U+2D). Recibe pulsos, añade productos al inventario.
- **Colocación de edificios:** HUD con `mouse_filter = IGNORE` para que los clics lleguen al mapa. Botón SELECCIÓN desactivado por defecto.
- **Save/Load:** Edificios se guardan/cargan; reconstrucción por referencia (`_activar_lista_edificios`), diferida desde WorldGenerator; registro en BuildingManager/GridManager; Constructor `check_ground` diferido y `_recuperar_estado_guardado` con guarda `is_inside_tree`. TechTree persistente en SaveSystem.
- **Prismas corregidos:** Solo se colocan en vacío (TILE_VACIO); placement_logic por grupo.
- **Void Generator:** Lógica real de borrado de tiles.
- **Pulido estético:** StyleBox en HUD, paneles unificados, tooltips. UIs edificios: sin Rotar 90° / "Abrir clic derecho"; títulos centrados (CONSTRUCTOR, FUSIONADOR); Merger con selector quarks y purga por fila.
- **Menú INFRAESTRUCTURA (ex RECURSOS):** Botón renombrado a INFRAESTRUCTURA; al abrir: oscurecer todo + ocultar red y tiles; tiles/red siguen ocultos al elegir ítem; conteo desde BuildingManager. Restaurar solo al cerrar.
- **F1/F2 actualizados:** Fabricador Hadrón, Protón, Neutrón. TechTree actualizado.
- **Análisis null-safety:** beam_emitter, god_siphon, save_system, world_generator, inventory_button, hud.

---

## 🐛 Bugs Conocidos

### Menor
- Haces visuales ligeramente cortados en prismas (HAZ_OFFSET_ORIGEN 0.25)
- Salidas de mergers: from_pos con offset ajustable
- Menús popup: recuadro gris en algunos entornos (dejado como mejora futura)

### Pendiente de verificar
- Estado visual ≠ estado lógico del sistema (visuales opcionales pendientes)
- Merger buffer al levantar/soltar (dejado en pausa, revisar más adelante)

---

## 📋 Inventario de bugs para T1 (priorizado)

Bloqueante para considerar **T1 funcional**: crítico + altos verificados. Menores y pendientes no bloquean.

| Prioridad | Bug | Estado |
|-----------|-----|--------|
| **Crítico** | Tecnologías desbloqueadas no persisten al cargar | ✅ Corregido: SaveSystem guarda/carga TechTree |
| **Alto** | Save/load con partidas complejas (20+ edificios) no verificado | Pendiente verificación manual |
| **Alto** | Colocación de todos los edificios en tiles correctos no verificada | Pendiente: test por tipo y en bordes (TEST_CHECKLIST) |
| **Menor** | Haces visuales cortados en prismas | HAZ_OFFSET_ORIGEN 0.25; verificar en juego |
| **Menor** | Salidas de mergers (from_pos) | Ajuste 0.5*dir aplicado; verificar si persiste |
| **Menor** | Recuadro gris en menús popup | Mejora futura; no bloqueante |
| **Pendiente** | Estado visual ≠ estado lógico | No bloqueante |
| **Pendiente** | Merger buffer al levantar/soltar | En pausa; decisión de diseño |

---

## 📌 Pausa / Recordar para Futuro

- Merger buffer: se mantiene al mover (no se resetea en desconectar_sifon). Revisar si se quiere otra lógica más adelante.
- God Siphon: solo disponible en DEBUG_MODE
- Menús popup recuadro gris: mejora futura dev/test

---

## 📊 Métricas

| Métrica | Valor |
|---------|-------|
| Tiempo desarrollo | ~2 semanas |
| Archivos | ~95 |
| Líneas código | ~4.800+ |
| Edificios | 8 tipos |
| Versión | v0.5-alpha |

---

## ✅ Criterios T1 funcional (definition of done)

- [x] **Tech persistente:** Desbloqueos F2 persisten tras guardar y cargar (SaveSystem + TechTree).
- [ ] **Save/Load 20+:** Partida con 20+ edificios se guarda y carga; posiciones/rotaciones y producción correctas (verificar con TEST_CHECKLIST 10.3).
- [ ] **Colocación:** Todos los tipos solo en tiles permitidos; rotación y bordes verificados (TEST_CHECKLIST 6.5).
- [ ] **Checklist:** TEST_CHECKLIST ejecutado; bugs críticos resueltos; resto documentado.
- [ ] **Docs:** ROADMAP 5.1–5.3 marcados cuando verificación completada.

---

## 🎯 Próximo Paso

1. **Estabilizar Tier 1:** Ejecutar TEST_CHECKLIST (6.5, 10.3), verificar bugs restantes
2. **Demo en itch.io:** Publicar Tier 1 jugable para feedback real
3. **Tier 2 foundation:** Escala 3×3, accumulator de tiempo, electrones

Ver `docs/4_ROADMAP.md` para tareas detalladas.  
Ver `docs/8_FUTURE_PLAN.md` para visión completa de 4 tiers.  
Índice de docs: `docs/3_README.md`.
