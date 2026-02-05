# Flujo para resolver issues (GitHub)

Cuando me pidas que siga este flujo, haré lo siguiente:

1. **Listar issues abiertos**  
   Ejecuta `gh issue list` y muéstrame los issues abiertos.  
   Luego pregúntame **cuál quiero resolver**.

2. **Al elegir uno:**
   - Lee el issue completo con `gh issue view #N`
   - Analiza el código existente del proyecto
   - Explícame tu **plan** e **implementa**
   - Pídeme que **pruebe los cambios** y espera mi **feedback**

3. **Si apruebo:**
   - Haz **commit** con este formato exacto:
     ```
     git commit -m "Fixes #N: [título breve]

     - [cambio 1]
     - [cambio 2]
     - [cambio N]"
     ```
   - Haz **push** para cerrar el issue automáticamente
   - **Añade el issue al CHANGELOG** en la sección "Issues resueltos (GitHub)" con **fecha y hora** de cierre (ej. `Cerrado: YYYY-MM-DD HH:MM`), enlace al issue, título y resumen de cambios
   - Vuelve al paso 1 para el siguiente issue

4. **Si no apruebo:**  
   Ajusta según mi feedback y vuelve al paso 4 (pedir que pruebe).

---

*Documento de referencia: leer cuando el usuario pida "haz lo de issues" o similar.*
