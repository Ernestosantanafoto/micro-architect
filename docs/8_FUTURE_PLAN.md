# 🗺 Plan Futuro - Micro Architect

**Base:** v0.5-alpha (Fase Cuántica funcional)  
**Última actualización:** 2025-02-02

---

## 🎯 Visión de Progresión

```
energía → quarks → protones/neutrones → átomos → moléculas → ADN
  ✅         ✅           ✅                ⏳         ⏳          ⏳
```

El jugador construye materia desde partículas fundamentales, experimentando la escala del universo a través de **4 eras** que transforman espacio, tiempo y complejidad de juego simultáneamente.

---

## 🏗 Sistema de 4 Tiers / Eras

### Principios de Diseño

Basados en análisis de Factorio, Satisfactory, DSP, Shapez 2, Mindustry, ONI, Antimatter Dimensions, Universal Paperclips, Spore y Katamari Damacy:

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

**Principio clave:** La velocidad es **GLOBAL** (afecta a todo el juego). Los tiers superiores nacen inherentemente lentos porque las partículas más pesadas se mueven más despacio. El jugador sube la velocidad global para que el tier en el que trabaja se sienta a velocidad "cómoda" (~1x visual).

| Velocidad global | T1 (cuántico) | T2 (subatómico) | T3 (atómico) | T4 (molecular) |
|------------------|---------------|------------------|---------------|-----------------|
| ×1 | **Cómodo** | Muy lento | Casi parado | Parado |
| ×4 | Rápido | **Cómodo** | Muy lento | Casi parado |
| ×16 | Muy rápido | Rápido | **Cómodo** | Muy lento |
| ×40 | Frenético | Muy rápido | Rápido | **Cómodo** |

**Desbloqueo de velocidades:**

| Velocidad | Desbloqueada tras… |
|-----------|---------------------|
| ×1 | Siempre disponible |
| ×4 | Condensador de Tiempo I (Tier 2) |
| ×16 | Condensador de Tiempo II (Tier 3) |
| ×40 | Condensador de Tiempo III (Tier 4) |

**Experiencia del jugador:** Siempre juega a una velocidad visual similar a la del Tier 1 original. Cuando sube la velocidad, los tiers inferiores "vuelan" en segundo plano. Como los tiers inferiores están reducidos a bloques o puntos de luz (LOD), verlos acelerados refuerza la sensación de escala. El jugador puede bajar la velocidad temporalmente si necesita ajustar fábricas de un tier inferior (zoom in + bajar velocidad).

**Justificación física:** Las partículas más pesadas se mueven más lento en el mundo real. Protones ~2000× más masivos que electrones. Los átomos son aún más lentos. Las moléculas, pesadísimas. El jugador experimenta esta diferencia de escalas de tiempo de forma natural.

---

## 🔬 Tier 1 — Fase Cuántica ✅ (v0.5-alpha)

**Escala:** Grid 1×1, edificios 1×1 a 3×1  
**Velocidad:** ×1  
**Producción:** Energía → Quarks → Protones / Neutrones

| Edificio | Función | Tamaño |
|----------|---------|--------|
| Sifón | Extrae energía del vacío cuántico | 1×1 |
| Compresor | Comprime energía 10:1 | 1×1 |
| Prisma (recto/angular) | Redirige haces de luz | 1×1 |
| Merger | Fusiona energías comprimidas → quarks | 3×1 |
| Fabricador Hadrón | Quarks → protones/neutrones | 3×1 |
| Constructor | Craftea edificios a partir de recursos | 1×1 |

**Rol del jugador:** Puzzle de colocación precisa. Cada celda importa.

**Milestone de transición a Tier 2:** Producir X protones Y neutrones estables + construir el Condensador de Tiempo I (alto costo energético continuo).

---

## ⚛️ Tier 2 — Fase Subatómica 🔜 (v0.6 – v0.7)

**Escala:** Grid 3×3 (1 celda T2 = 3×3 celdas T1)  
**Velocidad:** ×1 base → **×4 tras Condensador I**  
**Producción:** Protones + Neutrones + Electrones → Átomos simples (H, He)

### Concepto de escala

Las fábricas de Tier 1 se ven como **bloques compactos coloreados** cuando el jugador está en zoom de Tier 2. Hacer zoom in devuelve la vista detallada.

### Nuevos edificios

| Edificio | Función | Tamaño (T2) |
|----------|---------|-------------|
| Condensador de Tiempo I | Desbloquea velocidad ×4 | 3×3 (= 9×9 T1) |
| Generador de Electrones | Consume quarks → electrones | 1×1 |
| Acelerador de Partículas | Combina protones + neutrones + electrones → átomo | 2×2 |
| Estabilizador Atómico | Mantiene átomos coherentes | 1×1 |
| Canal de Partículas | Transporta partículas masivas entre zonas | 1×N |

### Condensador de Tiempo I

- **Costo:** Consumo continuo muy alto de energía comprimida
- **Mecánica:** Una vez construido, aparece botón de velocidad global en la UI
- **Desbloquea:** Velocidad ×4 (todo el juego se acelera)
- **Efecto:** Tier 2 pasa de "muy lento" a velocidad cómoda para el jugador
- **Efecto secundario:** Tier 1 corre a ×4 (en LOD reducido se percibe como "fábricas cuánticas zumbando en segundo plano")
- **Visual:** Efecto de distorsión temporal alrededor del edificio
- El jugador puede volver a ×1 si necesita hacer zoom in y ajustar fábricas de Tier 1

### Nuevos recursos

| Recurso | Color | Origen |
|---------|-------|--------|
| Electrón | Cyan | Generador de Electrones |
| Hidrógeno (H) | Blanco | Acelerador (1p + 1e) |
| Helio (He) | Naranja claro | Acelerador (2p + 2n + 2e) |

**Rol del jugador:** Optimización de throughput. Diseñar rutas eficientes para partículas más lentas y grandes. Primeras decisiones de layout macro.

**Milestone de transición a Tier 3:** Producir Z átomos de hidrógeno estables + construir Condensador de Tiempo II.

---

## 🌐 Tier 3 — Fase Atómica 🔮 (v0.8 – v0.9)

**Escala:** Grid 9×9 (1 celda T3 = 9×9 T1 = 3×3 T2)  
**Velocidad:** ×4 base → **×16 tras Condensador II**  
**Producción:** Átomos → Moléculas simples

### Visualización LOD

Desde zoom T3: Fábricas T1 → puntos de luz; T2 → bloques compactos; T3 → detalle completo.

### Nuevos edificios

| Edificio | Función | Tamaño (T3) |
|----------|---------|-------------|
| Condensador de Tiempo II | Desbloquea velocidad ×16 | 3×3 |
| Reactor de Fusión | Crea átomos pesados (C, N, O) | 2×2 |
| Enlazador Molecular | Une átomos en moléculas | 2×2 |
| Hub de Distribución | Logística entre zonas T3 | 1×1 |

### Nuevos recursos

| Recurso | Color | Origen |
|---------|-------|--------|
| Carbono (C) | Gris oscuro | Reactor (6p + 6n + 6e) |
| Nitrógeno (N) | Azul | Reactor (7p + 7n + 7e) |
| Oxígeno (O) | Rojo | Reactor (8p + 8n + 8e) |
| H₂O | Azul claro | Enlazador (2H + O) |
| CO₂ | Gris | Enlazador (C + 2O) |

**Rol del jugador:** Macro-gestión de zonas. Diseño de layouts regionales.

**Milestone de transición a Tier 4:** Producir moléculas orgánicas básicas (aminoácidos) + construir Condensador de Tiempo III.

---

## 🧬 Tier 4 — Fase Molecular / ADN 🌟 (v1.0+)

**Escala:** Grid 27×27  
**Velocidad:** ×16 base → **×40 tras Condensador III**  
**Producción:** Moléculas → Aminoácidos → ADN

### Visualización LOD

Desde zoom T4: T1 invisibles; T2 puntos de luz; T3 bloques compactos; T4 detalle completo.

### Objetivo Final: Construir ADN

1. Azúcares (ribosa, desoxirribosa) — C, H, O  
2. Bases nitrogenadas (A, T, G, C) — C, H, O, N  
3. Grupos fosfato — recurso especial  
4. Ensamblaje en secuencia → doble hélice  

### Mecánica de templates

Inspirada en "Make Anything Machine" de Shapez 2: templates de fábricas, auto-replicación, blueprints.

**Rol del jugador:** Arquitecto de sistemas. Diseñar fábricas que construyen fábricas.

---

## 👁 Sistema de LOD Semántico

El estilo visual **nunca cambia** (cubos, haces, partículas). Solo cambia la **resolución de detalle** según el nivel de zoom:

| Nivel de zoom | Representación | Tecnología |
|---------------|----------------|------------|
| > 80% (cerca) | Nodos reales (mallas, colisiones, haces) | Nodos Godot |
| 30–80% (medio) | Bloques compactos de color estático | MultiMesh |
| < 30% (lejos) | Puntos de luz con color de producción | GPUParticles3D / Sprites |

**Reglas:** Tier N → detalle completo; Tier N-1 → bloques compactos; Tier N-2 → puntos de luz; Tier N-3+ → invisibles.

> "La simulación manda, el render obedece."  
El LOD solo afecta al renderizado. La simulación corre idéntica. EnergyManager / BuildingManager procesan datos numéricos siempre.

---

## 📊 Sistema de Prestige

| Transición | Moneda | Efecto |
|------------|--------|--------|
| T1 → T2 | Quantum Seeds | +1% producción base T1 por unidad |
| T2 → T3 | Nucleon Cores | Desbloquea automatización avanzada |
| T3 → T4 | Atomic Bonds | Habilita templates y auto-replicación |

**Persiste entre tiers:** Blueprints, estadísticas, achievements, moneda prestige. **No persiste:** Recursos físicos, edificios individuales (pasan a LOD).

---

## ⚡ Arquitectura Técnica por Tier

- **Tier 1 (actual):** GridMap, nodos individuales, Area3D, señales Godot. Suficiente para escala actual.
- **Tier 2:** Fixed timestep con accumulator, MultiMesh batch, object pooling.
- **Tier 3:** Chunking obligatorio (16×16), virtualización, evaluar GDExtension.
- **Tier 4:** GDExtension core, threading, LOD agresivo.

---

## 🚧 Roadmap de Implementación

- **Fase 1 (v0.5.x):** Estabilización, demo itch.io, feedback, benchmark.
- **Fase 2 (v0.6):** Escala 3×3, accumulator, Generador Electrones, Condensador I, hidrógeno.
- **Fase 3 (v0.7):** Acelerador, helio, LOD T1, zoom continuo, blueprints.
- **Fase 4 (v0.8):** Chunking, escala 9×9, Reactor Fusión, Condensador II.
- **Fase 5 (v0.9):** Enlazador Molecular, LOD nivel 2, zonas, Hub.
- **Fase 6 (v1.0):** Aminoácidos, Condensador III, ADN, templates, polish.

---

## ⚠️ Riesgos Identificados

**Técnicos:** Rendimiento T3+ (chunking, GDExtension), TileMap no escala (MultiMesh), velocidad ×40 inestable, Save/Load multi-tier.  
**Diseño:** Transiciones confusas, late game tedioso, complejidad abrumadora, scope creep (mitigación: demo T1, feedback real).

---

## 📚 Referentes de Diseño

Factorio (UPS, blueprints), Satisfactory (3D performance), DSP (multi-escala), Shapez 2 (minimalismo, Make Anything Machine), Mindustry, ONI (emergent complexity), Antimatter Dimensions (prestige), Universal Paperclips (transiciones de fase), Spore (qué no hacer), Katamari (escala continua, ontología plana), KSP (time warp), Cookie Clicker, Kittens Game.

**Principios adoptados:** Lo que ves es cómo funciona; emergent complexity from simple rules; transformación no solo expansión; prestige logarítmico; UI que crece; ontología plana.

---

## 📁 Referencias internas

| Doc | Contenido |
|-----|-----------|
| 4_ROADMAP.md | Tareas inmediatas por bloques |
| 5_PROJECT_STATE.md | Estado actual, bugs, versión |
| 10_ARCHITECTURE.md | Principios técnicos |
| 11_ENERGY_SYSTEM.md | Sistema de energía numérica |
| 12_API_MANAGERS.md | API de managers |

---

*Última revisión: 2025-02-02. Escala 1→3→9→27 con LOD semántico.*
