# ADRs — Cronos

Registro de decisiones arquitectónicas del kit mismo, no de los proyectos que construye (para eso, ver la skill `technical-governance`). Mismo formato: Contexto / Decisión / Alternativas consideradas / Consecuencias.

| ADR | Título | Estado |
|---|---|---|
| [001](ADR-001-cronos-agente-primario.md) | Cronos como agente primario, no como plantilla de Titán | aceptada (retroactiva, v1.0.0) |
| [002](ADR-002-descubrimiento-modelos.md) | Descubrimiento de modelos en vez de catálogo fijo | aceptada (retroactiva, v1.4.0; criterio adaptado a "por fase" en v3.0.0; mecanismo de descubrimiento ramificado por plataforma en v4.0.0, ver 011) |
| [003](ADR-003-reglas-oro-defensa-profundidad.md) | Reglas de oro duplicadas como defensa en profundidad | aceptada (retroactiva, v1.3.0); mecanismo de `fragments/` superado en v3.0.0; principio reaplicado a `AGENTS.md`/`~/.cronos/` en v4.0.0 (ver 011) |
| [004](ADR-004-opencode-plataforma-referencia.md) | OpenCode como plataforma de referencia | aceptada (retroactiva, v1.0.0); única plataforma entre v3.0.0 y v4.0.0; sigue siendo la plataforma de referencia (la única con verificación empírica) aunque deja de ser la única soportada en v4.0.0, ver 011 |
| [005](ADR-005-nucleo-adaptadores-plataforma.md) | Núcleo agnóstico + adaptadores por plataforma | **superada** por 007 (v3.0.0); patrón retomado con diseño distinto en v4.0.0 (ver 011) |
| [006](ADR-006-paso-deteccion-plataforma.md) | "Paso 0.5 — Detecta la plataforma" en MASTER_PROMPT.md | **superada** por 007 (v3.0.0); reintroducida, fusionada con la detección de situación, en v4.0.0 (ver 011) |
| [007](ADR-007-consolidacion-agente-unico.md) | Consolidación a un único agente (Cronos) y eliminación de adapters multiplataforma | aceptada (v3.0.0); punto 1 (agente único) sigue vigente sin cambios; punto 3 (exclusividad de OpenCode) **reabierto parcialmente** por 011 (v4.0.0) |
| [008](ADR-008-omega-capacidades-sin-multiagente.md) | Cronos Omega — capacidades nuevas como skills/fases del agente único, sin reabrir el diseño multiagente | aceptada (v3.1.0) |
| [009](ADR-009-v4-enterprise-sin-reabrir-diseno.md) | "Los Titanes Enterprise V4.0" — 3 mejoras reales incorporadas, resto descartado sin reabrir ADR-007/ADR-008 | aceptada (v3.2.0) |
| [010](ADR-010-qa-browser-intelligence-sin-multiagente.md) | "Autonomous QA & Browser Intelligence" — skill `browser-qa-e2e` incorporada real, self-healing reducido, Knowledge System descartado, framing multiagente de la Fase 6 descartado sin reabrir ADR-007/ADR-008/ADR-009 | aceptada (v3.3.0) |
| [011](ADR-011-multiplataforma-opencode-codex-vscode.md) | Núcleo agnóstico + adaptadores para OpenCode, Codex CLI y VS Code — reabre parcialmente ADR-007 (solo exclusividad de plataforma, no agente único), a pedido directo del operador con necesidad real evidenciada (a diferencia de los pedidos externos especulativos que 008/009/010 descartaron) | aceptada (v4.0.0) |
| [012](ADR-012-deteccion-proactiva-promocion-skills.md) | Detección de gaps proactiva + promoción de skills — extiende `capability-gap-analysis` (nacida en 008 como versión acotada de "Skill Forge") en dos ejes elegidos por el operador, sin debilitar el checkpoint de confirmación que R-016 ya exige | aceptada (v4.1.0) |
| [013](ADR-013-subagentes-temporales-controlados.md) | Subagentes temporales acotados como herramienta de ejecución, sin restaurar los Titanes permanentes ni transferir autoridad de Cronos | aceptada (v4.2.0) |

**Regla de ahora en más:** toda entrada de `CHANGELOG.md` que represente una decisión costosa de revertir (mismo checklist que `technical-governance` ya usa para juzgar esto en los proyectos) genera un ADR nuevo, referenciado desde el changelog en vez de solo narrado en prosa. Un ADR superado no se borra — se marca como tal y se referencia desde el que lo reemplaza, para no perder el registro de por qué se tomó la decisión original.
