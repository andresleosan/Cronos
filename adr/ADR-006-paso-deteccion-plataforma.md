# ADR-006: "Paso 0.5 — Detecta la plataforma" en MASTER_PROMPT.md

**Estado:** superada por `ADR-007-consolidacion-agente-unico.md` (v3.0.0) — se conserva como registro histórico, no como decisión vigente.
**Fecha:** 2026-07-12 (aceptada en v2.0.0; superada 2026-07-14)

## Contexto
Con el patrón de ADR-005 (núcleo + adaptadores), Cronos necesita saber, antes de ejecutar cualquier paso mecánico (detectar stack, descubrir modelos), qué runtime lo está ejecutando — sin que eso cambie la lógica de decisión en sí (Flujo A/B, niveles, checkpoints), que es agnóstica.

## Decisión
Agregar un paso nuevo, antes del Paso 0 actual de `MASTER_PROMPT.md`: Cronos identifica (o el humano confirma) qué runtime está corriendo, y a partir de ahí usa el adaptador correspondiente (`adapters/<plataforma>/`) para los pasos mecánicos concretos.

## Alternativas consideradas
- **Detectar la plataforma implícitamente en cada paso que la necesite** (A2, A4), en vez de un paso explícito al inicio. Descartado: dispersaría la lógica de detección en varios lugares del flujo en vez de resolverla una sola vez, con más superficie para que un paso se actualice a una plataforma nueva y otro se olvide (el mismo tipo de deriva que ADR-003 ya corrigió para las reglas de oro).

## Consecuencias
- Un solo lugar nuevo que tocar cuando se agregue un adaptador de plataforma, no varios.
- Mientras solo existiera el adaptador de OpenCode verificado, este paso era casi transparente — detectaba OpenCode y todo funcionaba exactamente igual que en v1.x. Su valor iba a aparecer cuando el segundo adaptador estuviera verificado — cosa que nunca ocurrió.

**Nota de superación (v3.0.0):** con `ADR-007`, `adapters/` se elimina y OpenCode vuelve a ser la única plataforma soportada — el "Paso 0.5" deja de tener sentido porque ya no hay nada que detectar: `MASTER_PROMPT.md` v3.0.0 no lo incluye.
