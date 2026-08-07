# ADR-003: Reglas de oro duplicadas en cada plantilla, como defensa en profundidad

**Estado:** aceptada (retroactiva — decisión ya tomada en v1.3.0; mecanismo de mantenimiento actualizado en v2.0.0 y superado en v3.0.0, ver Consecuencias)
**Fecha original:** v1.3.0

## Contexto
No hay confirmación empírica de que `instructions` (la carga global de `AGENCY.md`/`MASTER_PROMPT.md`) llegue de forma fiable al contexto de un subagente invocado vía la herramienta `task`, ni cuando se invoca un Titán aislado sin pasar por Cronos (ver `RIESGOS.md` R-002, abierto desde v1.3.0).

## Decisión
Cada uno de los 10 `titanes/*.template.md` incluye su propio resumen de "Reglas de oro" embebido directamente en el archivo, en vez de depender solo de `instructions`. Es redundancia deliberada: si `instructions` no llega, el resumen embebido sigue funcionando porque es parte del propio prompt del agente.

## Alternativas consideradas
- **Confiar solo en `instructions`.** Se descartó por el mismo motivo que originó esta decisión: no hay confirmación de que llegue de forma fiable a un subagente.
- **Esperar a confirmar el hallazgo antes de agregar la redundancia.** Se descartó — el costo de agregar el resumen es bajo y el costo de esperar (mientras el hallazgo sigue sin confirmarse, como pasó durante 3 versiones) es alto.

## Consecuencias
- Mitiga el riesgo de forma inmediata, sin esperar la verificación empírica pendiente.
- Introduce un costo de mantenimiento real: el mismo bloque de texto mantenido a mano en 10 archivos, con riesgo de desalineación (ya ocurrió una vez con otro par de archivos, `AGENCY.md`/`MASTER_PROMPT.md`, corregido en v1.2.0).
- **Actualización en v2.0.0:** ese costo de mantenimiento se resuelve sin abandonar la redundancia — `fragments/reglas-oro.md` pasa a ser la fuente única, compuesta en cada plantilla por `scripts/generar-plantillas.py` y verificada por `scripts/verificar-kit.sh`. El resultado final (cada Titán con su resumen embebido) es idéntico; lo que cambia es que ya no se mantiene a mano.
- **Superada en v3.0.0:** con la consolidación a un único agente (ADR-007), el problema que originó este ADR — mantener el mismo bloque de texto sincronizado en 10 archivos distintos — desaparece de raíz: ya no hay 10 plantillas, solo `MASTER_PROMPT.md` y `AGENCY.md`. `fragments/` y `scripts/generar-plantillas.py` se eliminan del kit por no tener ya nada que componer. La pregunta de fondo (¿le llegan las reglas de oro a Cronos de forma confiable?) sigue abierta — ver `RIESGOS.md` R-002 — pero ya no depende de una redundancia entre archivos, sino de que `AGENCY.md`/`MASTER_PROMPT.md` lleguen al contexto de la única sesión que existe.
