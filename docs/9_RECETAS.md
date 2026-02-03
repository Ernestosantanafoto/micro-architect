# 📖 Recetario – Coste de construcción y desbloqueo

Referencia rápida: **qué cuesta fabricar** cada edificio y **cómo desbloquearlo**.  
Los datos provienen de `GameConstants.RECETAS` y del árbol tecnológico (`TechTree`).

---

## 🔓 Nivel BÁSICO (desbloqueados al inicio)

| Edificio | Coste de fabricación | Tiempo | Cómo desbloquear |
|----------|----------------------|--------|------------------|
| **Sifón** | 15 Estabilidad, 5 Carga | 3 s | 🔓 Inicio |
| **Prisma Recto** | 5 Estabilidad, 5 Carga | 2 s | 🔓 Inicio |
| **Prisma Angular** | 5 Estabilidad, 10 Carga | 2 s | 🔓 Inicio |

---

## ⚙️ Nivel MANIPULACIÓN

| Edificio | Coste de fabricación | Tiempo | Cómo desbloquear |
|----------|----------------------|--------|------------------|
| **Compresor** | 150 Estabilidad, 150 Carga | 8 s | Requiere: **Sifón** (tech) |

---

## 🚀 Nivel AVANZADO (T2)

| Edificio | Coste de fabricación | Tiempo | Cómo desbloquear |
|----------|----------------------|--------|------------------|
| **Sifón T2** | 5 Condensada-Estabilidad, 5 Condensada-Carga | 5 s | Requiere: **Sifón**. Además: **20 Sifones T1** colocados. |
| **Prisma Recto T2** | 50 Estabilidad, 50 Carga | 4 s | Requiere: **Prisma Recto**. Además: **100 Prismas Rectos T1** colocados. |
| **Prisma Angular T2** | 50 Estabilidad, 50 Carga | 4 s | Requiere: **Prisma Angular**. Además: **100 Prismas Angulares T1** colocados. |
| **Compresor T2** | 20 Condensada-Estabilidad, 20 Condensada-Carga | 12 s | Requiere: **Compresor**. Además: **50 Compresores T1** colocados. |

---

## 🏭 Nivel PRODUCCIÓN

| Edificio | Coste de fabricación | Tiempo | Cómo desbloquear |
|----------|----------------------|--------|------------------|
| **Fusionador** | 100 Condensada-Estabilidad, 100 Condensada-Carga | 10 s | Requiere: **Compresor**. Además: **5 Condensada-Estabilidad** en inventario. |
| **Constructor** | 50 Up-Quark, 50 Down-Quark | 30 s | Requiere: **Fusionador**. Además: **1 Up-Quark** en inventario. |
| **Fabricador Hadrón** | 40 Up-Quark, 40 Down-Quark | 15 s | Requiere: **Fusionador** (tech) |

---

## 🌑 Nivel ESPECIAL

| Edificio | Coste de fabricación | Tiempo | Cómo desbloquear |
|----------|----------------------|--------|------------------|
| **Void Generator** | 200 Estabilidad, 200 Carga | 10 s | **5 Constructores** colocados en el mundo (sin requisito tech previo). |

---

## Resumen por recurso (coste de fabricación)

- **Estabilidad / Carga**: Sifón, Prismas T1/T2, Compresor, Void Generator.
- **Condensada-Estabilidad / Condensada-Carga**: Sifón T2, Compresor T2, Fusionador.
- **Up-Quark / Down-Quark**: Constructor, Fabricador Hadrón.

---

## Notas

- **Tiempo**: segundos que tarda la receta al craftear desde el HUD/inventario.
- **Desbloqueo**: primero se cumplen los requisitos tech (ej. tener Sifón para Compresor); luego, si aplica, la condición extra (recursos en inventario o edificios colocados).
- God Siphon no es una receta; está en modo DEBUG (tecla 0) y no tiene coste de recursos en el recetario.

*Documento generado a partir de `GameConstants.RECETAS` y `TechTree` (tech_tree.gd).*
