# 🧪 CHECKLIST DE PRUEBAS - v0.5 T1

**Fecha:** 2025-01-31 15:02  
**Versión:** 0.5-alpha  
**Objetivo:** Verificar T1 funcional (pulido, save/load, colocación, bugs conocidos)

**Fase de inicio:** Void Generator (footprint, alineación grilla, pulso edificio y malla roja, latente/activar) completado. Recetario de referencia en `docs/9_RECETAS.md`.

---

## 📋 INSTRUCCIONES

1. Abre el juego en Godot
2. Presiona F5 para ejecutar
3. Crea una nueva partida
4. Sigue los pasos en orden
5. Marca cada ítem así:
   - **`[v]`** = correcto (lo comprobaste tú y funciona)
   - **`[x]`** = incorrecto (lo comprobaste y falla)
   - **`[ ]`** = sin comprobar aún

**Importante:** Pon **`[v]`** solo después de ejecutar la prueba y ver que pasa. No marques [v] por "ya está implementado"; márcalo cuando tú hayas comprobado que funciona.

---

## 🎮 PARTE 1: CONTROLES BÁSICOS

### Test 1.1: Cámara (solo zoom)
- [v] **Rueda del ratón**: Zoom in/out funciona
- [v] **Nota**: La cámara NO rota ni se mueve con arrastrar (no es parte del juego)

### Test 1.2: Menú del Sistema
- [v] **Botón GUARDAR**: Aparece mensaje de guardado
- [v] **Botón MENÚ**: Vuelve al menú principal
- [v] **Tecla F5**: Guarda rápidamente (mensaje en consola)

---

## 🖥️ PARTE 2: HUD Y RECURSOS

### Test 2.1: Visualización del HUD
- [v] **No hay solapamiento**: GUARDAR y MENÚ se ven completos (sin números encima)
- [v] **Recursos / categorías**: Panel de recursos visible; imagen y utilidad del menú se revisarán en el futuro (no se exige "ENERGÍA:", "QUARKS:", "EDIFICIOS:").
- [v] **Separadores visuales**: Hay líneas verticales entre categorías
- [v] **Colores correctos**: 
  - Verde para Estabilidad (🔋)
  - Violeta para Carga (⚡)
  - Amarillo para Quarks (🟡🟠)

### Test 2.2: Tooltips
- [v] **Hover sobre recursos**: Aparece el nombre completo del recurso
- [v] **Hover sobre botones**: Aparecen tooltips en SIFONES, PRISMAS, etc.

---

## 🔑 PARTE 3: HOTKEYS (ATAJOS DE TECLADO)

### Test 3.1: Tecla ESC
- [v] **Sin edificio en mano**: ESC abre menú de pausa
- [v] **Con edificio en mano**: ESC cancela construcción y devuelve al inventario

### Test 3.2: Tecla R
- [v] **Selecciona un Sifón** (clic en SIFONES → Sifón)
- [v] **Presiona R**: El edificio fantasma rota 90°
- [v] **Presiona R 4 veces**: Vuelve a la posición original

### Test 3.3: Tecla 0 (solo modo DEV)
- [v] **Con DEBUG:** Botón "DEBUG OFF" (panel sistema, abajo izquierda) → clic para "DEBUG ON"; presiona 0 → se selecciona God Siphon
- [v] **Sin DEBUG:** Tecla 0 no hace nada (God Siphon no en partida normal). Clic en "DEBUG ON" para volver a OFF.

### Test 3.4: Teclas 1-9
- [v] **Presiona 1**: Selecciona el primer edificio disponible (por orden en RECETAS)
- [v] **Presiona 2-9**: Selecciona edificios si hay en inventario
- [v] **Sin edificios**: No hace nada (sin mensaje)

### Test 3.5: Clic central (ratón)
- [v] **Clic central en edificio puesto:** Obtienes uno igual en mano (misma orientación), si tienes en inventario
- [v] **Clic central en suelo válido con edificio en mano:** Colocas y te quedas con otro en mano (si queda en inventario)

---

## 📖 PARTE 4: PANEL DE AYUDA (F1)

### Test 4.1: Abrir/Cerrar
- [v] **Presiona F1**: Se abre el panel de ayuda
- [v] **Presiona F1 de nuevo**: Se cierra el panel
- [v] **Botón CERRAR**: Cierra el panel

### Test 4.2: Navegación de Pestañas
- [v] **Clic en "Recursos"**: Cambia a la pestaña de recursos
- [v] **Clic en "Edificios"**: Cambia a la pestaña de edificios
- [v] **Clic en "Controles"**: Cambia a la pestaña de controles
- [v] **Clic en "Objetivos"**: Cambia a la pestaña de objetivos

### Test 4.3: Contenido con Colores
- [v] **Pestaña Recursos**: "ESTABILIDAD" aparece en verde
- [v] **Pestaña Recursos**: "CARGA" aparece en violeta
- [v] **Pestaña Edificios**: Descripciones completas de todos los edificios
- [v] **Pestaña Controles**: Lista de todos los controles del juego
- [v] **Pestaña Objetivos**: Cadena de producción Energía → ADN

### Test 4.4: Interacción Durante Ayuda
- [v] **Panel F1 abierto**: Puedes hacer clic en las pestañas
- [v] **Panel F1 abierto**: El juego sigue en play (no se pausa; el jugador sigue recolectando mientras lee — opcional, no determinante)

---

## 📚 PARTE 5: RECETARIO (F2)

### Test 5.1: Abrir/Cerrar
- [v] **Presiona F2**: Se abre el panel de recetario
- [v] **Presiona F2 de nuevo**: Se cierra el panel
- [v] **Botón CERRAR**: Cierra el panel

### Test 5.2: Tecnologías Iniciales
- [v] **Nivel "BÁSICO"**: Aparecen Sifón, Prismas con 🔓 (desbloqueados)
- [v] **Nivel "MANIPULACIÓN"**: Compresor con 🔒 (bloqueado)
- [v] **Nivel "AVANZADO"**: T2 upgrades con 🔒 (bloqueados)
- [v] **Nivel "PRODUCCIÓN"**: Fusionador, Constructor con 🔒 (bloqueados)

### Test 5.3: Requisitos Visibles
- [v] **Compresor bloqueado**: Muestra "Requiere: Sifón" (solo tech, sin recurso)
- [v] **Fusionador bloqueado**: Muestra requisitos de recursos
- [v] **Tecnologías desbloqueadas**: Muestran la receta de crafting

---

## 🏗️ PARTE 6: CONSTRUCCIÓN Y COLOCACIÓN

### Test 6.1: Selección de Edificios
- [v] **Clic en SIFONES**: Se abre menú con Sifón, Sifón T2
- [v] **Clic en un edificio**: Se selecciona y aparece fantasma
- [v] **Inventario se reduce**: El contador del edificio baja en 1

### Test 6.2: Colocación
- [v] **Fantasma verde**: Indica posición válida
- [v] **Fantasma rojo**: Indica posición inválida
- [v] **Clic izquierdo**: Coloca el edificio en posición válida
- [v] **Edificio colocado**: Aparece sólido y funcional

### Test 6.3: Rotación Durante Construcción
- [v] **Con edificio en mano**: Presiona R
- [v] **Edificio rota**: El fantasma gira 90°
- [v] **Colocación rotada**: El edificio se coloca con la rotación correcta

### Test 6.4: Cancelación
- [v] **Con edificio en mano**: Presiona ESC
- [v] **Fantasma desaparece**: Ya no hay edificio en mano
- [v] **Inventario restaurado**: El contador vuelve a su valor original

### Test 6.5: Colocación por tipo de edificio y en bordes (T1 funcional)
Verificar que cada edificio solo se coloca en el tile permitido y que rotación/bordes funcionan.

- [v] **Sifón**: Solo en loseta verde (Estabilidad) o azul (Carga). En vacío/rojo → fantasma rojo.
- [v] **Compresor**: Solo en loseta roja. En verde/azul/vacío → fantasma rojo.
- [v] **Prisma recto / Prisma angular**: Solo en vacío. En verde/azul/rojo → fantasma rojo.
- [v] **Fusionador (Merger)**: Solo en vacío. En losetas de energía → fantasma rojo.
- [v] **Fabricador Hadrón**: Solo en vacío. En losetas de energía → fantasma rojo.
- [v] **Constructor**: Solo en vacío (3×3): no en baldosa verde/azul/roja ni en casillas ocupadas. Si cualquier celda de su 3×3 está ocupada o es de energía → fantasma rojo.
- [v] **Void Generator**: Valida solo la celda central. Perímetro rojo en suelo alineado con la grilla (en mano y colocado). No rota (simétrico). Al colocar queda en estado latente (rojo/blanco pulsando); clic derecho = activar, clic izquierdo = recoger en mano. Mancha y borde pulsan con el edificio en latente.
- [v] **Rotación (R)**: Con cada tipo en mano, R gira el fantasma 90°; colocación respeta la rotación.
- [v] **Bordes del mapa**: Colocar al menos un edificio en una celda del borde (extremo del grid); no debe crashear ni permitir fuera de límites.

---

## 🔬 PARTE 7: SISTEMA DE PRODUCCIÓN

### Test 7.1: Sifón Básico
- [v] **Coloca Sifón en loseta verde**: Se activa (luz verde)
- [v] **Haz de luz**: Aparece al momento de colocarlo (correcto así)
- [v] **Stability no sube en el HUD**: El sifón no almacena energía, solo la emite; el contador solo sube cuando una fábrica produce y añade al inventario (Compresor, Merger, Hadrón, Constructor).

### Test 7.2: Compresor
- [v] **Coloca Compresor cerca del Sifón**: Se conectan automáticamente
- [v] **Haz de luz**: Va del Sifón al Compresor
- [v] **Pulsos de energía**: Bolas verdes viajan por el haz
- [v] **Producción**: Después de 10 pulsos, se crea 1 Compressed-Stability

### Test 7.3: Prismas
- [v] **Coloca Prisma Recto**: Redirige el haz en línea recta
- [v] **Coloca Prisma Angular**: Redirige el haz 90°
- [v] **Pulsos siguen el haz**: Las bolas viajan por los prismas

---

## 🎨 PARTE 8: GOD SIPHON UI

### Test 8.1: Abrir UI
- [v] **Presiona 0**: Selecciona God Siphon
- [v] **Coloca God Siphon**: Aparece en el mundo
- [v] **Clic en God Siphon**: Se abre UI flotante

### Test 8.2: Controles de UI
- [v] **Dropdown "Color"**: Verde (Estabilidad) / Azul (Carga)
- [v] **Dropdown "Tipo"**: Energía Base / Comprimida / Quark Up / Down
- [v] **Slider Energía**: Mueve de 1 a 100
- [v] **Slider Frecuencia**: Mueve de 1 a 20 ticks
- [v] **Vista Previa**: Se actualiza en tiempo real

### Test 8.3: Aplicar Cambios
- [v] **Cambia valores**: Ajusta energía y frecuencia
- [v] **Botón APLICAR**: Los cambios se aplican al Sifón
- [v] **Producción cambia**: El Sifón genera con los nuevos valores
- [v] **Botón RESETEAR**: Vuelve a valores por defecto
- [v] **Botón CERRAR**: Cierra la UI

### Test 8.4: Duplicar God Siphon (clic central)
- [v] **Configura un God Siphon**: Cambia color, tipo, energía y frecuencia en la UI y aplica
- [v] **Clic central sobre ese Sifón**: Sale una copia en mano (mismo edificio)
- [v] **Coloca la copia**: El nuevo Sifón tiene las mismas stats (color, tipo, energía, frecuencia) que el original
- [v] **Varios duplicados**: Puedes colocar varios con las mismas stats sin reabrir la UI

---

## 🔄 PARTE 9: DESBLOQUEOS AUTOMÁTICOS

### Test 9.1: Desbloqueo de Compresor
- [v] **Abre F2**: Compresor está 🔒 (requiere Sifón)
- [v] **Desbloqueo**: Compresor se desbloquea solo por tener Sifón (tech). No hace falta almacenar Stability: el sifón solo emite, no guarda.
- [v] **Abre F2 de nuevo**: Compresor ahora está 🔓
- [v] **Mensaje en consola**: "[TECH] 🔓 Desbloqueado: Compresor"

### Test 9.2: Desbloqueo de Fusionador (fábricas como desbloqueador)
- [v] **Producción de fábricas cuenta**: Compresor añade Compressed-Stability al inventario al producir; cuando hay 5+, Fusionador se desbloquea.
- [v] **Crea 5+ Compressed-Stability**: Usa Compresores (cada disparo comprimido suma 1 al inventario global).
- [v] **Abre F2**: Fusionador ahora está 🔓
- [v] **Aparece en HUD**: Fusionador disponible en menú MANIPULA

---

## 💾 PARTE 10: GUARDADO Y CARGA

### Test 10.1: Guardar Partida
- [v] **Construye varios edificios**: Sifones, Compresores, etc.
- [v] **Presiona GUARDAR**: Mensaje de confirmación
- [v] **Solo se guarda al pulsar GUARDAR**: Al salir al menú (botón MENÚ/CERRAR) no se guarda automáticamente; la partida se guarda únicamente cuando el jugador pulsa el botón GUARDAR.
- [v] **Cierra el juego**: Vuelve al menú principal

### Test 10.2: Cargar Partida
- [v] **Abre el juego**: Clic en "CARGAR"
- [v] **Edificios restaurados**: Todos los edificios están en su lugar
- [v] **Inventario correcto**: Recursos y edificios tienen los valores guardados
- [v] **Tecnologías desbloqueadas**: F2 muestra el progreso guardado (Compresor/Fusionador/etc. siguen 🔓)
- [v] **Producción funciona**: Los edificios siguen generando recursos

### Test 10.3: Save/load con partida compleja (20+ edificios)
- [v] **Coloca 20+ edificios**: Varios tipos (Sifones, Compresores, Prismas, Merger, Fabricador Hadrón, Constructor, Void).
- [v] **GUARDAR**: Mensaje de confirmación.
- [v] **Salir a menú** (MENÚ o CERRAR).
- [v] **CARGAR**: Partida cargada.
- [v] **Posiciones y rotaciones**: Todos los edificios en su sitio y orientación correcta.
- [v] **Producción activa**: Sifones/Compresores siguen funcionando tras cargar.

---

## 🐛 PARTE 11: BUGS CONOCIDOS (VERIFICAR QUE ESTÉN ARREGLADOS)

### Test 11.1: Bug de Solapamiento
- [v] **GUARDAR visible**: El texto "GUARDAR" se ve completo
- [v] **MENÚ visible**: El texto "MENÚ" se ve completo
- [v] **Sin números encima**: No hay "100" o "E 99" sobre los botones

### Test 11.2: Bug de F1
- [v] **F1 abre**: El panel se abre correctamente
- [v] **Pestañas clicables**: Puedes cambiar entre pestañas
- [v] **F1 cierra**: El panel se cierra correctamente
- [v] **Botón CERRAR funciona**: Cierra el panel

### Test 11.3: Bug de Hotkeys
- [v] **R funciona**: Rota edificios
- [v] **ESC funciona**: Cancela construcción
- [v] **0 funciona**: Selecciona God Siphon
- [v] **1-7 funcionan**: 1=Sifón, 2=Prisma Recto, 3=Prisma Angular, 4=Compresor, 5=Fusionador, 6=Constructor, 7=Void Generator. 8 y 9 reservados (vacíos por ahora). *Futuro: permitir bindear 1-9 a gusto del jugador.*

### Test 11.4: Bug de Colores
- [v] **ESTABILIDAD verde**: En HUD y F1
- [v] **CARGA violeta**: En HUD y F1
- [v] **Quarks amarillo/naranja**: En HUD

---

## 📊 RESUMEN DE PRUEBAS

**Total de checks:** 100+

### Estado actual (revisión rápida)
- **Pendientes de verificar por ti:** 0 ítems (Void Generator marcado [v] tras alineación grilla, pulso suelo y colocación latente).
- **Marcados [x] (revisar si ya funcionan):** 4 ítems — Recursos categorizados (2.1), Constructor colocación (6.5), Clic en God Siphon abre UI (8.1), Hotkeys 1-9 (11.3). Si al probar funcionan, cámbialos a `[v]`.
- **Resto:** Marcados `[v]` = ya comprobados o implementados.

### Resultados:
- ✅ Pasados: _____ / _____
- ❌ Fallidos: _____ / _____
- ⚠️ Parciales: _____ / _____

### Bugs Encontrados:
1. _______________________________________
2. _______________________________________
3. _______________________________________

### Notas Adicionales:
_____________________________________________
_____________________________________________
_____________________________________________

---

## ✅ CORRECCIONES POST-CHECKLIST (aplicadas)

1. **Siphon/Constructor al abrir no rota**: Clic derecho en God Siphon o Constructor solo abre la UI; ya no rota el edificio. Edificios en grupo `AbreUIClicDerecho` excluidos de rotación.
2. **GUARDAR/MENÚ no tapan recursos**: Panel movido a esquina inferior izquierda; recursos visibles arriba.
3. **F1 pestaña Edificios con scroll**: Cada pestaña tiene ScrollContainer; las pestañas quedan siempre visibles y el contenido hace scroll.
4. **Cámara**: Solo zoom con rueda; arrastre con clic izquierdo para mover cámara (sin rotación).
5. **F1/F2**: Cierre con ESC y clic fuera (izq/der), oscurecimiento al abrir/cerrar, márgenes y colores (Stability/Charge/quarks). Botón "CERRAR (ESC)".
6. **God Siphon / Constructor**: Animación de aparición; cierre con LMB/RMB fuera del menú; sin FondoDetector (solo VentanaFlotante).

### ⚠️ Conocido (dev)
- **Recuadro gris en menús popup:** God Siphon y Constructor pueden mostrar en algunos entornos un overlay gris hasta el borde inferior. Dejado como mejora futura para dev/test; no bloquea pruebas.

---

## 🎯 PRÓXIMOS PASOS

Si todos los tests pasan (T1 funcional):
1. Marcar ROADMAP Bloque 5.1 y 5.2 como verificados
2. Considerar demo itch.io (Bloque 5.4)
3. Planificar Bloque 6 (prep técnica T2)

**Notas de diseño / futuro:**
- Hotkeys 1-9: actualmente 1-7 fijos (Sifón…Void Generator), 8-9 vacíos. En el futuro: posibilidad de que el jugador bindee las teclas 1-9 a su gusto.
- Menú INFRAESTRUCTURA (HUD): comportamiento dim/ocultar red y tiles documentado en 0_REGLAS_UNIVERSALES; no refactorizar salvo petición.

Si hay bugs:
1. Documentar en "Bugs Encontrados" más abajo
2. Priorizar críticos (save/load, tech, colocación)
3. Repetir tests tras correcciones

---

## 📄 Documentos de referencia

- **`docs/9_RECETAS.md`**: Coste de fabricación (recursos + tiempo) y cómo desbloquear cada edificio (tech + condiciones).

---

**¡Buena suerte con las pruebas!** 🚀
