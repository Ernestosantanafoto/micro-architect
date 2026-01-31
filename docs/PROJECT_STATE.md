# 🎮 Micro Architect - Estado del Proyecto

**Última actualización:** 2025-01-31  
**Versión:** 0.3-alpha  
**Godot:** 4.x

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
- [ ] Pulsos de energía continúan aunque el emisor rote
- [ ] Pulsos persisten aunque el emisor desaparezca
- [ ] Estado visual ≠ estado lógico del sistema

### Menor
- [ ] Haces visuales ligeramente cortados en prismas
- [ ] Problemas en salidas de mergers (detalles)

---

## ⚠️ DECISIÓN ARQUITECTÓNICA PENDIENTE

**Problema identificado:** Sistema de energía física (nodos `energy_pulse.tscn`)

**Síntomas:**
- Acoplamiento simulación ↔ visualización
- Bugs dependientes del tiempo
- Difícil de escalar

**Solución recomendada:**
- Migrar a sistema numérico (valores en managers)
- Separar lógica de visuales
- Ver `docs/REFACTORING_PLAN.md`

---

## 📊 Métricas

- **Tiempo desarrollo:** ~1 semana
- **Archivos:** 95
- **Líneas código:** ~4,805
- **Edificios implementados:** 7 tipos

---

## 🎯 Próximo Paso

**NO añadir features nuevas** hasta estabilizar arquitectura base.

Ver: `docs/REFACTORING_PLAN.md`
