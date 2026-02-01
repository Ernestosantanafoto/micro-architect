# 🎮 Micro Architect - Estado del Proyecto

**Última actualización:** 2025-01-31  
**Versión:** 0.5-alpha  
**Godot:** 4.x

### ✅ Mejoras recientes (estética y pulido)
- **Fabricador Hadrón:** Edificio que convierte quarks en nucleones (Protón: 2U+1D; Neutrón: 1U+2D). Recibe pulsos, añade productos al inventario.
- **Colocación de edificios:** HUD con `mouse_filter = IGNORE` para que los clics lleguen al mapa. Botón SELECCIÓN desactivado por defecto.
- **Pulido HUD:** Barra recursos superior (StyleBox dedicado, bordes, espaciado). Paneles inferior izq/der con estilos unificados. Barra categorías con tooltips actualizados.
- **Menús popup:** Eliminado FondoDetector de ConstructorUI (recuadro gris corregido). Estilos consistentes en God Siphon y Constructor.
- **F1/F2:** Fabricador Hadrón, Proton, Neutron añadidos a ayuda y recetario. TechTree actualizado.

### 📌 Pausa / recordar para futuro
- **Merger buffer al levantar/soltar:** Dejado en pausa. Comportamiento actual: se mantiene el buffer al mover (no se resetea en `desconectar_sifon`). Revisar si se quiere otra lógica más adelante.

---

## 🎯 Concepto del Juego

Juego de gestión de recursos y fábrica que simula la construcción de materia desde su forma más fundamental:

**Progresión:**
```
energía → quarks → protones/neutrones → átomos → moléculas → ADN
```

**Mecánicas Core:**
- Grid procedural con losetas especiales (energía/gravedad)
- Cadena de producción sin combate
- Energía como moneda y recurso de transformación

---

## ✅ Sistemas Funcionando

- [x] Grid / Rejilla
- [x] Colocación de estructuras
- [x] Restricciones por losetas
- [x] Generación procedural del mapa
- [x] Siphons (extractores de energía)
- [x] Prismas (rectos y 90°)
- [x] Compressor (10:1 energía)
- [x] Merger (fusión de energías)
- [x] Factories (producción por recetas)
- [x] Inventario
- [x] Void Generators (limpiar terreno)
- [x] Sistema visual (haces, pulsos)
- [x] Menús (principal, guardar/cargar)
- [x] Música de fondo
- [x] **Selección múltiple por arrastre:** Solo en casillas vacías, hold threshold, rectángulo fantasma azul, zoom dinámico (solo aleja), acciones R (reembolso) y ELIMINAR; modo activable/desactivable con botón SELECCIÓN (panel inferior izq.); botón ELIMINAR en esquina inferior derecha.
- [x] **Fabricador Hadrón (v0.5):** Convierte quarks en protones/neutrones. Recetas: Protón 2U+1D, Neutrón 1U+2D. UI flotante U:X D:Y, barra de progreso. F1/F2 y TechTree actualizados.

---

## 🐛 Bugs Conocidos

### Crítico
- [x] ~~Pulsos de energía continúan aunque el emisor rote~~ (migrado a sistema numérico)
- [x] ~~Pulsos persisten aunque el emisor desaparezca~~ (migrado a sistema numérico)
- [ ] Estado visual ≠ estado lógico del sistema (visuales opcionales pendientes)

### Menor
- [x] ~~Haces visuales ligeramente cortados en prismas~~ (HAZ_OFFSET_ORIGEN 0.25)
- [x] ~~Problemas en salidas de mergers~~ (from_pos 0.5*dir)

---

## ✅ Arquitectura de Energía (MIGRADO)

**Sistema numérico implementado** – ver `docs/ENERGY_SYSTEM.md`

- Energía fluye como datos (EnergyManager + EnergyFlow)
- Visuales opcionales (PulseVisual) sin afectar lógica
- Deprecated eliminado: `scenes/deprecated/` y `scripts/deprecated/` (energy_pulse) borrados en ROADMAP 3.2

---

## 📊 Métricas

- **Tiempo desarrollo:** ~1 semana
- **Archivos:** 95
- **Líneas código:** ~4,805
- **Edificios implementados:** 8 tipos (incl. Fabricador Hadrón)

---

## 🎯 Próximo Paso

**Bloques 1–3 completados.** Bugs menores, pulido UX y técnico (RECETAS unificado, deprecated eliminado, merger 3x1 footprint, starter pack, God Siphon solo DEV) aplicados.

**Siguiente:** Bloque 4.2 – Edificio Electrón (consumir quarks, producir Electron) si se desea extender la cadena. Ver **`docs/ROADMAP.md`**. Índice de docs: **`docs/README.md`**.
