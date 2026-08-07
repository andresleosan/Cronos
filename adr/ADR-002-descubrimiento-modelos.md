# ADR-002: Descubrimiento de modelos en vez de catálogo fijo

**Estado:** aceptada (retroactiva — decisión ya tomada en v1.4.0, formalizada como ADR en v2.0.0)
**Fecha original:** v1.4.0

## Contexto
Las versiones anteriores de `MODELOS.md` mantenían una lista de modelos disponibles por proveedor. Esa lista caduca cada vez que un proveedor lanza o retira un modelo — y ya había caducado más de una vez.

## Decisión
`MODELOS.md` v1.4.0 en adelante no lista modelos por nombre: describe un **proceso de descubrimiento** (`opencode models`, `opencode auth list`) y un **criterio de asignación** por rol (qué tan crítico es el veto del Titán, cuánto contexto necesita, si conviene gratuito o pago), verificado contra una máquina real con un solo proveedor conectado.

## Alternativas consideradas
- **Mantener el catálogo fijo, actualizado a mano cada mes.** Se descartó: exige disciplina de mantenimiento recurrente que nadie garantiza, y el costo de que quede desactualizado (asignar un modelo retirado) es alto.
- **Automatizar la actualización del catálogo con un scraper.** Se descartó por complejidad desproporcionada para el problema — un scraper es, en sí mismo, otra dependencia a mantener.

## Consecuencias
- `MODELOS.md` no necesita mantenimiento cuando el mercado de modelos cambia — solo cuando el *criterio* de asignación deja de tener sentido, algo mucho menos frecuente.
- Es, de las piezas del kit, la que menos cambios necesitó en cada auditoría (pilar Independencia tecnológica, sub-nivel modelo: 9/10 en la auditoría v1.5.0).
- Sentó el precedente que la propuesta v2.0 generalizó un nivel más arriba (proceso de descubrimiento, no lista fija, aplicado a plataformas de orquestación — ver ADR-004 y la nota de continuidad de ADR-007).

**Nota de continuidad (v3.0.0):** con la consolidación a un único agente (ADR-007), el criterio de asignación de este ADR pasa de "por Titán" a "por fase del trabajo" — el proceso de descubrimiento (Paso 1 de `MODELOS.md`) no cambia, pero ya no hay 10 entradas `agent.<titán>.model` en paralelo, sino un único `agent.cronos.model` que se recomienda cambiar en cada transición de fase.
