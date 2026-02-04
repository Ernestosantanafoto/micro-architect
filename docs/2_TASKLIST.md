# Qué hacer ahora – Tasklist

**Un solo sitio para las tareas actuales.**  
Marca `[x]` al completar. Si algo bloquea, pasa al siguiente.  
Última actualización: 2025-02-03  
**Reglas y puntos no tocar:** [0_REGLAS_UNIVERSALES.md](0_REGLAS_UNIVERSALES.md)

---

## Cómo usar

- **Prioridad:** haz primero las marcadas como **P** (prioritarias para T1/demo).
- **Origen:** las tareas vienen de ROADMAP (Bloque 5), COSAS_POR_HACER (P) y mejoras recientes.
- **No tocar:** Lo marcado como hecho en "Menú INFRAESTRUCTURA (dim)" y en PROJECT_STATE (mejoras recientes) no debe refactorizarse salvo petición explícita.
- Para el plan completo por bloques → [4_ROADMAP.md](4_ROADMAP.md).  
- Para estado del proyecto → [1_PROGRESO.md](1_PROGRESO.md).

---

## Bloque 5: Estabilización v0.5 (pre-demo)

### 5.1–5.2 Save/load y colocación (verificación)
- [x] Verificar save/load con partida compleja (20+ edificios) — TEST_CHECKLIST 10.3
- [x] Verificar colocación de todos los edificios en tiles correctos — TEST_CHECKLIST 6.5
- [x] Test de rotación y colocación en bordes del mapa

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

### Menú INFRAESTRUCTURA (ex RECURSOS) — hecho — NO TOCAR
**Dim: solventado 100%. No tocar.**
- [x] Botón renombrado a INFRAESTRUCTURA
- [x] Al abrir panel: oscurecer todo, ocultar red (plano cámara) y tiles (GridMap)
- [x] Tiles y red permanecen ocultos al pulsar un ítem del dropdown (hasta cerrar panel)
- [x] Conteo de edificios colocados desde BuildingManager (menú actualizado en partida)
- [x] Clic fuera cierra y restaura visibilidad/materiales
- [ ] **Persistir bolas de energía en vuelo (PulseVisual)** al cargar partida o al quitar el dim (opcional; no bloqueante)

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

1. ~~Persistir bolas en vuelo~~ — Dim 100% solventado; no tocar.
2. ~~Ejecutar TEST_CHECKLIST 6.5 y 10.3~~ — Hecho; ROADMAP 5.1–5.2 verificados.
3. **Siguiente:** Testing integral (5.3) o empezar 5.4 (export y itch.io).

Cuando termines un bloque o varias tareas, actualiza [1_PROGRESO.md](1_PROGRESO.md) y la tabla “Estado actual” en [4_ROADMAP.md](4_ROADMAP.md).
