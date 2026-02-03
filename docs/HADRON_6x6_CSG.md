# Hadron Factory 6×6 con agujero (CSG)

## Cómo está hecho

La forma se hace con **CSG (Constructive Solid Geometry)** en Godot:

1. **Primera forma (padre):** un **CSGBox3D** que es la “masa” del edificio (6×6, o la altura que quieras).
2. **Segunda forma (hijo):** otro **CSGBox3D** con **Operation = Subtraction** (valor 2). Ese hijo se “resta” del padre y deja un hueco con su forma.

En la escena `hadron_factory.tscn`:

- **CSGBox3D** (raíz visual): `size = (6, 1, 6)` → anillo 6×6.
- **CSGBox3D** (hijo): `operation = 2` (Subtraction), `size = (2, 1.2, 2)` (o el tamaño del agujero que quieras), `position = (0, 0, 0)` → agujero en el centro.

El **CollisionShape3D** sigue siendo una caja 6×6 (o un shape que tú pongas) para que la física ocupe todo el 6×6.

## Cómo modificarlo tú en el editor

1. Abre **`scenes/buildings/hadron_factory.tscn`**.
2. Selecciona el nodo **CSGBox3D** raíz (el que tiene size 6,1,6):
   - **Size:** cambia `x` y `z` para el tamaño exterior (ej. 6×6); `y` es la altura.
   - **Material:** mismo material que antes o uno nuevo.
3. Selecciona el **hijo** (el segundo CSGBox3D, el que hace el agujero):
   - **Operation:** debe ser **Subtraction** (2).
   - **Size:** ancho/profundo del agujero (ej. 2,1.2,2). Si `y` es mayor que el padre, el agujero atraviesa.
   - **Position:** (0, 0, 0) = agujero centrado. Mueve para descentrar el hueco si quieres.

Guarda la escena (Ctrl+S). El script ya está preparado para footprint 6×6.

## Nota

Si en el juego el edificio se coloca por celdas de 1×1, un 6×6 ocupa 36 celdas. El `get_footprint_offsets()` en `hadron_factory.gd` devuelve esas 36 posiciones relativas para que GridManager/placement lo traten como 6×6.
