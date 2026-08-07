# ADR-005: Núcleo agnóstico + adaptadores por plataforma

**Estado:** superada por `ADR-007-consolidacion-agente-unico.md` (v3.0.0) — se conserva como registro histórico, no como decisión vigente.
**Fecha:** 2026-07-12 (aceptada en v2.0.0; superada 2026-07-14)

## Contexto
ADR-004 generó lock-in total de orquestación a OpenCode. El pedido explícito de soportar OpenCode, Roo Code, Claude Code y Codex CLI (ver `PROPUESTA-AGENCIA-TITANES-v2.0.md`, sección 7) no se resuelve escribiendo el kit 4 veces — eso multiplicaría por 4 el costo de mantenimiento y el riesgo de deriva ya identificado en ADR-003.

Verificación empírica de esta ronda (julio 2026): **Roo Code cerró el 15 de mayo de 2026** — uno de los cuatro nombres pedidos ya no existe como tal, lo cual confirma que una lista fija de plataformas caduca igual que caducaba el catálogo fijo de modelos que ADR-002 ya reemplazó.

## Decisión
Separar el **núcleo** (`AGENCY.md`, `MASTER_PROMPT.md`, `titanes/*.template.md`, `skills-custom/*`, el criterio de `MODELOS.md` — todo lo que describe qué debe creer y hacer un Titán, agnóstico de runtime) de **adaptadores** por plataforma (`adapters/<plataforma>/`, que traducen las mismas reglas a la mecánica concreta de cada runtime: `permission.bash` en OpenCode, hooks `PreToolUse` en Claude Code, `sandbox_mode`/`approval_policy` en Codex CLI).

Es el mismo patrón que ADR-002 ya aplicó a modelos (proceso de descubrimiento y criterio, no lista fija), generalizado un nivel más arriba, a plataformas.

## Alternativas consideradas
- **Reescribir el kit completo por plataforma.** Descartado por el costo de mantenimiento (4x) y el riesgo de deriva (4 copias divergiendo con el tiempo, el mismo problema que ADR-003 ya resolvió para las 10 plantillas de Titanes, pero multiplicado).
- **Elegir una sola plataforma y no soportar las demás.** Descartado — es exactamente la situación de ADR-004 que esta decisión busca corregir, y el pedido explícito de la propuesta v2.0 es no depender de una sola.
- **Comprometerse a los 4 nombres pedidos tal cual.** Descartado en el momento de verificar: uno de los cuatro (Roo Code) ya no existe. Comprometerse a nombres fijos repetiría el mismo error que ADR-002 corrigió para modelos.

## Consecuencias
- El núcleo no cambia entre runtimes — reduce el costo de mantenimiento a 1x núcleo + N adaptadores livianos, en vez de N copias completas.
- Cada adaptador necesita verificación empírica propia, independiente de las demás — mismo estándar de rigor que el resto del kit ya exige (ver `RIESGOS.md` R-008).
- La meta declarada en `PROPUESTA-AGENCIA-TITANES-v2.0.md` era "2-3 plataformas verificadas", no "4 de nombre" — se priorizó rigor sobre cobertura nominal.
- Introdujo un `Paso 0.5 — Detecta la plataforma` en `MASTER_PROMPT.md`, ver ADR-006.

**Nota de superación (v3.0.0):** en la práctica, en los meses siguientes a v2.0.0 solo se mantuvo un adaptador verificado (OpenCode); el segundo (Claude Code) nunca pasó de borrador sin confirmar. El pedido explícito de simplificar la agencia a un único agente hace que sostener la capa de adaptadores para plataformas no usadas sea puro costo de mantenimiento sin beneficio real. `ADR-007` revierte esta decisión: se elimina `adapters/` por completo y OpenCode vuelve a ser la única plataforma soportada, igual que en ADR-004 original.
