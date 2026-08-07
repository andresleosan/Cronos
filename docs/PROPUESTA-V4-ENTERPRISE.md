# PROPUESTA — Evaluación del pedido "Los Titanes Enterprise V4.0"

Documento de diseño para gate de aprobación (checkpoint tipo A3, `GOBERNANZA.md`: Arquitecto técnico). No modifica el kit todavía — es el `STACK.md`/`tasks.md` de este meta-proyecto. Una vez aprobado, se implementan los cambios archivo por archivo.

## 0. Nota sobre el nombre de versión

El Master Task pide "Enterprise V4.0". El kit real está en `3.1.0`, cerrado el mismo día que llegó este pedido (ver `ADR-008`). Como se ve en el punto 4, casi todo lo pedido ya existe con otro nombre o se descarta por contradecir decisiones ya tomadas — lo que queda como señal real (punto 3) es aditivo y no rompe nada. Por `CHANGELOG.md` y semver, eso es un bump **menor** (`3.2.0`), no un salto a `4.0`. Misma conclusión que ya se escribió para "Omega V5" un día antes: saltar el número sin arquitectura nueva detrás es marketing interno, no versión real.

## 1. Diagnóstico actual (resumen)

Cronos v3.1.0: agente único, `mode: primary`, 17 skills, gobernanza por sombreros con RACI (`GOBERNANZA.md`), registro de riesgos con 17 entradas (`RIESGOS.md`, 8 cerradas, 9 abiertas/aceptadas), 8 ADRs con alternativas descartadas por escrito, `LECCIONES.md` como memoria evolutiva (agregado ayer, vacío todavía). El mismo pedido — multiagente, consejo simulado, adaptadores multiplataforma — ya llegó una vez con otro nombre ("Cronos Omega V5 Ultimate") y ya fue evaluado en `ADR-008`, un día antes de este documento.

## 2. Debilidades reales encontradas

| # | Debilidad | Evidencia |
|---|---|---|
| D1 | `LECCIONES.md` no distingue tipo de entrada más allá de un campo `Categoría` genérico (skill faltante / MCP faltante / arquitectura / seguridad / costo / otra) | `LECCIONES.example.md` — no separa "algo que funcionó y conviene repetir" (patrón) de "algo que falló" (incidente) |
| D2 | R-017 (`LECCIONES.md` sin límite de tamaño) está "aceptado", no mitigado — la única acción definida es "revisar en cada convocatoria del Consejo", sin regla concreta de cuándo podar | `RIESGOS.md`, entrada R-017 |
| D3 | No hay ninguna métrica cuantitativa que dispare una convocatoria del Consejo — los 3 disparadores de `GOBERNANZA.md` son todos cualitativos (antes de Nivel 3, bump de versión, riesgo escala a crítico) | `GOBERNANZA.md`, sección "Cuándo se convoca el Consejo" |

No se encontraron más debilidades reales. El resto del pedido (ver punto 4) ya está cubierto o no aplica a la escala actual del kit.

## 3. Capacidades faltantes (gap real vs. Master Task V4.0)

- Taxonomía explícita dentro de `LECCIONES.md` (patrón / antipatrón / incidente / playbook), sin crear archivos nuevos.
- Regla concreta de poda/partición para cerrar R-017.
- 2-3 métricas mínimas y ya calculables (riesgos abiertos vs. cerrados, tamaño de `LECCIONES.md`, antigüedad de la última revisión de cada riesgo) como disparador adicional de convocatoria del Consejo.

Nada de esto requiere un documento nuevo, un consejo nuevo, ni un cambio de versión mayor.

## 4. Capacidades redundantes o contradictorias en el Master Task V4.0 (no reconstruir)

| Fase del Master Task | Ya existe como / por qué se descarta | Acción |
|---|---|---|
| Fase 1 — Auditoría arquitectónica completa | Modo Auditoría de Cronos + este mismo documento | Ninguna, ya se hace |
| Fase 2 — Detectar problemas estructurales (SPOF, escalabilidad, coordinación, deriva, vendor lock-in) | `RIESGOS.md` ya usa esa taxonomía exacta como categorías del schema | Ninguna, coincide casi literal |
| Fase 3 — Titan Core (Núcleo / Capacidades / Ejecución) | Contradice `ADR-007` — reintroduce la fragmentación en piezas separadas que la consolidación a agente único eliminó deliberadamente | Descartar |
| Fase 4 — Strategic Council (6 consejos con misión/KPIs propios) | Es el "Titan Council" del pedido anterior con nombre nuevo — ya rechazado en `ADR-008` por ser teatro (párrafos con encabezado de rol no es una segunda mirada real). `GOBERNANZA.md` (sombreros) + RACI ya cubre la intención real | Descartar el mecanismo de 6 consejos |
| Fase 5 — `MODEL_REGISTRY.md` (catálogo fijo por modelo) | `MODELOS.md` descarta explícitamente un catálogo fijo porque los proveedores y modelos gratuitos cambian todo el tiempo — es su primera línea | Descartar, contradice el diseño explícito de `MODELOS.md` |
| Fase 6 — `SKILL_REGISTRY.md` con ciclo de vida de 6 estados | `SKILLS.md` (17 skills con criterio de activación) + `capability-gap-analysis` ya cubren "propuesta → confirmación del operador" (ver R-016) | Descartar el ciclo formal de 6 estados — desproporcionado para 17 skills de un solo mantenedor |
| Fase 7 — Knowledge System (Lessons/Patterns/AntiPatterns/Decisions/Incidents/Playbooks) | `LECCIONES.md` cubre parte de esto en un solo archivo | **Señal real parcial** — ver punto 3, se amplía taxonomía sin crear 6 archivos nuevos |
| Fase 8 — Knowledge Graph (ADR → Riesgo → Skill → Proyecto → Roadmap → Cambio) | `ADR-008` ya evaluó una versión de esto y prefirió referencias cruzadas livianas (`Dueño`, referencias entre ADRs, `tasks.md`+`CHANGELOG.md`+`RIESGOS.md`) — "se reconsidera si el equipo crece" | Descartar, sin equipo que haya crecido desde ayer |
| Fase 9 — PMO Empresarial (Portfolio/Program/Project/Capacity Management) | `GOBERNANZA.md` descarta explícitamente reuniones periódicas formales "mientras el equipo siga siendo pequeño"; `product-strategy`/`mvp-roadmap-planning` ya cubren priorización por proyecto | Descartar, la escala (portfolio multi-proyecto con contención de recursos entre equipos) no aplica a un operador |
| Fase 10 — KPIs obligatorios (10 categorías) | No existe como framework, pero la mayoría serían métricas sin nadie más que las revise | **Señal real mínima** — ver punto 3, 2-3 métricas como disparador, no un documento `KPIs.md` nuevo |
| Fase 11 — Multiplataforma (Driver/Adapter/Execution/Governance/Knowledge layers para OpenCode, Claude Code, Codex CLI, Roo Code, Cursor) | Contradice `ADR-007` (decisión deliberada de uso exclusivo de OpenCode) y R-008 (cerrado, reclasificado de riesgo a decisión de alcance). Roo Code además cerró en mayo de 2026 — R-009 ya deja esto como antecedente de por qué comprometerse a nombres de plataforma específicos es frágil | Descartar sin una decisión deliberada nueva que reabra `ADR-007` explícitamente |
| Fase 12 — Roadmap V4 por etapas (V4.0 → V4.4) | `ROADMAP.md` ya tiene horizontes corto/mediano/largo plazo, con casi todos los ítems reales ya listados bajo "largo plazo (v4.0+)" | Ninguna, ya existe — el pedido solo re-etiqueta con nombres más grandes |

## 5. Nueva arquitectura — resumen de ADR-009 (borrador)

Ningún cambio a `opencode.template.json`, a la clasificación de proyectos por nivel, ni a `MODELOS.md`/`SKILLS.md`. Los tres puntos del gap real (D1-D3) se incorporan como ediciones a archivos que ya existen:

| Pedido del Master Task | Dónde vive en la versión reducida |
|---|---|
| Knowledge System con taxonomía | Campo `Categoría` de `LECCIONES.example.md` ampliado con 4 valores nuevos (patrón / antipatrón / incidente / playbook), sumados a los que ya había |
| KPIs | Sección nueva y corta en `GOBERNANZA.md`: 3 métricas + un 4º disparador de convocatoria del Consejo si alguna cruza un umbral |
| Gestión del conocimiento (poda) | Regla concreta agregada a `RIESGOS.md` R-017: pasa de "aceptado" a "mitigado" con criterio explícito de partición por año |

## 6. Nuevas Skills propuestas

Ninguna. No hay gap que justifique una skill nueva — los 3 puntos reales son ediciones a documentos de gobierno existentes, no comportamiento nuevo de Cronos en sesión.

## 7. Nuevos flujos

Ninguno. No se toca `MASTER_PROMPT.md`.

## 8. Cambios archivo por archivo (a implementar tras este gate)

- `LECCIONES.example.md`: ampliar taxonomía del campo `Categoría`.
- `RIESGOS.md`: R-017 pasa de "aceptado" a "mitigado", con regla de poda explícita.
- `GOBERNANZA.md`: agregar sección corta de métricas + 4º disparador de convocatoria.
- `adr/ADR-009-...md`: nuevo, documenta esta decisión completa (ya redactado, ver archivo adjunto).
- `ROADMAP.md`: mover el ítem "V4.0 Enterprise" a "resuelto", con referencia a `ADR-009`.
- `VERSION`: `3.1.0` → `3.2.0`, solo si se confirma esta propuesta.
- `CHANGELOG.md`: entrada nueva.

## 9. Plan de migración

No rompe proyectos ya creados. Ningún cambio toca `opencode.template.json` ni el flujo de `MASTER_PROMPT.md`, así que no hay migración de configuración ni de proyectos existentes.

## 10. Riesgos de la propuesta

Ninguno nuevo. Riesgo de *no* adoptarla: R-017 sigue sin regla de poda concreta y `LECCIONES.md` puede crecer sin criterio claro de qué podar primero — ya documentado, sin agravarse por esperar.

## 11. Quick wins

Los tres cambios del punto 8 son los quick wins reales de todo el pedido V4.0: bajo costo, cierran un riesgo abierto (R-017) y una debilidad real (D3), no requieren nuevo tooling ni documentos nuevos.

## 12. Sobre la meta de madurez 9.4+/10

El Master Task pide evolucionar de 8.4 a 9.4 sin agregar complejidad innecesaria — y en la misma frase pide 6 consejos, un PMO, dos registros nuevos y una capa multiplataforma. Esas dos cosas son incompatibles entre sí para un kit de un solo operador: la madurez que falta no viene de más estructura organizacional, viene de cerrar los riesgos que ya están escritos y abiertos (`RIESGOS.md`: R-002, R-007, R-012, R-013 siguen sin cerrar) y de la primera convocatoria real del Consejo con uso real de proyectos Nivel 2/3 — ambos ya están en `ROADMAP.md` desde antes de este pedido. Ninguno se resuelve escribiendo documentos de gobernanza nuevos.

## 13. Recomendación final

Aprobar como `3.2.0`, no `4.0`. Implementar los 3 cambios del punto 8, en ese orden, después de que confirmes `ADR-009`. Todo lo demás del Master Task (Fases 3, 4, 5, 6, 8, 9, 11) se descarta sin ambigüedad — no queda pendiente ni parcialmente adoptado.
