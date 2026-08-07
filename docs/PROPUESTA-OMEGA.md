# PROPUESTA — Cronos Omega (evolución de v3.0.0)

Documento de diseño para gate de aprobación (checkpoint tipo A3, `GOBERNANZA.md`: Arquitecto técnico). No modifica el kit todavía — es el `STACK.md`/`tasks.md` de este meta-proyecto. Una vez aprobado, se implementan los cambios archivo por archivo y se entrega el kit actualizado.

## 0. Nota sobre el nombre de versión

El Master Task pide "V5 Ultimate". El kit real está en `3.0.0`, consolidado ayer. Lo que se propone abajo es aditivo y no rompe nada existente — por `CHANGELOG.md` y semver, eso es un bump **menor** (`3.1.0`), no un salto a "5". Saltar el número sin que exista v4 detrás es puro marketing interno y contradice la Regla de oro 9 de `AGENCY.md` ("la agencia se versiona"). Recomendación: `3.1.0` ahora; reservar "Omega" como nombre de fase/hito si quieren un nombre evocador, no como número de versión.

## 1. Diagnóstico actual (resumen — detalle ya entregado en Fase 1)

Cronos v3.0.0: agente único, `mode: primary`, 10 fases heredadas de los Titanes + ciclo de autocrítica (seguridad, QA) + gobernanza por sombreros (`GOBERNANZA.md`) + 14 skills + registro de riesgos activo (`RIESGOS.md`) + historial de decisiones con alternativas descartadas (`adr/`). Sistema maduro, consciente de sus propios trade-offs (R-015 documentado, no ignorado).

## 2. Debilidades

| # | Debilidad | Evidencia |
|---|---|---|
| D1 | Sin mecanismo de benchmark/investigación externa antes de diseñar UI | `frontend-craft` cubre criterio propio + `ui-ux-pro-max`, pero no exige mirar referencias reales antes de proponer diseño |
| D2 | Sin memoria evolutiva entre proyectos | Nada en `AGENCY.md` persiste lecciones de un proyecto al siguiente; cada proyecto es una hoja aislada (`BRIEF.md`/`STACK.md`/`tasks.md` locales) |
| D3 | Adición de skills es manual, no sistemática | Las 14 skills se agregaron por decisión de versión, no por un flujo repetible de "detecté un gap → propongo skill → apruebas" |
| D4 | Sin seguimiento de costo (IA/APIs/hosting) por proyecto | No aparece en `AGENCY.md`, `STACK.example.md` ni `RIESGOS.md` |
| D5 | "CTO Challenge Mode" existe pero no es un paso obligatorio explícito | Las alternativas descartadas viven en `adr/`, pero solo cuando alguien decide escribir un ADR — no hay gate que fuerce cuestionar antes de aprobar |

## 3. Capacidades faltantes (gap real vs. Master Task)

- Competitor/Design benchmark formal antes de frontend.
- Reporte de Product/Business Intelligence estructurado (hoy `BRIEF.md` es más liviano).
- Capability Gap Report + Skill Forge como flujo repetible.
- Base de conocimiento persistente entre proyectos (Knowledge/Learning Engine).
- Cost Intelligence.

## 4. Capacidades redundantes en el Master Task (no reconstruir)

| Pedido del Master Task | Ya existe como | Acción |
|---|---|---|
| Titan Council (convocar Atlas, Hefesto, Prometeo...) | `GOBERNANZA.md` — gobernanza por sombreros, roles no personas/agentes | Extender el patrón existente, no crear uno nuevo |
| CTO Challenge Mode / Architecture Challenge Report | `adr/` — sección "Alternativas consideradas" en cada ADR | Formalizar como paso obligatorio, no reemplazar |
| Feature Prioritization Engine (MVP/V1/V2/V3) | Skills `product-strategy` + `mvp-roadmap-planning` | Ampliar criterio, no crear skill nueva |
| Visionary Mode (roadmap al cerrar proyecto) | `ROADMAP.md` a nivel del kit | Replicar el patrón a nivel de cada proyecto, no inventar formato nuevo |
| Repository Intelligence | Modo Auditoría + `AUDITORIA.example.md` | Extender la plantilla existente |

## 5. Nueva arquitectura — resumen de ADR-008 (borrador)

Un único agente, sin cambios en `mode: primary`. Las capas "Intelligence" del Master Task se incorporan como **checklists dentro de fases existentes** o **skills nuevas que Cronos aplica él mismo**, nunca como `agent.<nombre>` adicional en `opencode.json`. El "Titan Council" no convoca personajes — es una sección obligatoria nueva en cada ADR de impacto real ("Opiniones por sombrero": Producto, Arquitectura, Seguridad, QA — Cronos redacta las cuatro perspectivas en el mismo turno, el operador aprueba con el sombrero que corresponda según la RACI de `GOBERNANZA.md`).

Mapeo completo:

| Capa del Master Task | Dónde vive en Cronos Omega |
|---|---|
| Product/Business Intelligence | Sección nueva en `BRIEF.md` (plantilla ampliada): problema, usuario, valor, impacto, métrica de éxito, modelo de negocio si aplica |
| Competitor/Design Intelligence, UI Benchmark, Design DNA | Skill nueva `design-benchmark` (recolecta referencias antes de `frontend-craft`) |
| Feature Prioritization | Ampliación de `product-strategy` (clasificación MVP/V1/V2/V3 explícita) |
| CTO Challenge Mode | Paso obligatorio nuevo en checkpoint A3 de `MASTER_PROMPT.md`: todo ADR debe tener ≥2 alternativas descartadas antes de aprobarse (ya ocurre en la práctica en ADR-001 a 007; se formaliza como regla) |
| Repository/Technical Debt/Cost Intelligence | Ampliación de `AUDITORIA.example.md` (sección de deuda técnica y costo) |
| Titan Council | Sección "Opiniones por sombrero" en plantilla de ADR |
| Evolution Intelligence / Skill Forge / MCP Discovery | Skill nueva `capability-gap-analysis`, corre al cerrar cada proyecto Nivel 2/3 |
| Knowledge Intelligence | Archivo nuevo global `LECCIONES.md` (persiste entre proyectos, se actualiza al cerrar cada uno) |
| Visual QA | Checklist ampliado dentro de la fase QA del `self-critique-loop` |
| Visionary Mode | Sección "Roadmap del proyecto" obligatoria al cerrar `tasks.md` en Nivel 2/3 |

## 6. Nuevas Skills propuestas

| Skill | Reemplaza/extiende | Se activa |
|---|---|---|
| `design-benchmark` | Nada — hueco real (D1) | Antes de `frontend-craft`, cualquier nivel con frontend |
| `capability-gap-analysis` | Nada — hueco real (D3) | Al cerrar proyecto Nivel 2/3 |
| `cost-intelligence` | Nada — hueco real (D4) | Nivel 2/3, o cuando se integra un servicio de pago |

Total: 14 → 17 skills. (Se evaluó fusionar en vez de sumar — ver punto pendiente de `ROADMAP.md` de revisar si 14 es el número correcto; con esta propuesta la respuesta es "17, con criterio de cuándo se activa cada una", no expansión sin control.)

## 7. Nuevas SuperPowers

Ninguna. Regla del propio Master Task ("Comprar > Integrar > Construir") aplicada primero a la propuesta: Superpowers (Jesse Vincent) ya cubre TDD, worktrees, code review. No hay gap que justifique un componente nuevo de este tipo.

## 8. Nuevos flujos (cambios a `MASTER_PROMPT.md`)

- Flujo A (proyecto nuevo): entre `BRIEF.md` y `STACK.md`, insertar paso opcional (Nivel 2/3) "Benchmark de diseño" si el proyecto tiene frontend visible al usuario final.
- Ambos flujos: al cerrar el proyecto (última tarea en `tasks.md` → `desplegada`), correr `capability-gap-analysis` y actualizar `LECCIONES.md`.
- Checkpoint A3 (ADR): exigir sección "Opiniones por sombrero" antes de que el operador apruebe.

## 9. Cambios archivo por archivo (a implementar tras este gate)

- `SKILLS.md`: +3 filas (tabla de skills base/avanzadas según corresponda).
- `skills-custom/design-benchmark/`, `skills-custom/capability-gap-analysis/`, `skills-custom/cost-intelligence/`: carpetas + `SKILL.md` nuevos.
- `MASTER_PROMPT.md`: pasos nuevos en Flujo A, Flujo B y Paso 7.
- `AGENCY.md`: fila nueva en tabla de componentes globales (`LECCIONES.md`); nota en tabla de fases (Product Intelligence dentro de "Producto y alcance").
- `AUDITORIA.example.md`: sección de deuda técnica/costo ampliada.
- `adr/ADR-008-...md`: nuevo, documenta esta decisión completa.
- `RIESGOS.md`: +2 entradas (ver punto 13).
- `ROADMAP.md`: mover ítems de este documento a la columna correspondiente; cerrar el ítem "revisar si 14 skills es el número correcto".
- `VERSION`: `3.0.0` → `3.1.0`.
- `CHANGELOG.md`: entrada nueva.

## 10. Plan de migración

No rompe proyectos ya creados con v3.0.0: `scripts/actualizar-proyecto.sh` ya trae mejoras del core sin tocar lo específico del proyecto (Principio 9, `AGENCY.md`). `LECCIONES.md` arranca vacío — no requiere backfill. Ningún cambio toca `opencode.template.json` (sigue siendo un único `agent.cronos`), así que no hay migración de configuración.

## 11. Roadmap (actualización propuesta a `ROADMAP.md`)

- v3.1.0 (este documento, tras aprobación): las 3 skills nuevas, `LECCIONES.md`, ADR-008.
- v3.2.0: primer proyecto Nivel 2/3 real usando `design-benchmark` y `capability-gap-analysis` — validar antes de dar por buena la propuesta con datos reales (mismo criterio que ya aplica el kit a todo lo nuevo).
- Pendientes de v3.0.0 (R-002, primera convocatoria del Consejo) siguen con prioridad #1 — Omega no los reemplaza.

## 12. Capability Gap Report (de esta misma sesión, formato para reutilizar)

- ¿Qué faltó?: benchmark de diseño, memoria entre proyectos, seguimiento de costo.
- ¿Qué repetí?: nada — primera vez que se ejecuta este análisis sobre el kit mismo.
- ¿Qué automatizaría?: el propio `capability-gap-analysis` que se propone.
- ¿Qué Skill faltó?: las 3 del punto 6.
- ¿Qué MCP/herramienta faltó?: ninguna evaluada como necesaria — ver punto 7.

## 13. Riesgos nuevos (entradas propuestas para `RIESGOS.md`)

- **R-016 — Skill Forge sin curaduría puede inflar el catálogo.** Mitigación: `capability-gap-analysis` propone, nunca instala solo; siempre pasa por el checkpoint del operador (mismo patrón que ya usa el kit).
- **R-017 — `LECCIONES.md` como archivo único puede crecer sin límite.** Mitigación: revisar tamaño en cada convocatoria del Consejo Estratégico; podar o particionar por año si hace falta.

## 14. Beneficios

Cierra los 3 gaps reales encontrados (D1, D3, D4) sin reabrir la discusión multiagente, sin agregar superficie de mantenimiento comparable a los 10 Titanes/adapters que ya se eliminaron deliberadamente, y reutilizando patrones que el kit ya probó (gobernanza por sombreros, ADRs con alternativas, skills con criterio de activación).

## 15. Recomendaciones finales

Aprobar como v3.1.0, no v5. Implementar en este orden: ADR-008 → skills nuevas → `MASTER_PROMPT.md` → resto de archivos → `CHANGELOG.md`/`VERSION`. Siguiente gate: confirmar este documento completo (o pedir cambios) antes de que genere los archivos reales y te entregue el zip actualizado.
