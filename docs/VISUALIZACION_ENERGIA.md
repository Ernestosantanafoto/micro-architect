# Visualización de energía (haz + bola)

**Documento vivo:** describe cómo funciona la visualización de energía en el juego y se actualiza cuando cambian las mecánicas.

- Estado actual: **2026-02-04**
- Relacionado: [11_ENERGY_SYSTEM.md](11_ENERGY_SYSTEM.md) (flujo numérico), [10_ARCHITECTURE.md](10_ARCHITECTURE.md) (simulación vs visual).

---

## Estado actual (cómo funciona ahora)

### Los tres elementos

| Elemento | Qué es | Dónde vive |
|----------|--------|------------|
| **Haz (beam)** | Línea de luz (segmentos 3D) | Se redibuja cada frame en `BeamEmitter.dibujar_haz()` |
| **Bola (pulso visual)** | Esfera que se mueve de A a B | `PulseVisual`, nodo hijo de la escena |
| **Flujo numérico** | Datos: origen, destino, cantidad, tiempo | `EnergyFlow` en `EnergyManager.energy_flows` |

El haz es solo visual. La energía real la lleva el flujo numérico. La bola es un visual opcional.

---

### 1. Haz (línea de luz)

- **Cuándo se dibuja:** Cada frame, en `_process`, cada edificio con haz activo llama a `beam_emitter.dibujar_haz(...)`.
- **Comportamiento:** Borra todos los segmentos y vuelve a dibujar la línea desde el origen hasta el primer edificio que “bloquea” (ray/point query en el grid) o hasta la longitud máxima.
- **Conclusión:** El haz **no** se propaga cuadro a cuadro; es una línea **estática por frame**: cada frame se recalcula y se dibuja de nuevo de inicio a fin.

---

### 2. Bola (pulso visual)

- **Cuándo se crea:** El edificio obtiene la ruta con `beam_emitter.obtener_ruta_y_objetivo(...)` y solo llama a `EnergyManager.spawn_pulse_visual(..., path_waypoints)` si `path.size() >= 2`. Los pulsos solo aparecen donde hay haz dibujado.
- **Duración:** Con waypoints: `longitud_total_del_path / PULSO_VELOCIDAD_VISUAL`. Sin waypoints: `distancia(from, to) / PULSO_VELOCIDAD_VISUAL` (mínimo `FLUJO_DURACION_BASE` = 0.5 s).
- **Movimiento:** Con waypoints, la bola recorre el path celda a celda; sin waypoints, lerp lineal. Al `progress >= 1.0` → `queue_free()`.
- **Colisiones:** La bola **no** colisiona con nada. No “toca” el edificio para desaparecer; desaparece porque **se cumple su tiempo de vida** (progress ≥ 1). Es un lerp lineal origen → destino.
- **Seguridad:** Si el edificio origen se destruye o rota, o deja de tener haz activo en PulseValidator, la bola se destruye antes (`queue_free()`).
- **Estela (trail):** Opcional. Si `GameConstants.TRAIL_PULSO_HABILITADO` es true, se dibuja una línea detrás con las últimas `TRAIL_PULSO_NUM_PUNTOS` posiciones.

---

### 3. Flujo numérico (EnergyFlow)

- **Cuándo se crea:** En el mismo disparo que la bola: `EnergyManager.register_flow(from, to, amount, tipo, color)`. Si no se pasa `duration`, se usa la **misma fórmula**: `duration = distancia(from, to) / PULSO_VELOCIDAD_VISUAL`.
- **Actualización:** En `EnergyManager._process(delta)` cada flujo hace `flow.update(delta)` (suma delta al timer); cuando `timer >= duration` se llama `_entregar()` (entrega numérica al edificio destino) y se elimina el flujo.
- **Conclusión:** La entrega no depende de que la bola “llegue”; es un **timer fijo**: tras `duration` segundos se entrega.

---

### Sincronización: ¿cuadro a cuadro o por tiempo?

- **No** hay sincronización cuadro a cuadro con el haz: el haz se redibuja entero cada frame; la bola va en línea recta de `from_pos` a `to_pos`.
- **Sí** hay sincronización **por duración** entre bola y entrega: ambos usan la misma `duration` y arrancan en el mismo frame, así que la bola llega visualmente y el flujo entrega **casi a la vez** (mismo tiempo de vida).
- En resumen: es una mecánica de **“tiempo de vida fijo”**; la bola no “choca” con el edificio para desaparecer ni para disparar la entrega.

---

### Constantes y configuración

| Constante / variable | Ubicación | Uso |
|----------------------|-----------|-----|
| `PULSO_VELOCIDAD_VISUAL` | GameConstants | 1.0 – Unidades/seg para duración del movimiento de la bola y del flujo |
| `TRAIL_PULSO_HABILITADO` | GameConstants | false – Activar estela detrás de la bola |
| `TRAIL_PULSO_NUM_PUNTOS` | GameConstants | 12 – Número de posiciones recientes para la estela |
| `MOSTRAR_VISUAL_PULSO` | EnergyManager | true – Activar/desactivar esferas de pulso |
| `FLUJO_DURACION_BASE` | EnergyManager | 0.5 – Duración mínima cuando distancia ≈ 0 |

En modo debug (`GameConstants.DEBUG_MODE`), el path del haz se dibuja como línea amarilla en `BeamEmitter._dibujar_path_debug()` para verificar que coincide con los segmentos y con la ruta del pulso.

---

## Progreso / cambios de mecánica

*(Se irá actualizando cuando se modifiquen las mecánicas de haz, bola o flujo.)*

| Fecha | Cambio | Notas |
|-------|--------|--------|
| 2026-02-04 | Documento creado | Estado actual descrito arriba. |
| 2026-02-04 | Path y validación | BeamEmitter expone `obtener_ruta_haz` / `obtener_ruta_y_objetivo`; spawn de pulso solo si path ≥ 2; bola recorre waypoints. |
| 2026-02-04 | Trail y debug | Trail opcional (TRAIL_PULSO_*); en DEBUG_MODE se dibuja el path del haz. |

---

## Ideas para futuros cambios (referencia)

- **Entrega “al tocar”:** sincronizar la entrega con el evento “bola llegó” (p. ej. cuando `progress >= 1` en el visual) o dar colisión a la bola (menos alineado con separación simulación/visual).
- Cualquier cambio de **cuándo** se entrega la energía debe hacerse en `EnergyFlow`/`EnergyManager`; el cambio de **cómo se mueve o cuándo desaparece la bola** es solo en `PulseVisual` y no afecta la lógica de juego.
