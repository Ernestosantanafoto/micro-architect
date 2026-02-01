# 🎮 Micro Architect - Estado del Proyecto

**Última actualización:** 2025-02-01  
**Versión:** 0.4-alpha  
**Godot:** 4.x

### ⚠️ Conocidos (dev / test)
- **Menús popup (God Siphon, Constructor):** En algunos entornos puede verse un recuadro gris hasta el borde inferior de la pantalla. No afecta a la jugabilidad; dejado como mejora futura para dev/test.

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

---

## 🐛 Bugs Conocidos

### Crítico
- [x] ~~Pulsos de energía continúan aunque el emisor rote~~ (migrado a sistema numérico)
- [x] ~~Pulsos persisten aunque el emisor desaparezca~~ (migrado a sistema numérico)
- [ ] Estado visual ≠ estado lógico del sistema (visuales opcionales pendientes)

### Menor
- [ ] Haces visuales ligeramente cortados en prismas
- [ ] Problemas en salidas de mergers (detalles)

---

## ✅ Arquitectura de Energía (MIGRADO)

**Sistema numérico implementado** – ver `docs/ENERGY_SYSTEM.md`

- Energía fluye como datos (EnergyManager + EnergyFlow)
- Visuales opcionales (PulseVisual) sin afectar lógica
- `scenes/deprecated/energy_pulse.tscn` deprecado (ya no se usa)

---

## 📊 Métricas

- **Tiempo desarrollo:** ~1 semana
- **Archivos:** 95
- **Líneas código:** ~4,805
- **Edificios implementados:** 7 tipos

---

## 🎯 Próximo Paso

**Refactor + Polish UI aplicado.** Arquitectura de energía numérica estable; HUD, F1/F2, God Siphon/Constructor UI y tutorial básico completados.

Ver **`docs/FUTURE_PLAN.md`** para roadmap (electrones, protones, bugs menores) o **`docs/POLISH_PLAN.md`** para detalle del pulido.
