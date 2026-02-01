# 🧪 CHECKLIST DE PRUEBAS - v0.4 Polish

**Fecha:** 2025-02-01  
**Versión:** 0.4-alpha  
**Objetivo:** Verificar todas las mejoras implementadas

---

## 📋 INSTRUCCIONES

1. Abre el juego en Godot
2. Presiona F5 para ejecutar
3. Crea una nueva partida
4. Sigue los pasos en orden
5. Marca ✅ si funciona, ❌ si falla

---

## 🎮 PARTE 1: CONTROLES BÁSICOS

### Test 1.1: Cámara (solo zoom)
- [ ] **Rueda del ratón**: Zoom in/out funciona
- [ ] **Nota**: La cámara NO rota ni se mueve con arrastrar (no es parte del juego)

### Test 1.2: Menú del Sistema
- [x ] **Botón GUARDAR**: Aparece mensaje de guardado
- [ v] **Botón MENÚ**: Vuelve al menú principal
- [v ] **Tecla F5**: Guarda rápidamente (mensaje en consola)

---

## 🖥️ PARTE 2: HUD Y RECURSOS

### Test 2.1: Visualización del HUD
- [x ] **No hay solapamiento**: GUARDAR y MENÚ se ven completos (sin números encima)
- [ x] **Recursos categorizados**: Aparece "ENERGÍA:", "QUARKS:", "EDIFICIOS:"
- [x ] **Separadores visuales**: Hay líneas verticales entre categorías
- [x ] **Colores correctos**: 
  - Verde para Estabilidad (🔋)
  - Violeta para Carga (⚡)
  - Amarillo para Quarks (🟡🟠)

### Test 2.2: Tooltips
- [x ] **Hover sobre recursos**: Aparece el nombre completo del recurso
- [ v] **Hover sobre botones**: Aparecen tooltips en SIFONES, PRISMAS, etc.

---

## 🔑 PARTE 3: HOTKEYS (ATAJOS DE TECLADO)

### Test 3.1: Tecla ESC
- [ v] **Sin edificio en mano**: ESC abre menú de pausa
- [v ] **Con edificio en mano**: ESC cancela construcción y devuelve al inventario

### Test 3.2: Tecla R
- [v ] **Selecciona un Sifón** (clic en SIFONES → Sifón)
- [ v] **Presiona R**: El edificio fantasma rota 90°
- [ v] **Presiona R 4 veces**: Vuelve a la posición original

### Test 3.3: Tecla 0 (solo modo DEV)
- [ ] **Con DEBUG_MODE:** Presiona 0 → se selecciona God Siphon
- [ ] **Sin DEBUG_MODE:** Tecla 0 no hace nada (God Siphon no en partida normal)

### Test 3.4: Teclas 1-9
- [ ] **Presiona 1**: Selecciona el primer edificio disponible (por orden en RECETAS)
- [ ] **Presiona 2-9**: Selecciona edificios si hay en inventario
- [ ] **Sin edificios**: No hace nada (sin mensaje)

### Test 3.5: Clic central (ratón)
- [ ] **Clic central en edificio puesto:** Obtienes uno igual en mano (misma orientación), si tienes en inventario
- [ ] **Clic central en suelo válido con edificio en mano:** Colocas y te quedas con otro en mano (si queda en inventario)

---

## 📖 PARTE 4: PANEL DE AYUDA (F1)

### Test 4.1: Abrir/Cerrar
- [ v] **Presiona F1**: Se abre el panel de ayuda
- [v ] **Presiona F1 de nuevo**: Se cierra el panel
- [ v] **Botón CERRAR**: Cierra el panel

### Test 4.2: Navegación de Pestañas
- [ v] **Clic en "Recursos"**: Cambia a la pestaña de recursos
- [v ] **Clic en "Edificios"**: Cambia a la pestaña de edificios
- [ v] **Clic en "Controles"**: Cambia a la pestaña de controles
- [ v] **Clic en "Objetivos"**: Cambia a la pestaña de objetivos

### Test 4.3: Contenido con Colores
- [ v] **Pestaña Recursos**: "ESTABILIDAD" aparece en verde
- [ v] **Pestaña Recursos**: "CARGA" aparece en violeta
- [ v] **Pestaña Edificios**: Descripciones completas de todos los edificios
- [ v] **Pestaña Controles**: Lista de todos los controles del juego
- [ v] **Pestaña Objetivos**: Cadena de producción Energía → ADN

### Test 4.4: Interacción Durante Ayuda
- [ ] **Panel F1 abierto**: Puedes hacer clic en las pestañas
- [ ] **Panel F1 abierto**: El juego está pausado (los edificios no avanzan)

---

## 📚 PARTE 5: RECETARIO (F2)

### Test 5.1: Abrir/Cerrar
- [ v] **Presiona F2**: Se abre el panel de recetario
- [v ] **Presiona F2 de nuevo**: Se cierra el panel
- [ v] **Botón CERRAR**: Cierra el panel

### Test 5.2: Tecnologías Iniciales
- [ v] **Nivel "BÁSICO"**: Aparecen Sifón, Prismas con 🔓 (desbloqueados)
- [ v] **Nivel "MANIPULACIÓN"**: Compresor con 🔒 (bloqueado)
- [ v] **Nivel "AVANZADO"**: T2 upgrades con 🔒 (bloqueados)
- [v ] **Nivel "PRODUCCIÓN"**: Fusionador, Constructor con 🔒 (bloqueados)

### Test 5.3: Requisitos Visibles
- [v ] **Compresor bloqueado**: Muestra "Requiere: Sifón" y "Necesita: 10 Stability"
- [ v] **Fusionador bloqueado**: Muestra requisitos de recursos
- [x ] **Tecnologías desbloqueadas**: Muestran la receta de crafting

---

## 🏗️ PARTE 6: CONSTRUCCIÓN Y COLOCACIÓN

### Test 6.1: Selección de Edificios
- [v ] **Clic en SIFONES**: Se abre menú con Sifón, Sifón T2
- [v ] **Clic en un edificio**: Se selecciona y aparece fantasma
- [ v] **Inventario se reduce**: El contador del edificio baja en 1

### Test 6.2: Colocación
- [ v] **Fantasma verde**: Indica posición válida
- [v ] **Fantasma rojo**: Indica posición inválida
- [ v] **Clic izquierdo**: Coloca el edificio en posición válida
- [ v] **Edificio colocado**: Aparece sólido y funcional

### Test 6.3: Rotación Durante Construcción
- [ v] **Con edificio en mano**: Presiona R
- [v ] **Edificio rota**: El fantasma gira 90°
- [v ] **Colocación rotada**: El edificio se coloca con la rotación correcta

### Test 6.4: Cancelación
- [v ] **Con edificio en mano**: Presiona ESC
- [ v] **Fantasma desaparece**: Ya no hay edificio en mano
- [ v] **Inventario restaurado**: El contador vuelve a su valor original

---

## 🔬 PARTE 7: SISTEMA DE PRODUCCIÓN

### Test 7.1: Sifón Básico
- [ v] **Coloca Sifón en loseta verde**: Se activa (luz verde)
- [ v] **Espera 5 segundos**: Aparece haz de luz
- [ ?] **Inventario aumenta**: Stability sube en el HUD

### Test 7.2: Compresor
- [v ] **Coloca Compresor cerca del Sifón**: Se conectan automáticamente
- [v ] **Haz de luz**: Va del Sifón al Compresor
- [ v] **Pulsos de energía**: Bolas verdes viajan por el haz
- [v ] **Producción**: Después de 10 pulsos, se crea 1 Compressed-Stability

### Test 7.3: Prismas
- [v ] **Coloca Prisma Recto**: Redirige el haz en línea recta
- [v ] **Coloca Prisma Angular**: Redirige el haz 90°
- [ v] **Pulsos siguen el haz**: Las bolas viajan por los prismas

---

## 🎨 PARTE 8: GOD SIPHON UI

### Test 8.1: Abrir UI
- [v ] **Presiona 0**: Selecciona God Siphon
- [ v] **Coloca God Siphon**: Aparece en el mundo
- [v ] **Clic en God Siphon**: Se abre UI flotante

### Test 8.2: Controles de UI
- [ v] **Dropdown "Color"**: Verde (Estabilidad) / Azul (Carga)
- [ v] **Dropdown "Tipo"**: Energía Base / Comprimida / Quark Up / Down
- [v ] **Slider Energía**: Mueve de 1 a 100
- [v ] **Slider Frecuencia**: Mueve de 1 a 20 ticks
- [ v] **Vista Previa**: Se actualiza en tiempo real

### Test 8.3: Aplicar Cambios
- [v ] **Cambia valores**: Ajusta energía y frecuencia
- [ v] **Botón APLICAR**: Los cambios se aplican al Sifón
- [v ] **Producción cambia**: El Sifón genera con los nuevos valores
- [ v] **Botón RESETEAR**: Vuelve a valores por defecto
- [ v] **Botón CERRAR**: Cierra la UI

---

## 🔄 PARTE 9: DESBLOQUEOS AUTOMÁTICOS

### Test 9.1: Desbloqueo de Compresor
- [ v] **Abre F2**: Compresor está 🔒
- [ v] **Extrae 10+ Stability**: Usa Sifones
- [x ] **Abre F2 de nuevo**: Compresor ahora está 🔓
- [x ] **Mensaje en consola**: "[TECH] 🔓 Desbloqueado: Compresor"

### Test 9.2: Desbloqueo de Fusionador
- [ v] **Crea 5+ Compressed-Stability**: Usa Compresores
- [ x] **Abre F2**: Fusionador ahora está 🔓
- [ x] **Aparece en HUD**: Fusionador disponible en menú MANIPULA

---

## 💾 PARTE 10: GUARDADO Y CARGA

### Test 10.1: Guardar Partida
- [ v] **Construye varios edificios**: Sifones, Compresores, etc.
- [ v] **Presiona GUARDAR**: Mensaje de confirmación
- [ v] **Cierra el juego**: Vuelve al menú principal

### Test 10.2: Cargar Partida
- [v ] **Abre el juego**: Clic en "CARGAR"
- [v ] **Edificios restaurados**: Todos los edificios están en su lugar
- [v ] **Inventario correcto**: Recursos y edificios tienen los valores guardados
- [? ] **Tecnologías desbloqueadas**: F2 muestra el progreso guardado
- [ v] **Producción funciona**: Los edificios siguen generando recursos

---

## 🐛 PARTE 11: BUGS CONOCIDOS (VERIFICAR QUE ESTÉN ARREGLADOS)

### Test 11.1: Bug de Solapamiento
- [ x] **GUARDAR visible**: El texto "GUARDAR" se ve completo
- [ x] **MENÚ visible**: El texto "MENÚ" se ve completo
- [ x] **Sin números encima**: No hay "100" o "E 99" sobre los botones

### Test 11.2: Bug de F1
- [v ] **F1 abre**: El panel se abre correctamente
- [v ] **Pestañas clicables**: Puedes cambiar entre pestañas
- [v ] **F1 cierra**: El panel se cierra correctamente
- [ v] **Botón CERRAR funciona**: Cierra el panel

### Test 11.3: Bug de Hotkeys
- [v ] **R funciona**: Rota edificios
- [v ] **ESC funciona**: Cancela construcción
- [v ] **0 funciona**: Selecciona God Siphon
- [x] **1-9 funcionan**: Seleccionan edificios

### Test 11.4: Bug de Colores
- [v ] **ESTABILIDAD verde**: En HUD y F1
- [v ] **CARGA violeta**: En HUD y F1
- [x ] **Quarks amarillo/naranja**: En HUD

---

## 📊 RESUMEN DE PRUEBAS

**Total de checks:** 100+

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

Si todos los tests pasan:
1. ✅ Marcar v0.4-alpha como estable
2. ✅ Crear tag en GitHub: `v0.4-alpha`
3. ✅ Comenzar planificación de v0.5 (Electrones)

Si hay bugs:
1. ❌ Documentar bugs en este archivo
2. ❌ Crear issues en GitHub (opcional)
3. ❌ Priorizar y arreglar bugs críticos
4. ❌ Repetir tests

---

**¡Buena suerte con las pruebas!** 🚀
