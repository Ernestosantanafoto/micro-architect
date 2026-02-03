# 📋 Cosas por hacer – Checklist proactiva

**Objetivo:** Tareas que suelen necesitar los juegos de gestión/fábrica y que aún no están sobre la mesa, o que conviene tener en radar.  
**Última actualización:** 2025-01-31

---

## 🎮 Cómo usar este doc

- No sustituye al **ROADMAP** ni al **TEST_CHECKLIST**; los complementa.
- Prioridad: **P** = prioritaria para T1/demo, **M** = mejora, **F** = futuro.
- Marca `[x]` cuando lo completes o lo incorpores al ROADMAP como tarea explícita.

---

## 🔧 Opciones y configuración (típico en cualquier juego)

| Estado | Prioridad | Tarea | Notas |
|--------|-----------|--------|--------|
| [x] | P | **Volumen de música** (slider en menú o pausa) | OPCIONES en menú principal + OPCIONES en menú ingame (MENU → OPCIONES) |
| [x] | M | **Volumen de efectos** (si se añaden SFX) | Slider + bus SFX creado al vuelo; guardado en user://settings.cfg |
| [x] | M | **Pantalla completa / ventana** | CheckButton en opciones; guardado en preferencias |
| [ ] | F | **Rebind de teclas 1–9** (y R, ESC) | Placeholder "Reasignar teclas (próximamente)" en opciones |
| [x] | M | **Guardar preferencias** (volumen, fullscreen) | user://settings.cfg (audio.volume, audio.sfx_volume, display.fullscreen) |

---

## 💾 Guardado y robustez

| Estado | Prioridad | Tarea | Notas |
|--------|-----------|--------|--------|
| [ ] | P | **Manejo de partida corrupta o inexistente** | Al cargar: si falla JSON o falta archivo, mensaje claro y no crashear |
| [x] | M | **Más de un slot de guardado** (ej. 3 slots) | Guardar en user://save_1.json, save_2.json, etc. |
| [ ] | M | **Indicador “Partida guardada”** (ya existe mensaje; verificar que sea visible) | Revisar que el jugador vea confirmación |
| [ ] | M | **Pantalla de carga** al cargar partida | Mínimo: “Cargando…” mientras se reconstruye el mundo |
| [ ] | F | **Auto-guardado** (cada N minutos o al salir) | Opción en configuración; actualmente solo guardado manual |

---

## 📊 Feedback al jugador (gestión/fábrica)

| Estado | Prioridad | Tarea | Notas |
|--------|-----------|--------|--------|
| [ ] | M | **Aviso cuando recursos insuficientes** al craftear | Ej. “Faltan 50 Stability” al intentar construir sin stock |
| [ ] | M | **Tooltip en edificio en el mundo** (nombre + estado) | Al pasar ratón sobre edificio colocado; no solo en HUD |
| [ ] | F | **Estadísticas de sesión** (recursos producidos, tiles limpiados, etc.) | Útil para balance y sensación de progreso |
| [ ] | F | **Resumen al cargar partida** (fecha/hora del guardado, versión) | En pantalla de carga o en menú Cargar |
| [ ] | M | **Versión visible** en menú principal o F1 | Para reportar bugs y saber qué build se juega |

---

## 🎨 UX y accesibilidad

| Estado | Prioridad | Tarea | Notas |
|--------|-----------|--------|--------|
| [ ] | M | **Contraste / tamaño de fuente** (opción básica) | Especialmente en F1/F2 y HUD si hay quejas |
| [ ] | F | **Modo color-blind** (diferenciar Stability/Charge por forma además de color) | Opcional; documentar si se pide |
| [ ] | M | **Confirmar antes de salir sin guardar** | “¿Tienes partida sin guardar. ¿Salir?” al ir al menú o cerrar |
| [ ] | M | **Deshacer última colocación** (opcional) | Útil en fábricas; puede ser “deshacer 1 edificio” con límite |

---

## 🔊 Audio

| Estado | Prioridad | Tarea | Notas |
|--------|-----------|--------|--------|
| [ ] | M | **SFX al colocar edificio** | Refuerza feedback visual (pop/shake) |
| [ ] | M | **SFX al producir recurso** (Compresor, Merger, etc.) | Opcional; puede ser sutil |
| [ ] | F | **SFX al desbloquear tecnología** (F2) | Acompaña notificación de desbloqueo |
| [ ] | M | **Silencio de música en menú** o tema distinto | Si la música actual es solo in-game |

---

## 🧹 Calidad y mantenimiento

| Estado | Prioridad | Tarea | Notas |
|--------|-----------|--------|--------|
| [ ] | P | **Revisar logs de debug** (print / _void_dbg) | Reducir o condicionar a DEBUG_MODE antes de demo |
| [ ] | M | **.cursor/debug.log en .gitignore** | Si no está ya; evitar subir logs |
| [ ] | M | **Documentar constantes de balance** (costes, tiempos) | RECETAS.md ya existe; enlazar desde PROJECT_STATE |
| [ ] | F | **Tests automatizados** (unit/integration) | A largo plazo; Godot tests o scripts de smoke |

---

## 🏭 Específico de cadena de producción

| Estado | Prioridad | Tarea | Notas |
|--------|-----------|--------|--------|
| [ ] | M | **Cola en Constructor** (elegir siguiente receta mientras fabrica) | Mejora UX en partidas largas |
| [ ] | F | **Gráfico de flujo** (qué produce qué) | En F1/F2: diagrama Energía → Quarks → … |
| [ ] | M | **Indicador “en producción” en edificios** | Icono o barra sutil en Compresor/Merger/Constructor |
| [ ] | F | **Alertas de bloqueo** (ej. “Sifón sin salida”) | Opcional; ayuda a depurar diseños |
| [ ] | F | **Balanceo de recursos solicitados** | Evitar desbloquear Fabricador Hadrón antes que Compresores/fábricas normales; orden de Tier1 coherente |
| [ ] | F | **Visión/UI de fábricas más amigable** | Mejorar feedback visual de edificios de producción |
| [ ] | F | **Interfaz externa de progresión/almacenaje** | Panel o HUD que permita ver progresión o almacenaje de fábricas de un vistazo |
| [ ] | M | **Bugs visuales prismas (energía aparece/desaparece)** | Corregir parpadeo o desaparición incorrecta de energía/haces en prismas |

---

## 📱 Demo y publicación

| Estado | Prioridad | Tarea | Notas |
|--------|-----------|--------|--------|
| [ ] | P | **Export HTML5/Windows** estable | ROADMAP 5.4; probar en máquina limpia |
| [ ] | P | **Texto de itch.io** (descripción, controles, versión) | Incluir RECETAS o enlace a doc |
| [ ] | M | **Capturas y GIF** de gameplay | Para itch y redes |
| [ ] | M | **Créditos** (música, Godot, etc.) | En menú o pantalla final |

---

## 🔗 Relación con otros docs

- **4_ROADMAP.md**: tareas ya planificadas (Bloques 5–8).
- **6_TEST_CHECKLIST.md**: pruebas para considerar T1 listo.
- **5_PROJECT_STATE.md**: estado actual, bugs, criterios “done”.
- **9_RECETAS.md**: costes y desbloqueos.

Cuando una tarea de esta lista se lleve a cabo, márcala aquí y, si aplica, añádela al ROADMAP o a PROJECT_STATE como completada.
