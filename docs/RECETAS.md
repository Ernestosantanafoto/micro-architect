# 📖 Recetario – Coste de construcción y desbloqueo

Referencia rápida: **qué cuesta fabricar** cada edificio y **cómo desbloquearlo**.  
Los datos provienen de `GameConstants.RECETAS` y del árbol tecnológico (`TechTree`).

---

## 🔓 Nivel BÁSICO (desbloqueados al inicio)

| Edificio | Coste de fabricación | Tiempo | Cómo desbloquear |
|----------|----------------------|--------|------------------|
| **Sifón** | 15 Stability, 5 Charge | 3 s | 🔓 Inicio |
| **Prisma Recto** | 5 Stability, 5 Charge | 2 s | 🔓 Inicio |
| **Prisma Angular** | 5 Stability, 10 Charge | 2 s | 🔓 Inicio |

---

## ⚙️ Nivel MANIPULACIÓN

| Edificio | Coste de fabricación | Tiempo | Cómo desbloquear |
|----------|----------------------|--------|------------------|
| **Compresor** | 150 Stability, 150 Charge | 8 s | Requiere: **Sifón** (tech) |

---

## 🚀 Nivel AVANZADO (T2)

| Edificio | Coste de fabricación | Tiempo | Cómo desbloquear |
|----------|----------------------|--------|------------------|
| **Sifón T2** | 5 Compressed-Stability, 5 Compressed-Charge | 5 s | Requiere: **Sifón**. Además: **20 Sifones T1** colocados. |
| **Prisma Recto T2** | 50 Stability, 50 Charge | 4 s | Requiere: **Prisma Recto**. Además: **100 Prismas Rectos T1** colocados. |
| **Prisma Angular T2** | 50 Stability, 50 Charge | 4 s | Requiere: **Prisma Angular**. Además: **100 Prismas Angulares T1** colocados. |
| **Compresor T2** | 20 Compressed-Stability, 20 Compressed-Charge | 12 s | Requiere: **Compresor**. Además: **50 Compresores T1** colocados. |

---

## 🏭 Nivel PRODUCCIÓN

| Edificio | Coste de fabricación | Tiempo | Cómo desbloquear |
|----------|----------------------|--------|------------------|
| **Fusionador** | 100 Compressed-Stability, 100 Compressed-Charge | 10 s | Requiere: **Compresor**. Además: **5 Compressed-Stability** en inventario. |
| **Constructor** | 50 Up-Quark, 50 Down-Quark | 30 s | Requiere: **Fusionador**. Además: **1 Up-Quark** en inventario. |
| **Fabricador Hadrón** | 40 Up-Quark, 40 Down-Quark | 15 s | Requiere: **Fusionador** (tech) |

---

## 🌑 Nivel ESPECIAL

| Edificio | Coste de fabricación | Tiempo | Cómo desbloquear |
|----------|----------------------|--------|------------------|
| **Void Generator** | 200 Stability, 200 Charge | 10 s | **5 Constructores** colocados en el mundo (sin requisito tech previo). |

---

## Resumen por recurso (coste de fabricación)

- **Stability / Charge**: Sifón, Prismas T1/T2, Compresor, Void Generator.
- **Compressed-Stability / Compressed-Charge**: Sifón T2, Compresor T2, Fusionador.
- **Up-Quark / Down-Quark**: Constructor, Fabricador Hadrón.

---

## Notas

- **Tiempo**: segundos que tarda la receta al craftear desde el HUD/inventario.
- **Desbloqueo**: primero se cumplen los requisitos tech (ej. tener Sifón para Compresor); luego, si aplica, la condición extra (recursos en inventario o edificios colocados).
- God Siphon no es una receta; está en modo DEBUG (tecla 0) y no tiene coste de recursos en el recetario.

*Documento generado a partir de `GameConstants.RECETAS` y `TechTree` (tech_tree.gd).*
