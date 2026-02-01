# 🎨 MOCKUPS DE UI - Diseños y Especificaciones

**Propósito:** Documentar cómo deben verse las UIs antes de implementarlas

---

## 🔧 GOD SIPHON UI

### Mockup Visual (Descripción)
```
┌─────────────────────────────────────────┐
│  ⚙️  CONFIGURACIÓN DE GOD SIPHON       │
├─────────────────────────────────────────┤
│                                         │
│  Energía por segundo:                   │
│  ├─────────●─────────┤  [10.0]         │
│  (min: 1.0)       (max: 100.0)          │
│                                         │
│  Tipo de salida:                        │
│  ( ) Energía básica                     │
│  (●) Energía comprimida                 │
│  ( ) Quarks directos                    │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ VISTA PREVIA:                   │   │
│  │ Producción: 10 energía/seg      │   │
│  │ Conectado a: 2 compresores      │   │
│  └─────────────────────────────────┘   │
│                                         │
│  [Aplicar]  [Resetear]  [Cerrar]       │
└─────────────────────────────────────────┘
```

### Especificaciones Técnicas

**Componentes:**
- Panel: `PanelContainer` con tema custom
- Sliders: `HSlider` con labels dinámicos
- Radio buttons: `CheckBox` en grupo exclusivo
- Vista previa: `Label` con info en tiempo real
- Botones: `Button` con señales

**Comportamiento:**
- Se abre al hacer doble-click en God Siphon
- Se cierra al clickear fuera o botón "Cerrar"
- "Aplicar" actualiza valores y cierra
- "Resetear" vuelve a valores por defecto
- Cambios en slider actualizan vista previa en tiempo real

**Posición:**
- Centro de pantalla (popup modal)
- O anclado al lado del edificio seleccionado (decisión de diseño)

---

## 🏗️ CONSTRUCTOR UI

### Mockup Visual (Descripción)
```
┌─────────────────────────────────────────────────────┐
│  🏗️  CONSTRUCTOR - Selecciona qué crear            │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌───────┐  ┌───────┐  ┌───────┐  ┌───────┐      │
│  │ [1]   │  │ [2]   │  │ [3]   │  │ [4]   │      │
│  │  🔋   │  │  ⚗️   │  │  🔀   │  │  🏭   │      │
│  │Siphon │  │Comprs │  │Merger │  │Fcty   │      │
│  │ 10💰  │  │ 50💰  │  │100💰  │  │500💰  │      │
│  └───────┘  └───────┘  └───────┘  └───────┘      │
│   ✅         ✅         ❌         ✅             │
│  (Puedes)  (Puedes)  (Faltan)  (Puedes)          │
│                                                     │
│  ┌───────┐  ┌───────┐                             │
│  │ [5]   │  │ [6]   │  ...                        │
│  │  ◆    │  │  🌀   │                             │
│  │Prism  │  │Void   │                             │
│  │ 30💰  │  │200💰  │                             │
│  └───────┘  └───────┘                             │
│   ✅         ✅                                   │
│                                                     │
│  [ESC para cerrar]                                 │
└─────────────────────────────────────────────────────┘
```

### Especificaciones Técnicas

**Componentes:**
- Grid: `GridContainer` con 4 columnas
- Cards: `PanelContainer` con:
  - Icono grande (TextureRect)
  - Nombre (Label)
  - Costo (Label con icono de recurso)
  - Estado: ✅ disponible / ❌ bloqueado
- Hotkeys: números visibles en esquina superior

**Comportamiento:**
- Se abre al interactuar con Constructor
- Click en card selecciona edificio → cierra menú → modo colocación
- Teclas 1-9 seleccionan directamente
- ESC cierra sin seleccionar
- Cards bloqueadas no son clickeables (visuales grises)
- Hover muestra tooltip con descripción breve

**Posición:**
- Popup centrado o cerca del Constructor

---

## 🎮 HUD MEJORADO

### Mockup Visual (Descripción)
```
┌────────────────────────────── BARRA INFERIOR ──────────────────────────────┐
│                                                                             │
│  💰 Recursos:     🔋 100  ⚗️ 50  ◆ 10              [?] [⚙️] [💾] [⏸️]     │
│                                                                             │
│  🏗️ Construcción: [Siphon] [Compr] [Merge] [Prism] [Void] [Fcty] [+]     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Secciones:**
1. **Recursos** (izquierda): Muestra inventario actual
2. **Acciones rápidas** (derecha): 
   - `[?]` = Ayuda (F1)
   - `[⚙️]` = Opciones
   - `[💾]` = Guardar
   - `[⏸️]` = Pausar
3. **Construcción** (centro): Acceso rápido a edificios comunes

**Comportamiento:**
- Tooltips al hacer hover
- Feedback visual (flash) cuando recursos cambian
- Botones disabled si acción no disponible

---

## 📖 GUÍA DE AYUDA (F1)

### Mockup Visual (Descripción)
```
┌──────────────────────── GUÍA DE MICRO ARCHITECT ───────────────────────────┐
│                                                                             │
│  [Edificios] [Recursos] [Controles] [Objetivos]                            │
│  ═══════════                                                                │
│                                                                             │
│  🔋 SIPHON                                                                  │
│  ├─ Extrae energía básica del vacío                                        │
│  ├─ Requiere: Loseta de energía (azul)                                     │
│  ├─ Costo: Gratis                                                          │
│  └─ Producción: 10 energía/segundo                                         │
│                                                                             │
│  ⚗️ COMPRESSOR                                                              │
│  ├─ Comprime 10 energía en 1 comprimida                                    │
│  ├─ Requiere: Cualquier terreno                                            │
│  ├─ Costo: 50 energía                                                      │
│  └─ Ratio: 10:1                                                            │
│                                                                             │
│  [... más edificios]                                                        │
│                                                                             │
│                                              [Cerrar (ESC)]                 │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Pestañas:**
1. **Edificios:** Lista de todos los edificios con stats
2. **Recursos:** Cadena de producción visual (diagrama)
3. **Controles:** Teclado y ratón
4. **Objetivos:** Qué es el juego y cómo ganar

---

## 🎓 TUTORIAL OVERLAY

### Mockup Visual (Paso 1)
```
┌─────────────────────────────────────────────────────────────────────────┐
│  PANTALLA DEL JUEGO (semi-transparente)                                │
│                                                                         │
│    [SIPHON con glow amarillo destacado]                                │
│                                                                         │
│  ┌────────────────────────────────────────────────────────────────┐   │
│  │  👋 Bienvenido a Micro Architect                               │   │
│  │                                                                 │   │
│  │  Construye materia desde su forma más básica.                  │   │
│  │  Coloca un SIPHON en una loseta de energía (azul).             │   │
│  │                                                                 │   │
│  │                                   [Saltar tutorial]             │   │
│  └────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

**Elementos:**
- Overlay semi-transparente oscuro
- Panel de instrucciones (abajo centro)
- Highlight en elemento relevante (shader outline/glow)
- Botón "Saltar" siempre visible
- Avanza automáticamente al completar acción

---

## 📝 NOTAS DE DISEÑO

**Paleta de colores recomendada:**
- Energía básica: Azul (#3498db)
- Energía comprimida: Púrpura (#9b59b6)
- Quarks: Naranja (#e67e22)
- Positivo/Disponible: Verde (#2ecc71)
- Negativo/Bloqueado: Rojo/Gris (#e74c3c / #95a5a6)

**Fuentes:**
- Títulos: Bold, tamaño 18-24
- Texto normal: Regular, tamaño 14-16
- Labels pequeños: Regular, tamaño 12

**Espaciado:**
- Padding interno: 10-15px
- Margin entre elementos: 8-10px
- Grupos de elementos: 20px separación

---

**Última actualización:** 2025-02-01