# 🏗️ Arquitectura del Proyecto

**Principios fundamentales para el desarrollo del juego**

---

## 🎯 Principios Fundamentales

### 1. Separación Simulación ↔ Visualización

**Regla de Oro:**
> La lógica del juego NUNCA debe depender de nodos visuales
```
❌ MAL: EnergyPulse (nodo 3D) → detecta colisión → Compressor actúa
✅ BIEN: EnergyManager calcula → Compressor recibe dato → Visual se actualiza
```

**Consecuencia:**
- La simulación corre con números puros
- Los visuales solo representan el estado
- Si un visual desaparece antes de tiempo → no afecta la lógica

**Verificación (visuales opcionales):**
- **Pulsos (bolas):** `EnergyManager.spawn_pulse_visual()` solo se llama si `MOSTRAR_VISUAL_PULSO`; la entrega de energía es siempre `EnergyManager.register_flow()` → `EnergyFlow._entregar()` → `recibir_energia_numerica()`. Sin visual, la lógica sigue igual.
- **Haces (beams):** `beam_emitter.dibujar_haz()` solo dibuja cilindros; no entrega energía. La entrega es numérica (EnergyFlow). `recibir_luz_instantanea()` en prismas actualiza solo dirección/color del haz dibujado, no la lógica de flujo.
- **Dónde se spawnean visuales:** siphon_logic, god_siphon, prism_logic, compressor, merger (spawn_pulse_visual + dibujar_haz en cada uno). En todos, `register_flow` / flujo numérico es independiente del visual.

---

### 2. Managers Centrales

**Arquitectura recomendada:**
```
GridManager       → Qué hay en cada celda, validación de colocación
EnergyManager     → Flujos de energía (números, no nodos)
BuildingManager   → Registro de edificios activos
```

**Comunicación:**
```
Building → Manager (registrarse, reportar estado)
Manager → Building (callbacks, actualizar estado)

❌ Building ↔ Building (nunca directamente)
```

---

### 3. Sistema de Energía (Numérico)

**Modelo implementado:**
```gdscript
# Clase pura de datos
class EnergyFlow:
    var from: Building
    var to: Building
    var amount: float = 10.0
    var tick_rate: float = 1.0
    var timer: float = 0.0
    
    func update(delta):
        timer += delta
        if timer >= tick_rate:
            to.receive_energy(amount)
            timer = 0.0
            # Opcional: trigger visual
```

Ver `ENERGY_SYSTEM.md` para detalle completo.

---

## 🔭 Arquitectura Multi-Tier

### 4. LOD Semántico

El juego usa 4 tiers de escala creciente (1→3→9→27). El estilo visual **nunca cambia** (cubos, haces, partículas). Solo cambia la resolución de detalle según el nivel de zoom.

**Regla:** Desde la vista de Tier N:

| Tier relativo | Representación | Tecnología |
|---------------|----------------|------------|
| Tier N (actual) | Nodos reales (mallas, colisiones, haces) | Nodos Godot |
| Tier N-1 | Bloques compactos de color estático | MultiMesh |
| Tier N-2 | Puntos de luz | GPUParticles3D / Sprites |
| Tier N-3+ | Invisibles | No renderizar |

**Principio:** El LOD solo afecta renderizado. La simulación es idéntica independientemente de la representación visual.

### 5. Velocidad Global del Juego

La velocidad es **GLOBAL**: afecta a todo el juego simultáneamente. No hay velocidades independientes por tier.

- Velocidad ×1: T1 cómodo | T2 muy lento | T3 casi parado  
- Velocidad ×4: T1 rápido | T2 cómodo | T3 muy lento  
- Velocidad ×16: T1 frenético | T2 rápido | T3 cómodo  

La simulación usa un accumulator con velocidad global (ver `FUTURE_PLAN.md` y ROADMAP Bloque 6).

### 6. Grids Anidados

Cada tier opera sobre un grid que agrupa celdas del tier anterior:

- T1: 1×1 (unidad base)
- T2: 3×3 de T1 = 1 celda T2
- T3: 3×3 de T2 = 9×9 de T1 = 1 celda T3
- T4: 3×3 de T3 = 27×27 de T1 = 1 celda T4

El GridManager debe soportar consultas en cualquier escala (multi-escala) cuando se implemente T2+.

---

## 🔄 Flujo de Trabajo

### Al añadir un nuevo edificio

1. Crear escena `.tscn` (visual)
2. Crear script de lógica (extiende base de edificio)
3. Registrar en `BuildingManager` en `_ready()`
4. Implementar `recibir_energia_numerica()` si es receptor
5. Registrar en `GameConstants.RECETAS`
6. Registrar en `placement_logic` con restricción de tile
7. **NO comunicarse directamente con otros edificios**

---

### Al modificar mecánicas:

1. Cambiar SOLO la lógica (managers)
2. Verificar que funciona con `print()` / debugger
3. Actualizar visuales si es necesario
4. Nunca mezclar ambos pasos

### Al añadir un nuevo tier

1. Definir escala de grid (factor ×3)
2. Crear LOD para tier anterior (MultiMesh / puntos)
3. Añadir edificios del nuevo tier
4. Implementar Condensador de Tiempo (desbloquea velocidad)
5. Actualizar F1/F2/tutorial
6. Profiling de rendimiento obligatorio

---

## 📏 Reglas de Oro

1. **Nada existe si no está documentado**
2. **Los edificios NO se comunican directamente**
3. **La simulación manda, el render obedece**
4. **Nunca mezclar lógica con nodos visuales**
5. **Preferir sistemas aburridos pero claros**
6. **Si algo "ya se arreglará después" → parar**
7. **LOD semántico: misma simulación, diferente representación**
8. **Escala ×3 constante entre tiers**

---

## 🎯 Estado Actual vs Objetivo

| Aspecto | Actual (T1) | Objetivo (T2+) |
|---------|-------------|-----------------|
| Energía | Datos numéricos ✅ | Datos numéricos ✅ |
| Comunicación | Building → Manager ✅ | Building → Manager ✅ |
| Validación | Centralizada ✅ | Multi-escala (GridManager T2) |
| Escalabilidad | ~200 edificios | 1000+ con LOD + chunking |
| Velocidad | ×1 fija | ×1/×4/×16/×40 GLOBAL con accumulator |
| Renderizado | Nodos individuales | MultiMesh + LOD semántico |

---

## 📚 Documentos Relacionados

- `docs/README.md` — Índice de documentación
- `PROJECT_STATE.md` — Estado general
- `ENERGY_SYSTEM.md` — Sistema energía detallado
- `API_MANAGERS.md` — API de managers
- `FUTURE_PLAN.md` — Visión completa de 4 tiers
- `ROADMAP.md` — Tareas actuales
