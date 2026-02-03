# ✅ Checklist de test – Cambios de la sesión

**Objetivo:** Probar todo lo implementado/corregido en esta sesión y dejar el juego fetén.  
**Fecha de referencia:** 2025-01-31

---

## 🖱️ Clic central (botón central del ratón)

| [ ] | Prueba | Cómo verificar |
|-----|--------|-----------------|
| [ ] | **Clic central sobre edificio (con stock)** | Coloca un edificio (ej. Prisma). Con al menos 1 en inventario, haz clic central sobre ese edificio. Debe aparecer uno igual en mano, misma orientación. |
| [ ] | **Clic central sobre suelo válido con algo en mano** | Con un edificio en mano y posición válida (verde), clic central. Debe colocar y, si queda stock, ponerte otro en mano. Repetir hasta agotar inventario. |
| [ ] | **Sin botón CLONAR en la barra** | La barra inferior (SIFONES, PRISMAS, MANIPULA, CONSTR, SOLTAR, ELIMINAR) no debe tener botón "CLONAR". |
| [ ] | **Clic central no hace nada sin stock** | Sin ese tipo en inventario, clic central sobre el edificio no debe poner nada en mano (comportamiento normal). |

---

## 🔧 Modo DEBUG y clic central

| [ ] | Prueba | Cómo verificar |
|-----|--------|-----------------|
| [ ] | **Activar DEBUG** | MENU → DEBUG OFF → debe pasar a "DEBUG ON" (o similar). |
| [ ] | **Clic central clona siempre en DEBUG** | Con DEBUG activo, clic central sobre cualquier edificio (sifón, prisma, compresor, fusionador, etc.) debe ponerte uno en mano aunque tengas 0 en inventario. |
| [ ] | **Misma orientación al clonar en DEBUG** | El fantasma en mano debe tener la misma rotación que el edificio clonado. |
| [ ] | **Colocar y seguir clonando en DEBUG** | Con algo en mano (clonado en DEBUG), clic central en suelo válido: coloca y te vuelve a dar otro en mano (sin consumir inventario en DEBUG). |

---

## 💾 Guardado y carga (mapa + edificios)

| [ ] | Prueba | Cómo verificar |
|-----|--------|-----------------|
| [ ] | **Guardar con edificios** | Coloca varios edificios (sifones, prismas, compresores, etc.). MENU → GUARDAR → elige slot y guarda. |
| [ ] | **Cargar partida** | Sal al menú principal (MENU → SALIR). Cargar la partida del mismo slot. Debe aparecer el mismo mapa (terreno) y los mismos edificios en sus posiciones. |
| [ ] | **Cargar in-game** | En partida, coloca más edificios, GUARDAR. Luego MENU → CARGAR → mismo slot. El mundo debe actualizarse con mapa + todos los edificios guardados. |

---

## 🏭 Compresor T1 y T2

| [ ] | Prueba | Cómo verificar |
|-----|--------|-----------------|
| [ ] | **Compresor T2 sin brillo** | El compresor T2 (dorado) no debe emitir glow/brillo en su textura; aspecto más mate. |
| [ ] | **UI T1 al rotar** | Coloca un Compresor T1. Rótalo con clic derecho varias veces. La barra y el texto (X/10) no deben “saltar” ni cambiar de posición; deben quedarse fijos sobre el compresor. |
| [ ] | **Barra del compresor al comprimir** | Cuando el compresor recibe 10 de energía y empieza a comprimir, la barra debe **bajar** de lleno a vacío (cuenta atrás), no llenarse de 0 a 100. |
| [ ] | **Compresor rotable** | Clic derecho sobre un compresor colocado debe **rotarlo** (como cualquier otro edificio), no abrir ninguna ventana. |
| [ ] | **Compresor acepta E y C** | Un mismo compresor puede recibir pulsos de Estabilidad y de Carga; comprime según el último tipo recibido (comportamiento clásico, sin UI de elección). |

---

## 🔀 Merger (UI existente)

| [ ] | Prueba | Cómo verificar |
|-----|--------|-----------------|
| [ ] | **Abrir UI del Merger** | Clic derecho sobre un Fusionador (Merger) colocado. Debe abrirse la ventana flotante (producto UP/DOWN, purga E/C). |
| [ ] | **Cambiar producto y purgar** | En la UI, cambia entre UP y DOWN. Usa "Purga E" / "Purga C" si tienes almacenado; los valores deben actualizarse. |

---

## 🎮 Flujo rápido general

| [ ] | Prueba | Cómo verificar |
|-----|--------|-----------------|
| [ ] | **Colocar → Rotar → Guardar → Cargar** | Coloca 2–3 edificios, rota alguno, guarda, sal y carga. Todo debe verse igual. |
| [ ] | **Clic central en cadena** | Con varios del mismo tipo en inventario, usa solo clic central para colocar varios seguidos (clic central en suelo, repetir). Debe colocarse y seguir en mano hasta agotar stock. |
| [ ] | **Sin errores en consola** | Juega 2–3 minutos (colocar, rotar, guardar, cargar, clic central, DEBUG). Revisa que no aparezcan errores rojos en consola. |

---

Cuando todo esté marcado, la sesión queda **fetén** ✅.  
Si algo falla, anótalo aquí o en **5_PROJECT_STATE.md** / **7_COSAS_POR_HACER.md** para no perderlo.
