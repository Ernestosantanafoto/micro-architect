# Hadron Factory 12×12 con agujero (CSG)

## Cómo está hecho

La forma se hace con **CSG (Constructive Solid Geometry)** en Godot:

1. **Primera forma (padre):** un **CSGBox3D** que es la “masa” del edificio (12×12, o la altura que quieras).
2. **Segunda forma (hijo):** otro **CSGBox3D** con **Operation = Subtraction** (valor 2). Ese hijo se “resta” del padre y deja un hueco con su forma.

En la escena `hadron_factory.tscn`:

- Varios **CSGBox3D** con formas y huecos (subtraction) configurados en el editor; el tamaño exterior actual es **12×12**.
- **CollisionShape3D:** BoxShape3D `size = (12, 1, 12)` para que la física ocupe todo el 12×12.

## Cómo modificarlo tú en el editor

1. Abre **`scenes/buildings/hadron_factory.tscn`**.
2. Los nodos **CSGBox3D** (ShapeVisual, etc.): ajusta **Size** para el tamaño exterior y los huecos; **Operation = Subtraction (2)** en los hijos que forman el agujero.
3. **CollisionShape3D:** el shape debe coincidir con el tamaño en celdas (ej. 12×12 → `size = (12, 1, 12)`).
4. Si cambias el tamaño en celdas, actualiza **`get_footprint_offsets()`** en `hadron_factory.gd` para que devuelva el mismo rango (ej. 12×12 = de (-6,-6) a (5,5)).

## Nota

Un 12×12 ocupa 144 celdas. El `get_footprint_offsets()` en `hadron_factory.gd` devuelve esas posiciones relativas para que GridManager/placement lo traten como 12×12.
