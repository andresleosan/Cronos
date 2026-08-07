# ADR-004: OpenCode como plataforma de referencia

**Estado:** aceptada (retroactiva — decisión implícita desde v1.0.0, formalizada como ADR en v2.0.0)
**Fecha original:** v1.0.0

## Contexto
La agencia necesitaba un runtime concreto sobre el cual construir mecanismos reales (permisos, subagentes, comandos) en vez de quedarse en prosa abstracta. En junio de 2026, al arrancar el proyecto, OpenCode ofrecía el mecanismo de agentes/subagentes, permisos granulares (`permission.bash`) y descubrimiento de modelos multi-proveedor que el diseño de la agencia necesitaba.

## Decisión
Construir la mecánica completa de la agencia (permisos, roles, checkpoints técnicos) directamente sobre las primitivas de OpenCode, sin capa de abstracción intermedia.

## Alternativas consideradas
- **Diseñar una capa de abstracción desde el día uno**, agnóstica de plataforma. Se descartó por prematuro: sin un runtime real funcionando primero, la capa de abstracción se habría diseñado sobre supuestos, no sobre mecanismos verificados — el mismo error que, más tarde, la propuesta v2.0 evita al construir el patrón de adaptadores *después* de tener un runtime real y probado como referencia (ver ADR-005).

## Consecuencias
- Permitió construir rápido y verificar empíricamente cada mecanismo contra un runtime real — la razón de que `AGENCY.md`, `MODELOS.md` y `LOOPS.md` tengan el nivel de rigor que tienen hoy.
- Generó lock-in total de orquestación a OpenCode (Hallazgo del pilar Independencia tecnológica, `AUDITORIA-EMPRESARIAL-v1.5.0.md`): `permission`, `agent`/`mode`, la convención `commands/`, los hooks `session.idle` — todo específico de OpenCode.
- Motivó ADR-005 (núcleo + adaptadores multiplataforma, v2.0.0).

**Nota de continuidad (v3.0.0):** ADR-007 revierte ADR-005 y vuelve a esta decisión original — OpenCode deja de ser "la plataforma de referencia" entre varias posibles y pasa a ser, otra vez, la única soportada, ahora de forma explícita y deliberada en vez de por defecto histórico. Ver `ADR-007-consolidacion-agente-unico.md` para el razonamiento completo.
