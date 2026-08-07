# GOBERNANZA.md — Consejo Estratégico de Cronos

Componente global (resuelve el Hallazgo Crítico C3 de la auditoría empresarial que dio origen a v2.0.0: antes de esa versión, los checkpoints y toda resolución de desacuerdo dependían exclusiva y siempre de una sola persona, sin backup, sin quórum, sin SLA).

## El patrón: gobernanza por sombreros, no por personas

No es un comité de reuniones — sería teatro para un equipo chico y friccionaría más de lo que ayuda. Es un patrón de **roles de decisión** que funciona igual de bien con una persona ejerciendo los cuatro que con cuatro personas distintas:

| Sombrero | Qué aprueba | Hoy lo ejerce | Puede delegarse a |
|---|---|---|---|
| **Product Owner** | Alcance, prioridad, checkpoint A2.1/B2.1 (clasificación de nivel) | el operador | Un colaborador de confianza, con Cronos como asistente en la fase de producto |
| **Arquitecto técnico** | ADRs (`adr/`), checkpoint A3/B3 (recomendación de modelo), decisiones irreversibles | el operador | Alguien con criterio técnico, con Cronos como asistente en la fase de arquitectura |
| **Oficial de seguridad** | Excepciones a hallazgos de la fase de seguridad del `self-critique-loop`, checkpoint A3.1/B3.1 (Capa 2 de loops) | el operador | Nunca se delega sin experiencia de seguridad real |
| **Aprobador de operaciones** | Deploy a producción, migraciones destructivas (las condiciones de `deploy-checklist`) | el operador | El más sensible de delegar — candidato natural a quedar siempre en el operador incluso si los otros tres se delegan |

Formalizar los cuatro sombreros hoy, con un solo operador, no cambia nada en el día a día — pero crea el andamiaje para delegar *uno* sin rediseñar toda la gobernanza cuando llegue el momento (por ejemplo, cuando un colaborador de `GUIA-PARA-PRINCIPIANTES.md` madure lo suficiente).

**Nota v3.0.0:** con un solo agente en vez de 10, "Cronos como asistente" en la tabla de arriba significa que la misma sesión que hace el trabajo también puede resumir contexto para quien ejerce el sombrero — no que haya un Titán separado dedicado a ese rol. La responsabilidad de gobernanza sigue siendo siempre humana; lo único que cambia es quién hace el trabajo técnico de fondo.

## Cuándo se convoca el Consejo

No por calendario — por evento, en cuatro momentos:

1. **Antes de que arranque un proyecto Nivel 3** — revisión estructurada de alcance, riesgos (`RIESGOS.md`) y recomendación de modelo.
2. **En cada bump de versión del core** (como este mismo, v2.0.1 → v3.0.0) — revisión de `ROADMAP.md`, cierre de riesgos, nuevos ADRs.
3. **Cuando una entrada de `RIESGOS.md` escala a impacto "crítico"** — convocatoria ad hoc, sin esperar al próximo evento programado.
4. **Cuando alguna de las métricas mínimas de abajo cruza su umbral** (nuevo en v3.2.0, `ADR-009`) — único disparador cuantitativo, el resto son cualitativos.

### Métricas mínimas (revisión rápida, no un framework de KPIs)

Se calculan a ojo sobre `RIESGOS.md` y `LECCIONES.md` — no requieren tooling ni telemetría (eso sigue siendo R-013, sin resolver):

| Métrica | Cómo se calcula | Umbral que dispara convocatoria |
|---|---|---|
| Riesgos abiertos sin revisión reciente | Entradas con Estado `abierto` cuya `Última revisión` supera 90 días | Cualquier entrada con Impacto `alto` o `crítico` que lo cruce |
| Proporción de riesgos abiertos | Entradas `abierto` ÷ total de entradas en `RIESGOS.md` | Supera 40% del total |
| Tamaño de `LECCIONES.md` | Entradas activas (no podadas) | Cruza el umbral de partición de R-017 (30 entradas o 12 meses) |

Estas métricas no reemplazan los tres disparadores cualitativos de arriba — son una red de seguridad para el caso en que nadie note el problema "a ojo" antes de que se acumule.

## Matriz RACI mínima

Para las decisiones que hoy son ambiguas sobre quién decide qué (R = Responsable, A = Aprueba, C = Consultado, I = Informado):

| Decisión | Product Owner | Arquitecto | Seguridad | Operaciones |
|---|---|---|---|---|
| Cambio de alcance | A/R | C | I | I |
| ADR nuevo o cambio de stack | C | A/R | C | I |
| Excepción a un hallazgo de seguridad del `self-critique-loop` | I | C | A/R | I |
| Deploy a producción | I | C | C | A/R |
| Promover skill de proyecto a catálogo global *(nuevo en v4.1.0, ver `adr/ADR-012`)* | A/R | C | I | I |
| Bump de versión del core | C | A/R | C | C |
| Cambio de modelo recomendado | I | A/R | I | I |
| Escalar un riesgo de `RIESGOS.md` a crítico | C | C | C | C (cualquier sombrero puede iniciarlo) |

## Alternativas consideradas en decisiones de impacto (formalizado en v3.1.0)

Todo ADR que registre una decisión de impacto real (cambio de arquitectura, de stack, o que sea costoso de revertir) debe incluir su sección "Alternativas consideradas" con al menos dos opciones descartadas y el motivo puntual de cada descarte — práctica que ya era de facto desde `adr/ADR-001-cronos-agente-primario.md`, formalizada como regla explícita a partir de `adr/ADR-008-omega-capacidades-sin-multiagente.md`.

Esto resuelve, con lo que ya existía, el pedido externo de un "Titan Council" que convocara distintos roles (Producto, Arquitectura, Seguridad, QA) antes de decidir: en vez de que Cronos genere párrafos simulando opiniones de roles separados en el mismo turno —lo cual sería la misma autocrítica de siempre con más pasos, no una segunda mirada real—, la decisión pasa igual por los sombreros humanos de la tabla de arriba, con las alternativas ya escritas y descartables por cualquiera de ellos. Ver "Alternativas consideradas" de ADR-008 para el razonamiento completo de por qué se descartó simular el Council como mecanismo aparte.

## Relación con el resto del kit

- Este documento **no reemplaza** los checkpoints ya definidos en `MASTER_PROMPT.md` (A2.1, A3/B3, A3.1/B3.1, B2.1) — les da estructura de quién los aprueba cuando dejen de ser una sola persona.
- **No se instala globalmente** (`~/.config/opencode/`, `~/.codex/`) ni se copia a `.cronos/` de ningún proyecto por los scripts de ciclo de vida: es gobernanza del kit, no una instrucción que Cronos necesite en su contexto de sesión.
- Se referencia desde `AGENCY.md` como componente global, junto a `RIESGOS.md`, `ROADMAP.md` y `adr/`.

## Estado real hoy (2026-08-06, v4.2.0)

Los cuatro sombreros los ejerce una sola persona (el operador). Este documento es, por ahora, el diseño del andamiaje — no un cambio de gobernanza en la práctica. El primer paso real pendiente sigue en `ROADMAP.md`: la primera convocatoria formal del Consejo, aunque sea con un solo sombrero activo, para empezar a ejercitar el patrón antes de que haga falta delegar de verdad. La decisión de `adr/ADR-011` (reabrir la exclusividad de OpenCode) se tomó bajo el sombrero de Arquitecto técnico, mismo proceso que ya cubría "ADR nuevo o cambio de stack" en la matriz de arriba — no necesitó una fila nueva.
