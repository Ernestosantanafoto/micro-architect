# ⚡ Sistema de Energía Numérico

**Estado:** ✅ Implementado (v0.4-alpha)

---

## Arquitectura

La energía fluye como **datos numéricos**, no como nodos físicos.

```
Emisor (Siphon/Compressor/Merger/Prism)
    → EnergyManager.register_flow(from, to, amount, tipo, color)
    → EnergyFlow (timer + duración)
    → Destino.recibir_energia_numerica(amount, tipo, origen)
```

---

## Componentes

### EnergyManager (Autoload)
- `register_flow(from, to, amount, tipo_recurso, color, duration?)` → EnergyFlow
- `spawn_pulse_visual(from_pos, to_pos, color)` → Visual opcional
- Señal: `energy_transferred(from, to, amount)` al completar flujo
- Constante: `MOSTRAR_VISUAL_PULSO = true` para activar/desactivar esferas

### EnergyFlow (RefCounted)
- Datos: from_building, to_building, amount, tipo_recurso, color, duration
- `update(delta)` → retorna false cuando entregó
- Duración calculada: `distancia / PULSO_VELOCIDAD_VISUAL` (velocidad constante)

### PulseVisual (opcional)
- Esfera que hace lerp de origen a destino
- Duración = distancia / velocidad (ver `PULSO_VELOCIDAD_VISUAL` en GameConstants)
- No afecta lógica, solo feedback visual
- **Detalle completo (haz + bola + sincronización):** [VISUALIZACION_ENERGIA.md](VISUALIZACION_ENERGIA.md)

---

## Tipos de Recurso

| Tipo | Color | Origen |
|------|-------|--------|
| Stability | Verde | Siphon (tile verde) |
| Charge | Magenta | Siphon (tile azul) |
| Compressed-Stability | Verde | Compressor |
| Compressed-Charge | Magenta | Compressor |
| Up-Quark | Amarillo | Merger |
| Down-Quark | Naranja | Merger |

---

## Flujo de Construcción

1. **Siphon** → dispara cada N ticks → `obtener_objetivo()` → `register_flow()` + `spawn_pulse_visual()`
2. **Compressor** → acumula 10 → dispara → mismo patrón
3. **Prism** → `recibir_energia_numerica()` → calcula rebote → reemite con `_color_por_tipo()`
4. **Merger** → fusiona Compressed-Stability + Compressed-Charge → emite Up-Quark o Down-Quark
5. **Constructor** → `recibir_energia_numerica()` → inventario interno → crafteo

---

## BeamEmitter.obtener_objetivo()

Retorna `{target: Node, impact_pos: Vector3}` o null.

- **impact_pos** = centro de la celda donde impacta el haz (no el centro del edificio)
- Útil para edificios anchos (Merger 3x1): el visual va al punto de impacto

---

## Deprecado / eliminado

- `scenes/deprecated/` y `scripts/deprecated/` (energy_pulse) – **eliminados** en ROADMAP 3.2
- `PulseValidator` – sigue activo por compatibilidad, pero no hay pulsos físicos
- Handlers `area_entered` para grupo "Pulsos" – legacy, limpian pulsos huérfanos si existieran

---

## Extensión futura (Tier 2+)

Cuando se implemente el sistema multi-tier:

- El EnergyManager procesará flujos de todos los tiers simultáneamente
- Los flujos de tiers superiores serán más lentos (partículas más pesadas)
- El `speed_multiplier` del SimulationManager afectará a todos los flujos
- Nuevos tipos de recurso: Electron, Hydrogen, Helium, etc.
- Ver `8_FUTURE_PLAN.md` para detalle de cada tier
