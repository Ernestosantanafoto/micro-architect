# Notas de desarrollo

## Flujo al cerrar sesión

**Cuando el usuario diga "hasta mañana" (o similar para cerrar):**
1. Hacer **commit** de los cambios pendientes (si los hay).
2. Hacer **push** a `origin` (si hay commits por subir).

Así el trabajo queda guardado y sincronizado antes de seguir al día siguiente.

## Documentación de reglas

- **Reglas universales** (colores, unidades, "todos los…", botón INFRAESTRUCTURA, dim): [0_REGLAS_UNIVERSALES.md](0_REGLAS_UNIVERSALES.md).
- **Puntos no tocar** (save/load, UIs edificios, menú INFRAESTRUCTURA): mismo documento; no refactorizar salvo petición explícita.

*(Regla commit/push guardada 2025-01-31; reglas universales añadidas 2025-01-31.)*
