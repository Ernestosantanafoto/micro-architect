# 📖 Recetario – Coste de construcción y desbloqueo

Referencia: **recipe book** del proyecto. Costes de fabricación, tiempos y condiciones de desbloqueo.  
Fuente de verdad en código: `GameConstants.RECETAS` y `TechTree` (tech_tree.gd).

---

## 🔓 Nivel BÁSICO (inicio)

| Edificio | Coste de fabricación | Tiempo | Desbloqueo |
|----------|----------------------|--------|------------|
| **Sifón T1** | 12 Estabilidad, 4 Carga | 3 s | 🔓 Inicio |
| **Prisma Recto T1** | 4 Estabilidad, 4 Carga | 2 s | 🔓 Inicio |
| **Prisma Angular T1** | 4 Estabilidad, 8 Carga | 2 s | 🔓 Inicio |

---

## ⚙️ Nivel MANIPULACIÓN

| Edificio | Coste de fabricación | Tiempo | Desbloqueo |
|----------|----------------------|--------|------------|
| **Compresor T1** | 120 Estabilidad, 120 Carga | 8 s | Tech: Sifón |

---

## 🚀 Nivel AVANZADO (T2)

| Edificio | Coste de fabricación | Tiempo | Desbloqueo |
|----------|----------------------|--------|------------|
| **Sifón T2** | 3 Cond.-Estabilidad, 3 Cond.-Carga | 5 s | Tech: Sifón · **12 Sifones T1** colocados |
| **Prisma Recto T2** | 40 Estabilidad, 40 Carga | 4 s | Tech: Prisma Recto · **48 Prismas T1** colocados |
| **Prisma Angular T2** | 40 Estabilidad, 40 Carga | 4 s | Tech: Prisma Angular · **48 Prismas T1** colocados |
| **Compresor T2** | 15 Cond.-Estabilidad, 15 Cond.-Carga | 12 s | Tech: Compresor · **9 Compresores T1** colocados |

---

## 🏭 Nivel PRODUCCIÓN

| Edificio | Coste de fabricación | Tiempo | Desbloqueo |
|----------|----------------------|--------|------------|
| **Fusionador** | 80 Cond.-Estabilidad, 80 Cond.-Carga | 10 s | Tech: Compresor · **5 Cond.-Estabilidad** en inventario |
| **Constructor** | 40 Up-Quark, 40 Down-Quark | 30 s | Tech: Fusionador · **1 Up-Quark** en inventario |
| **Fabricador Hadrón** | 30 Up-Quark, 30 Down-Quark | 15 s | Tech: Fusionador · **10 Constructores** colocados |

---

## 🌑 Nivel ESPECIAL

| Edificio | Coste de fabricación | Tiempo | Desbloqueo |
|----------|----------------------|--------|------------|
| **Void Generator** | 160 Estabilidad, 160 Carga | 10 s | **3 Constructores** colocados (sin tech previo) |

---

## ⏱ Producción en mundo

### Extracción — Sifones

| Edificio | Producción | Ciclo |
|----------|------------|-------|
| Sifón T1 | 1 Estabilidad **o** 1 Carga | cada 5 s |
| Sifón T2 | 2 Estabilidad **o** 2 Carga | cada 2 s |

### Compresión — Energía → Condensada
*(10 energía normal = 1 condensada; E y C no intercambiables)*

| Edificio | Consumo | Producción | Tiempo |
|----------|---------|------------|--------|
| Compresor T1 | 10 pulsos E o C | 1 Cond.-E o Cond.-C | 5 s |
| Compresor T2 | 10 pulsos E o C | 1 Cond.-E o Cond.-C | 2,5 s |

### Fusión — Condensada → Quarks

| Producción | Consumo | Tiempo |
|------------|---------|--------|
| Up-Quark | 150 Cond.-Estabilidad + 150 Cond.-Carga | 15 s |
| Down-Quark | 120 Cond.-Estabilidad + 180 Cond.-Carga | 15 s |

### Nucleones — Quarks → Partículas (proporciones reales)

| Producción | Consumo | Tiempo |
|------------|---------|--------|
| Protón | 2 Up-Quark + 1 Down-Quark | 12 s |
| Neutrón | 1 Up-Quark + 2 Down-Quark | 12 s |

*(Prioridad interna mantenida.)*

### Constructor — Fabricación

El Constructor usa exactamente las recetas y tiempos documentados en las tablas de edificios de arriba.

### Void Generator

| Acción | Tiempo |
|--------|--------|
| Avance por tile (mancha) | 2 s por tile |
| Destrucción de edificio (animación) | 0,4 s |

---

## Notas

- **Tiempo**: segundos al craftear desde HUD/inventario o en Constructor.
- **Desbloqueo**: requisito tech primero; luego, si aplica, condición extra (recurso en inventario o edificios colocados).
- God Siphon no es receta; modo DEBUG (tecla 0), sin coste en recetario.

---

## Checklist de implementación

- [x] Costes de fabricación alineados con este documento
- [x] Tiempos de producción alineados
- [x] Condiciones de desbloqueo implementadas (TechTree)
- [x] Dependencias del árbol tech enlazadas
- [x] Contadores «colocados» para desbloqueos
- [x] Condiciones «en inventario» (Fusionador, Constructor)

*Documento alineado con el recipe book de referencia del proyecto. Documentación de costes, tiempos y desbloqueos completada.*
