# Runbook: TEST_CHECKLIST 6.5 + 10.3

**Objetivo:** Verificar colocación por tipo (6.5) y save/load con 20+ edificios (10.3).  
**Cuándo marcar:** Solo `[v]` tras comprobarlo en juego. `[x]` = falla.

Referencia completa: [6_TEST_CHECKLIST.md](6_TEST_CHECKLIST.md).

---

## 6.5 — Colocación por tipo y bordes

Abre partida (nueva o con recursos para tener todos los edificios). Comprueba que cada tipo **solo** se coloca donde debe; en tile no permitido → fantasma **rojo**.

| Tipo | Tile permitido | En otros tiles → fantasma rojo |
|------|----------------|--------------------------------|
| **Sifón** | Verde (Estabilidad) o azul (Carga) | Vacío/rojo |
| **Compresor** | Roja | Verde/azul/vacío |
| **Prisma recto / angular** | Vacío | Verde/azul/rojo |
| **Fusionador (Merger)** | Vacío | Losetas de energía |
| **Fabricador Hadrón** | Vacío | Losetas de energía |
| **Constructor** | Vacío 3×3 (ninguna celda ocupada ni de energía) | Si cualquier celda 3×3 ocupada o energía → rojo |
| **Void Generator** | Solo celda central; perímetro rojo en suelo; latente al colocar; clic der = activar | No rota; simétrico |

- [ ] Sifón: solo verde/azul
- [ ] Compresor: solo roja
- [ ] Prismas: solo vacío
- [ ] Merger: solo vacío
- [ ] Hadrón: solo vacío
- [ ] Constructor: solo vacío 3×3
- [ ] Void Generator: celda central, latente, clic der activar
- [ ] **Rotación (R):** Con cada tipo, R gira 90°; colocación respeta rotación
- [ ] **Bordes:** Colocar al menos un edificio en una celda del borde del grid; no crashea ni permite fuera de límites

---

## 10.3 — Save/load partida compleja (20+ edificios)

1. Coloca **20+ edificios** (Sifones, Compresores, Prismas, Merger, Hadrón, Constructor, Void).
2. **GUARDAR** → mensaje de confirmación.
3. **Salir a menú** (MENÚ o CERRAR).
4. **CARGAR** la partida.

Comprueba:

- [ ] Partida carga sin error
- [ ] Posiciones: todos los edificios en su sitio
- [ ] Rotaciones: orientación correcta
- [ ] Producción activa: Sifones/Compresores siguen funcionando tras cargar

---

## Resultado

- **6.5:** ¿Todo OK? Sí / No — notas: _______________
- **10.3:** ¿Todo OK? Sí / No — notas: _______________

Si ambos OK → se marcan ROADMAP 5.1 y 5.2 como verificados.
