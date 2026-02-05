Cuando te pida que leas este documento:

Ejecuta `gh issue list` y muéstrame los issues abiertos.
Luego pregúntame cuál quiero resolver.

Cuando elija uno:
1. Lee el issue completo con `gh issue view #N`
2. Analiza el código existente del proyecto
3. Explícame tu plan e implementa
4. Pídeme que pruebe los cambios y espera mi feedback
5. Si apruebo, haz commit con este formato exacto:

git commit -m "Fixes #N: [título breve]

- [cambio 1]
- [cambio 2]
- [cambio N]"

6. Modifica el ChangeLog añadiendo lo que has implementado, fecha y hora
7. Haz push para cerrar el issue automáticamente
8. Vuelve al paso 1 para el siguiente issue

Si no apruebo, ajusta y vuelve al paso 4.