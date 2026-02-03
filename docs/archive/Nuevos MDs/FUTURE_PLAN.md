# 🗺 Plan Futuro - Micro Architect

**Base**: v0.5-alpha (Fase Cuántica funcional)  
**Última actualización**: 2025-02-02

---

## 🎯 Visión de Progresión

```
energía → quarks → protones/neutrones → átomos → moléculas → ADN
  ✅         ✅           ✅                ⏳         ⏳          ⏳
```

El jugador construye materia desde partículas fundamentales, experimentando
la escala del universo a través de **4 eras** que transforman espacio, tiempo
y complejidad de juego simultáneamente.

---

## 🏗 Sistema de 4 Tiers / Eras

### Principios de Diseño

Basados en análisis de Factorio, Satisfactory, DSP, Shapez 2, Mindustry,
ONI, Antimatter Dimensions, Universal Paperclips, Spore y Katamari Damacy:

1. **Transformación, no solo escala** — Cada tier cambia QUÉ hace el jugador
2. **Escala gradual** — Progresión 1→3→9→27 (factor ×3 constante)
3. **LOD semántico** — Fábricas anteriores se simplifican visualmente según zoom
4. **Simulación intacta** — El render cambia, la lógica nunca
5. **Prestige con propósito** — Las transiciones otorgan bonificaciones permanentes
6. **UI que crece** — La interfaz revela paneles nuevos por era (estilo A Dark Room)

### Escala espacial (corregida)

```
Tier 1:  1×1   (unidad base)
Tier 2:  3×3   (cada celda = 3×3 de Tier 1)     →  ×9
Tier 3:  9×9   (cada celda = 9×9 de Tier 1)     →  ×81
Tier 4: 27×27  (cada celda = 27×27 de Tier 1)   →  ×729
```

### Escala temporal

**Principio clave**: La velocidad es **GLOBAL** (afecta a todo el juego).
Los tiers superiores nacen inherentemente lentos porque las partículas más
pesadas se mueven más despacio. El jugador sube la velocidad global para que
el tier en el que trabaja se sienta a velocidad "cómoda" (~1x visual).

| Velocidad global | T1 (cuántico) | T2 (subatómico) | T3 (atómico) | T4 (molecular) |
|------------------|---------------|------------------|---------------|-----------------|
| ×1 | **Cómodo** | Muy lento | Casi parado | Parado |
| ×4 | Rápido | **Cómodo** | Muy lento | Casi parado |
| ×16 | Muy rápido | Rápido | **Cómodo** | Muy lento |
| ×40 | Frenético | Muy rápido | Rápido | **Cómodo** |

**Desbloqueo de velocidades**:

| Velocidad | Desbloqueada tras… |
|-----------|---------------------|
| ×1 | Siempre disponible |
| ×4 | Condensador de Tiempo I (Tier 2) |
| ×16 | Condensador de Tiempo II (Tier 3) |
| ×40 | Condensador de Tiempo III (Tier 4) |

**Experiencia del jugador**:
- Siempre juega a una velocidad visual similar a la del Tier 1 original
- Cuando sube la velocidad, los tiers inferiores "vuelan" en segundo plano
- Como los tiers inferiores están reducidos a bloques o puntos de luz (LOD),
  verlos acelerados no molesta — al contrario, refuerza la sensación de escala
- El jugador puede bajar la velocidad temporalmente si necesita ajustar
  fábricas de un tier inferior (hacer zoom in + bajar velocidad)

**Justificación física**: Las partículas más pesadas se mueven más lento
en el mundo real. Protones son ~2000× más masivos que electrones. Los átomos
son aún más lentos. Las moléculas, pesadísimas. El jugador experimenta
esta diferencia de escalas de tiempo de forma natural.

---

## 🔬 Tier 1 — Fase Cuántica ✅ (v0.5-alpha)

**Escala**: Grid 1×1, edificios 1×1 a 3×1  
**Velocidad**: ×1  
**Producción**: Energía → Quarks → Protones / Neutrones

| Edificio | Función | Tamaño |
|----------|---------|--------|
| Sifón | Extrae energía del vacío cuántico | 1×1 |
| Compresor | Comprime energía 10:1 | 1×1 |
| Prisma (recto/angular) | Redirige haces de luz | 1×1 |
| Merger | Fusiona energías comprimidas → quarks | 3×1 |
| Fabricador Hadrónico | Quarks → protones/neutrones | 3×1 |
| Constructor | Craftea edificios a partir de recursos | 1×1 |

**Rol del jugador**: Puzzle de colocación precisa. Cada celda importa.

**Milestone de transición a Tier 2**: Producir X protones Y neutrones estables
+ construir el Condensador de Tiempo I (alto costo energético continuo).

---

## ⚛️ Tier 2 — Fase Subatómica 🔜 (v0.6 – v0.7)

**Escala**: Grid 3×3 (1 celda T2 = 3×3 celdas T1)  
**Velocidad**: ×1 base → **×4 tras Condensador I**  
**Producción**: Protones + Neutrones + Electrones → Átomos simples (H, He)

### Concepto de escala

```
Tier 1:  [·][·][·]        Tier 2:  [███]
         [·][·][·]    →            (1 celda)
         [·][·][·]
```

Las fábricas de Tier 1 se ven como **bloques compactos coloreados** cuando
el jugador está en zoom de Tier 2. Hacer zoom in devuelve la vista detallada.

### Nuevos edificios

| Edificio | Función | Tamaño (T2) |
|----------|---------|-------------|
| Condensador de Tiempo I | Desbloquea velocidad ×4 | 3×3 (= 9×9 T1) |
| Generador de Electrones | Consume quarks → electrones | 1×1 |
| Acelerador de Partículas | Combina protones + neutrones + electrones → átomo | 2×2 |
| Estabilizador Atómico | Mantiene átomos coherentes | 1×1 |
| Canal de Partículas | Transporta partículas masivas entre zonas | 1×N |

### Condensador de Tiempo I

- **Costo**: Consumo continuo muy alto de energía comprimida
- **Mecánica**: Una vez construido, aparece botón de velocidad global en la UI
- **Desbloquea**: Velocidad ×4 (todo el juego se acelera)
- **Efecto**: Tier 2 pasa de "muy lento" a velocidad cómoda para el jugador
- **Efecto secundario**: Tier 1 corre a ×4 (acelerado, pero como está en LOD
  reducido se percibe como "fábricas cuánticas zumbando en segundo plano")
- **Visual**: Efecto de distorsión temporal alrededor del edificio
- **El jugador puede volver a ×1** si necesita hacer zoom in y ajustar
  fábricas de Tier 1 con precisión

### Nuevos recursos

| Recurso | Color | Origen |
|---------|-------|--------|
| Electrón | Cyan | Generador de Electrones |
| Hidrógeno (H) | Blanco | Acelerador (1p + 1e) |
| Helio (He) | Naranja claro | Acelerador (2p + 2n + 2e) |

**Rol del jugador**: Optimización de throughput. Diseñar rutas eficientes
para partículas más lentas y grandes. Primeras decisiones de layout macro.

**Milestone de transición a Tier 3**: Producir Z átomos de hidrógeno estables
+ construir Condensador de Tiempo II.

---

## 🌐 Tier 3 — Fase Atómica 🔮 (v0.8 – v0.9)

**Escala**: Grid 9×9 (1 celda T3 = 9×9 T1 = 3×3 T2)  
**Velocidad**: ×4 base → **×16 tras Condensador II**  
**Producción**: Átomos → Moléculas simples

### Visualización LOD

Desde zoom T3:
- Fábricas T1 → **puntos de luz** (color = tipo de producción)
- Fábricas T2 → **bloques compactos** con icono simplificado
- Fábricas T3 → **detalle completo** (cubos, haces, partículas)

### Nuevos edificios

| Edificio | Función | Tamaño (T3) |
|----------|---------|-------------|
| Condensador de Tiempo II | Desbloquea velocidad ×16 | 3×3 |
| Reactor de Fusión | Crea átomos pesados (C, N, O) | 2×2 |
| Enlazador Molecular | Une átomos en moléculas | 2×2 |
| Hub de Distribución | Logística entre zonas T3 | 1×1 |

### Mecánica de zonas

- El grid T3 se divide en zonas especializadas
- Cada zona puede contener múltiples fábricas T2 completas
- El transporte entre zonas usa Canales de Partículas pesados

### Nuevos recursos

| Recurso | Color | Origen |
|---------|-------|--------|
| Carbono (C) | Gris oscuro | Reactor (6p + 6n + 6e) |
| Nitrógeno (N) | Azul | Reactor (7p + 7n + 7e) |
| Oxígeno (O) | Rojo | Reactor (8p + 8n + 8e) |
| H₂O | Azul claro | Enlazador (2H + O) |
| CO₂ | Gris | Enlazador (C + 2O) |

**Rol del jugador**: Macro-gestión de zonas. Diseño de layouts regionales.

**Milestone de transición a Tier 4**: Producir moléculas orgánicas básicas
(aminoácidos) + construir Condensador de Tiempo III.

---

## 🧬 Tier 4 — Fase Molecular / ADN 🌟 (v1.0+)

**Escala**: Grid 27×27 (1 celda T4 = 27×27 T1 = 9×9 T2 = 3×3 T3)  
**Velocidad**: ×16 base → **×40 tras Condensador III**  
**Producción**: Moléculas → Aminoácidos → ADN

### Visualización LOD

Desde zoom T4:
- Fábricas T1 → **invisibles** (demasiado pequeñas)
- Fábricas T2 → **puntos de luz**
- Fábricas T3 → **bloques compactos**
- Fábricas T4 → **detalle completo**

### Objetivo Final: Construir ADN

Requiere ensamblar en secuencia:
1. Azúcares (ribosa, desoxirribosa) — a partir de C, H, O
2. Bases nitrogenadas (A, T, G, C) — a partir de C, H, O, N
3. Grupos fosfato — recurso especial
4. Ensamblaje en la secuencia correcta → doble hélice

### Mecánica de templates

Inspirada en "Make Anything Machine" de Shapez 2:
- El jugador diseña **templates de fábricas**
- Las fábricas pueden **auto-replicarse** siguiendo templates
- Blueprints permiten abstracción sin perder visibilidad

**Rol del jugador**: Arquitecto de sistemas. Diseñar fábricas que construyen fábricas.

---

## 👁 Sistema de LOD Semántico

El estilo visual **nunca cambia** (cubos, haces, partículas). Solo cambia la
**resolución de detalle** según el nivel de zoom:

| Nivel de zoom | Representación | Tecnología |
|---------------|----------------|------------|
| > 80% (cerca) | Nodos reales (mallas, colisiones, haces) | Nodos Godot |
| 30–80% (medio) | Bloques compactos de color estático | MultiMesh |
| < 30% (lejos) | Puntos de luz con color de producción | GPUParticles3D / Sprites |

### Reglas de LOD por tier relativo

Desde la vista de Tier N:
- Tier N → Detalle completo
- Tier N-1 → Bloques compactos
- Tier N-2 → Puntos de luz
- Tier N-3+ → Invisibles

### Principio de arquitectura

> "La simulación manda, el render obedece."

El LOD **solo afecta al renderizado**. La simulación de cada tier corre
idéntica independientemente de la representación visual. Los flujos de energía,
la producción de recursos y los estados de las máquinas son siempre datos
numéricos procesados por EnergyManager / BuildingManager.

---

## 📊 Sistema de Prestige

### Monedas por transición de tier

| Transición | Moneda | Efecto |
|------------|--------|--------|
| T1 → T2 | Quantum Seeds | +1% producción base T1 por unidad |
| T2 → T3 | Nucleon Cores | Desbloquea automatización avanzada |
| T3 → T4 | Atomic Bonds | Habilita templates y auto-replicación |

### Fórmulas de progresión

**Costo exponencial de edificios**:
```
Costo = Base × 1.15^(cantidad_construida)
```

**Moneda prestige al cambiar tier**:
```
Prestige = floor(√(Producción_Total_Tier / Threshold))
```

**Multiplicador por prestige**:
```
Multiplicador = 1 + (Prestige × 0.01)
```

### Qué persiste entre tiers

- ✅ Blueprints / diseños guardados
- ✅ Estadísticas históricas
- ✅ Achievements
- ✅ Moneda prestige del tier anterior
- ❌ Recursos físicos (se encapsulan en la nueva escala)
- ❌ Edificios individuales (pasan a ser LOD simplificado)

---

## ⚡ Arquitectura Técnica por Tier

### Tier 1 (actual)
- TileMap/GridMap normal
- Nodos individuales por edificio (< 1,000 entidades)
- Area3D con colisiones
- Señales de Godot para comunicación
- ✅ Suficiente para la escala actual

### Tier 2 (siguiente refactor)
- **Fixed timestep con accumulator** para velocidad variable
- Migrar entidades frecuentes a arrays de datos
- MultiMesh para visuales batch de ítems repetidos
- Object pooling para partículas dinámicas

```gdscript
# Patrón accumulator para velocidad GLOBAL
const DT = 1.0 / 60.0
var accumulator: float = 0.0
var speed: float = 1.0  # GLOBAL: ×1, ×4, ×16, ×40

func _process(delta: float):
    # La velocidad afecta a TODO el juego simultáneamente
    # Tier 1 a ×4 = rápido, Tier 2 a ×4 = cómodo, etc.
    accumulator += delta * speed
    while accumulator >= DT:
        simulate_step(DT)  # Simula TODOS los tiers a la vez
        accumulator -= DT
    render_interpolated(accumulator / DT)
```

### Tier 3 (refactor mayor)
- **Chunking obligatorio** (chunks de 16×16 recomendado)
- Virtualización: solo procesar visible + buffer
- MultiMesh generalizado para todos los LOD
- Evaluar GDExtension (C++) para simulación core

```gdscript
# Chunking básico
const CHUNK_SIZE = 16
var chunks: Dictionary  # Vector2i → ChunkData

func get_cell(x: int, y: int) -> int:
    var key = Vector2i(x / CHUNK_SIZE, y / CHUNK_SIZE)
    if key not in chunks:
        return 0
    return chunks[key].get_local(x % CHUNK_SIZE, y % CHUNK_SIZE)
```

### Tier 4 (optimización extrema)
- GDExtension para core loop de simulación
- Reducir frecuencia de updates visuales (cada N sim steps)
- Threading para sistemas independientes
- LOD agresivo: T1 y T2 invisibles desde zoom T4

---

## 🚧 Roadmap de Implementación

### Fase 1: Estabilización v0.5.x (actual)
- [ ] Corregir bugs pendientes (save/load, prismas, etc.)
- [ ] Publicar demo jugable Tier 1 en itch.io
- [ ] Recoger feedback de jugadores reales
- [ ] Preparar benchmark de rendimiento baseline

### Fase 2: Tier 2 Core (v0.6)
- [ ] Implementar escala 3×3 sobre grid existente
- [ ] Fixed timestep con accumulator
- [ ] Generador de Electrones (nuevo edificio)
- [ ] Condensador de Tiempo I (edificio + UI de velocidad ×1/×4)
- [ ] Primeros átomos (hidrógeno: 1p + 1e)

### Fase 3: Tier 2 Completo (v0.7)
- [ ] Acelerador de Partículas
- [ ] Átomos de helio (2p + 2n + 2e)
- [ ] LOD nivel 1: fábricas T1 como bloques compactos
- [ ] Zoom continuo entre escala T1 y T2
- [ ] Sistema básico de blueprints

### Fase 4: Tier 3 Foundation (v0.8)
- [ ] Chunking de datos obligatorio
- [ ] MultiMesh para renderizado batch
- [ ] Escala 9×9
- [ ] Reactor de Fusión (átomos pesados: C, N, O)
- [ ] Condensador de Tiempo II (×16)

### Fase 5: Tier 3 Completo (v0.9)
- [ ] Enlazador Molecular (H₂O, CO₂)
- [ ] LOD nivel 2: T1 como puntos de luz, T2 como bloques
- [ ] Sistema de zonas
- [ ] Hub de Distribución
- [ ] Evaluar GDExtension

### Fase 6: Tier 4 y Release (v1.0)
- [ ] Moléculas orgánicas (aminoácidos)
- [ ] Condensador de Tiempo III (×40)
- [ ] ADN como objetivo final
- [ ] Sistema de templates / auto-replicación
- [ ] Polish y optimización final

---

## ⚠️ Riesgos Identificados

### Técnicos

| Riesgo | Prob. | Impacto | Mitigación |
|--------|-------|---------|------------|
| Rendimiento en T3+ | Alta | Crítico | Chunking desde diseño, GDExtension backup |
| TileMap no escala | Media | Alto | Migrar a renderizado custom con MultiMesh |
| Velocidad ×40 inestable | Media | Medio | Limitar updates visuales, interpolación |
| Save/Load con multi-tier | Media | Alto | Serialización por chunks, versionado de saves |

### Diseño

| Riesgo | Prob. | Impacto | Mitigación |
|--------|-------|---------|------------|
| Transiciones confusas | Media | Alto | Tutorial por tier, UI progresiva |
| Late game tedioso | Alta | Alto | Objetivos visuales claros, blueprints |
| Complejidad abrumadora | Media | Medio | Revelar mecánicas gradualmente |
| Scope creep | Alta | Crítico | Publicar demo T1, iterar con feedback real |

---

## 📚 Referentes de Diseño

### Juegos analizados

| Juego | Lección para Micro Architect |
|-------|------------------------------|
| **Factorio** | UPS optimization, blueprints, separar UPS de FPS |
| **Satisfactory** | Riesgo de single-thread, manifolds, 3D performance |
| **Dyson Sphere Program** | Multi-escala planetaria, logística a distancia |
| **Shapez 2** | Minimalismo, Make Anything Machine, motor optimizado |
| **Mindustry** | Accesibilidad, espacio limitado fuerza optimización |
| **Oxygen Not Included** | Emergent complexity, pocas reglas → muchos resultados |
| **Antimatter Dimensions** | Prestige en capas, escala exponencial controlada |
| **Universal Paperclips** | Transiciones de fase dramáticas, UI que crece |
| **Spore** | Qué NO hacer: eras desconectadas = 5 juegos distintos |
| **Katamari Damacy** | Escala continua, ontología plana, zoom fluido |
| **KSP** | Time warp en 2 modos (rails vs physics) |
| **Cookie Clicker** | Prestige currency, permanent upgrade slots |
| **Kittens Game** | Múltiples sistemas de prestige apilados |

### Principios adoptados

1. **"Lo que ves es cómo funciona"** (Factorio) — Sin magia oculta
2. **"Emergent complexity from simple rules"** (ONI) — Pocas reglas, muchos resultados
3. **"Transformación, no solo expansión"** (Universal Paperclips) — Cada era es diferente
4. **"Prestige toma logaritmo"** (Antimatter Dimensions) — Números manejables
5. **"La UI crece con el juego"** (A Dark Room) — Revelación progresiva
6. **"Ontología plana"** (Katamari) — Mismo estilo visual, diferente resolución

---

## 📁 Referencias internas

| Doc | Contenido |
|-----|-----------|
| ROADMAP.md | Tareas inmediatas por bloques |
| PROJECT_STATE.md | Estado actual, bugs, versión |
| ARCHITECTURE.md | Principios técnicos |
| ENERGY_SYSTEM.md | Sistema de energía numérica |
| API_MANAGERS.md | API de managers |

---

*Última revisión: 2025-02-02. Escala corregida a 1→3→9→27 con LOD semántico.*
