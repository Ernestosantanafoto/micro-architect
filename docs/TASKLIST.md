# Qué hacer ahora – Tasklist

**Un solo sitio para las tareas actuales.**  
Marca `[x]` al completar. Si algo bloquea, pasa al siguiente.  
Última actualización: 2025-01-31

---

## Cómo usar

- **Prioridad:** haz primero las marcadas como **P** (prioritarias para T1/demo).
- **Origen:** las tareas vienen de ROADMAP (Bloque 5), COSAS_POR_HACER (P) y mejoras recientes (dim RECURSOS).
- Para el plan completo por bloques → [ROADMAP.md](ROADMAP.md).  
- Para estado del proyecto → [PROGRESO.md](PROGRESO.md).

---

## Bloque 5: Estabilización v0.5 (pre-demo)

### 5.1–5.2 Save/load y colocación (verificación)
- [ ] Verificar save/load con partida compleja (20+ edificios) — TEST_CHECKLIST 10.3
- [ ] Verificar colocación de todos los edificios en tiles correctos — TEST_CHECKLIST 6.5
- [ ] Test de rotación y colocación en bordes del mapa

### 5.3 Testing integral
- [ ] Ejecutar TEST_CHECKLIST completo (Partes 1–11)
- [ ] Documentar bugs encontrados
- [ ] Arreglar bugs críticos y re-test

### 5.4 Preparar demo
- [ ] Configurar export HTML5 o Windows
- [ ] Crear página en itch.io (descripción, controles, versión)
- [ ] Screenshots / GIF de gameplay
- [ ] Publicar como alpha buscando feedback

---

## Mejoras recientes (seguimiento)

### Menú RECURSOS (dim/ocultar) — hecho
- [x] Al elegir categoría: edificios no seleccionados se atenúan
- [x] Grilla azul, tiles de energía (GridMap), bolas (PulseVisual) y haces (BeamSegment) se ocultan/atenúan
- [x] Clic fuera del menú RECURSOS cierra y quita el dim
- [ ] **Persistir bolas de energía en vuelo (PulseVisual)** al cargar partida o al quitar el dim (que no desaparezcan y que no se reinicien desde el edificio)

---

## Prioridad P (T1 / demo) — de COSAS_POR_HACER

- [ ] **Volumen de música** (slider en menú o pausa) — MusicManager existe; falta UI
- [ ] **Manejo de partida corrupta o inexistente** — Al cargar: mensaje claro, no crashear
- [ ] **Revisar logs de debug** — Reducir o condicionar a DEBUG_MODE antes de demo
- [ ] **Export HTML5/Windows estable** — Probar en máquina limpia (coincide con 5.4)
- [ ] **Texto itch.io** (descripción, controles, versión)

---

## Documentación (reorganización)

- [x] Crear PROGRESO.md (punto único para seguir estado)
- [x] Crear TASKLIST.md (punto único para “qué hacer ahora”)
- [x] Reescribir README.md con “Empieza aquí” y niveles (diario / cuando toque / referencia)
- [x] Archivar docs redundantes (Nuevos MDs, ANALISIS_UNIFICACION_MDS, MD_ACTUALIZADO)

---

## Siguiente sesión sugerida

1. Persistir bolas en vuelo (PulseVisual) si quieres pulir el dim; **o**
2. Ejecutar TEST_CHECKLIST 6.5 y 10.3 y marcar ROADMAP 5.1–5.2; **o**
3. Empezar 5.4 (export y itch.io).

Cuando termines un bloque o varias tareas, actualiza [PROGRESO.md](PROGRESO.md) y la tabla “Estado actual” en [ROADMAP.md](ROADMAP.md).
