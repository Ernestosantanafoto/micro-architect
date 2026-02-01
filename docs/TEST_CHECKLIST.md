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

### Test 1.1: Cámara
- [ ] **Clic derecho + arrastrar**: La cámara rota
- [ ] **Rueda del ratón**: Zoom in/out funciona
- [ ] **Clic medio + arrastrar**: La cámara se mueve lateralmente

### Test 1.2: Menú del Sistema
- [ ] **Botón GUARDAR**: Aparece mensaje de guardado
- [ ] **Botón MENÚ**: Vuelve al menú principal
- [ ] **Tecla F5**: Guarda rápidamente (mensaje en consola)

---

## 🖥️ PARTE 2: HUD Y RECURSOS

### Test 2.1: Visualización del HUD
- [ ] **No hay solapamiento**: GUARDAR y MENÚ se ven completos (sin números encima)
- [ ] **Recursos categorizados**: Aparece "ENERGÍA:", "QUARKS:", "EDIFICIOS:"
- [ ] **Separadores visuales**: Hay líneas verticales entre categorías
- [ ] **Colores correctos**: 
  - Verde para Estabilidad (🔋)
  - Violeta para Carga (⚡)
  - Amarillo para Quarks (🟡🟠)

### Test 2.2: Tooltips
- [ ] **Hover sobre recursos**: Aparece el nombre completo del recurso
- [ ] **Hover sobre botones**: Aparecen tooltips en SIFONES, PRISMAS, etc.

---

## 🔑 PARTE 3: HOTKEYS (ATAJOS DE TECLADO)

### Test 3.1: Tecla ESC
- [ ] **Sin edificio en mano**: ESC abre menú de pausa
- [ ] **Con edificio en mano**: ESC cancela construcción y devuelve al inventario

### Test 3.2: Tecla R
- [ ] **Selecciona un Sifón** (clic en SIFONES → Sifón)
- [ ] **Presiona R**: El edificio fantasma rota 90°
- [ ] **Presiona R 4 veces**: Vuelve a la posición original

### Test 3.3: Tecla 0
- [ ] **Presiona 0**: Se selecciona el God Siphon (edificio dorado)
- [ ] **Aparece fantasma**: El edificio sigue el cursor

### Test 3.4: Teclas 1-9
- [ ] **Presiona 1**: Selecciona el primer edificio disponible
- [ ] **Presiona 2**: Selecciona el segundo edificio disponible
- [ ] **Presiona 3-9**: Selecciona edificios si hay disponibles
- [ ] **Sin edificios**: Mensaje en consola "No hay edificio disponible"

---

## 📖 PARTE 4: PANEL DE AYUDA (F1)

### Test 4.1: Abrir/Cerrar
- [ ] **Presiona F1**: Se abre el panel de ayuda
- [ ] **Presiona F1 de nuevo**: Se cierra el panel
- [ ] **Botón CERRAR**: Cierra el panel

### Test 4.2: Navegación de Pestañas
- [ ] **Clic en "Recursos"**: Cambia a la pestaña de recursos
- [ ] **Clic en "Edificios"**: Cambia a la pestaña de edificios
- [ ] **Clic en "Controles"**: Cambia a la pestaña de controles
- [ ] **Clic en "Objetivos"**: Cambia a la pestaña de objetivos

### Test 4.3: Contenido con Colores
- [ ] **Pestaña Recursos**: "ESTABILIDAD" aparece en verde
- [ ] **Pestaña Recursos**: "CARGA" aparece en violeta
- [ ] **Pestaña Edificios**: Descripciones completas de todos los edificios
- [ ] **Pestaña Controles**: Lista de todos los controles del juego
- [ ] **Pestaña Objetivos**: Cadena de producción Energía → ADN

### Test 4.4: Interacción Durante Ayuda
- [ ] **Panel F1 abierto**: Puedes hacer clic en las pestañas
- [ ] **Panel F1 abierto**: El juego NO está pausado (los edificios siguen funcionando)

---

## 📚 PARTE 5: RECETARIO (F2)

### Test 5.1: Abrir/Cerrar
- [ ] **Presiona F2**: Se abre el panel de recetario
- [ ] **Presiona F2 de nuevo**: Se cierra el panel
- [ ] **Botón CERRAR**: Cierra el panel

### Test 5.2: Tecnologías Iniciales
- [ ] **Nivel "BÁSICO"**: Aparecen Sifón, Prismas con 🔓 (desbloqueados)
- [ ] **Nivel "MANIPULACIÓN"**: Compresor con 🔒 (bloqueado)
- [ ] **Nivel "AVANZADO"**: T2 upgrades con 🔒 (bloqueados)
- [ ] **Nivel "PRODUCCIÓN"**: Fusionador, Constructor con 🔒 (bloqueados)

### Test 5.3: Requisitos Visibles
- [ ] **Compresor bloqueado**: Muestra "Requiere: Sifón" y "Necesita: 10 Stability"
- [ ] **Fusionador bloqueado**: Muestra requisitos de recursos
- [ ] **Tecnologías desbloqueadas**: Muestran la receta de crafting

---

## 🏗️ PARTE 6: CONSTRUCCIÓN Y COLOCACIÓN

### Test 6.1: Selección de Edificios
- [ ] **Clic en SIFONES**: Se abre menú con Sifón, Sifón T2
- [ ] **Clic en un edificio**: Se selecciona y aparece fantasma
- [ ] **Inventario se reduce**: El contador del edificio baja en 1

### Test 6.2: Colocación
- [ ] **Fantasma verde**: Indica posición válida
- [ ] **Fantasma rojo**: Indica posición inválida
- [ ] **Clic izquierdo**: Coloca el edificio en posición válida
- [ ] **Edificio colocado**: Aparece sólido y funcional

### Test 6.3: Rotación Durante Construcción
- [ ] **Con edificio en mano**: Presiona R
- [ ] **Edificio rota**: El fantasma gira 90°
- [ ] **Colocación rotada**: El edificio se coloca con la rotación correcta

### Test 6.4: Cancelación
- [ ] **Con edificio en mano**: Presiona ESC
- [ ] **Fantasma desaparece**: Ya no hay edificio en mano
- [ ] **Inventario restaurado**: El contador vuelve a su valor original

---

## 🔬 PARTE 7: SISTEMA DE PRODUCCIÓN

### Test 7.1: Sifón Básico
- [ ] **Coloca Sifón en loseta verde**: Se activa (luz verde)
- [ ] **Espera 5 segundos**: Aparece haz de luz
- [ ] **Inventario aumenta**: Stability sube en el HUD

### Test 7.2: Compresor
- [ ] **Coloca Compresor cerca del Sifón**: Se conectan automáticamente
- [ ] **Haz de luz**: Va del Sifón al Compresor
- [ ] **Pulsos de energía**: Bolas verdes viajan por el haz
- [ ] **Producción**: Después de 10 pulsos, se crea 1 Compressed-Stability

### Test 7.3: Prismas
- [ ] **Coloca Prisma Recto**: Redirige el haz en línea recta
- [ ] **Coloca Prisma Angular**: Redirige el haz 90°
- [ ] **Pulsos siguen el haz**: Las bolas viajan por los prismas

---

## 🎨 PARTE 8: GOD SIPHON UI

### Test 8.1: Abrir UI
- [ ] **Presiona 0**: Selecciona God Siphon
- [ ] **Coloca God Siphon**: Aparece en el mundo
- [ ] **Clic en God Siphon**: Se abre UI flotante

### Test 8.2: Controles de UI
- [ ] **Dropdown "Color"**: Verde (Estabilidad) / Azul (Carga)
- [ ] **Dropdown "Tipo"**: Energía Base / Comprimida / Quark Up / Down
- [ ] **Slider Energía**: Mueve de 1 a 100
- [ ] **Slider Frecuencia**: Mueve de 1 a 20 ticks
- [ ] **Vista Previa**: Se actualiza en tiempo real

### Test 8.3: Aplicar Cambios
- [ ] **Cambia valores**: Ajusta energía y frecuencia
- [ ] **Botón APLICAR**: Los cambios se aplican al Sifón
- [ ] **Producción cambia**: El Sifón genera con los nuevos valores
- [ ] **Botón RESETEAR**: Vuelve a valores por defecto
- [ ] **Botón CERRAR**: Cierra la UI

---

## 🔄 PARTE 9: DESBLOQUEOS AUTOMÁTICOS

### Test 9.1: Desbloqueo de Compresor
- [ ] **Abre F2**: Compresor está 🔒
- [ ] **Extrae 10+ Stability**: Usa Sifones
- [ ] **Abre F2 de nuevo**: Compresor ahora está 🔓
- [ ] **Mensaje en consola**: "[TECH] 🔓 Desbloqueado: Compresor"

### Test 9.2: Desbloqueo de Fusionador
- [ ] **Crea 5+ Compressed-Stability**: Usa Compresores
- [ ] **Abre F2**: Fusionador ahora está 🔓
- [ ] **Aparece en HUD**: Fusionador disponible en menú MANIPULA

---

## 💾 PARTE 10: GUARDADO Y CARGA

### Test 10.1: Guardar Partida
- [ ] **Construye varios edificios**: Sifones, Compresores, etc.
- [ ] **Presiona GUARDAR**: Mensaje de confirmación
- [ ] **Cierra el juego**: Vuelve al menú principal

### Test 10.2: Cargar Partida
- [ ] **Abre el juego**: Clic en "CARGAR"
- [ ] **Edificios restaurados**: Todos los edificios están en su lugar
- [ ] **Inventario correcto**: Recursos y edificios tienen los valores guardados
- [ ] **Tecnologías desbloqueadas**: F2 muestra el progreso guardado
- [ ] **Producción funciona**: Los edificios siguen generando recursos

---

## 🐛 PARTE 11: BUGS CONOCIDOS (VERIFICAR QUE ESTÉN ARREGLADOS)

### Test 11.1: Bug de Solapamiento
- [ ] **GUARDAR visible**: El texto "GUARDAR" se ve completo
- [ ] **MENÚ visible**: El texto "MENÚ" se ve completo
- [ ] **Sin números encima**: No hay "100" o "E 99" sobre los botones

### Test 11.2: Bug de F1
- [ ] **F1 abre**: El panel se abre correctamente
- [ ] **Pestañas clicables**: Puedes cambiar entre pestañas
- [ ] **F1 cierra**: El panel se cierra correctamente
- [ ] **Botón CERRAR funciona**: Cierra el panel

### Test 11.3: Bug de Hotkeys
- [ ] **R funciona**: Rota edificios
- [ ] **ESC funciona**: Cancela construcción
- [ ] **0 funciona**: Selecciona God Siphon
- [ ] **1-9 funcionan**: Seleccionan edificios

### Test 11.4: Bug de Colores
- [ ] **ESTABILIDAD verde**: En HUD y F1
- [ ] **CARGA violeta**: En HUD y F1
- [ ] **Quarks amarillo/naranja**: En HUD

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
