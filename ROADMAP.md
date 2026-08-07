# ROADMAP.md — Cronos

Horizontes, no fechas comprometidas — mismo criterio que ya usa la skill `mvp-roadmap-planning` para los proyectos que construye el agente.

Un ítem pasa de una columna a la siguiente solo cuando el Consejo Estratégico (`GOBERNANZA.md`) lo confirma en una de sus convocatorias.

## Corto plazo — ya incluido en v3.0.0

- [x] Consolidación a un único agente (Cronos), ver `adr/ADR-007-consolidacion-agente-unico.md`.
- [x] Renombre de la agencia a "Cronos".
- [x] Eliminación de `titanes/*.template.md`, `fragments/` y `scripts/generar-plantillas.py`.
- [x] Eliminación de `adapters/` (uso exclusivo de OpenCode).
- [x] `SKILLS.md` — catálogo curado con 7 skills nuevas (`self-critique-loop`, `security-baseline`, `backend-patterns`, `database-design`, `performance-baseline`, `deploy-checklist`, `external-integrations`) que reemplazan la disciplina que antes vivía en cada plantilla de Titán.
- [x] `MODELOS.md` — criterio de recomendación por fase en vez de por Titán.
- [x] `opencode.template.json` — un único agente `cronos` con todos los patrones de `permission.bash` consolidados.
- [x] `scripts/elegir-modelo.sh` (singular) reemplaza a `scripts/elegir-modelos.sh`.
- [x] `RIESGOS.md` — cierre de R-005, R-008, R-009, R-010 (ya no aplican); nuevo R-015 (autoauditoría sin segunda mirada independiente).
- [x] `GOBERNANZA.md` actualizado a las nuevas fases/checkpoints.

## Corto plazo — ya incluido en v3.1.0 (Cronos Omega)

- [x] `docs/PROPUESTA-OMEGA.md` — diagnóstico completo del pedido externo "Cronos Omega V5 Ultimate" (debilidades, gaps reales, capacidades redundantes) que originó esta versión.
- [x] `adr/ADR-008-omega-capacidades-sin-multiagente.md` — decisión de incorporar las capacidades nuevas como skills/fases del agente único, sin reabrir ADR-007.
- [x] 3 skills nuevas: `design-benchmark`, `cost-intelligence`, `capability-gap-analysis` — `SKILLS.md` pasa de 14 a 17.
- [x] `LECCIONES.md` (nuevo componente global, memoria evolutiva entre proyectos) — `LECCIONES.example.md` como plantilla.
- [x] `MASTER_PROMPT.md`: paso A2.2 (benchmark de diseño) y paso 7.5 (cierre de proyecto Nivel 2/3).
- [x] `RIESGOS.md` — R-016 (Skill Forge sin curaduría) y R-017 (`LECCIONES.md` sin límite de tamaño), nuevos.
- [x] `STACK.example.md`/`AUDITORIA.example.md` — secciones nuevas de Identidad visual y Costo.
- [x] `scripts/instalar-global.sh` — paso no destructivo para `LECCIONES.md`.
- [x] Resuelto el ítem pendiente desde v3.0.0 sobre si 14 skills era el número correcto: ahora 17, cada una con criterio de activación explícito en `SKILLS.md`. Reabrir solo si el uso real muestra solapamiento.

## Corto plazo — ya incluido en v3.2.0

- [x] `docs/PROPUESTA-V4-ENTERPRISE.md` — diagnóstico completo del pedido externo "Los Titanes Enterprise V4.0" (mismo tipo de pedido que Omega, un día después: multiagente, consejo simulado, multiplataforma, con nombres nuevos).
- [x] `adr/ADR-009-v4-enterprise-sin-reabrir-diseno.md` — decisión: 9 de 12 fases pedidas descartadas (ya cubiertas o contradicen `ADR-007`/`ADR-008`), 3 debilidades reales incorporadas.
- [x] `LECCIONES.example.md` — taxonomía ampliada (patrón/antipatrón/incidente/playbook) + regla concreta de poda/partición.
- [x] `RIESGOS.md` — R-017 pasa de "aceptado" a "mitigado".
- [x] `GOBERNANZA.md` — sección de métricas mínimas + 4º disparador cuantitativo de convocatoria del Consejo.

## Corto plazo — ya incluido en v3.3.0

- [x] `docs/PROPUESTA-QA-BROWSER-INTELLIGENCE.md` — diagnóstico completo del pedido externo "Cronos Omega — Autonomous QA & Browser Intelligence" (cuarto pedido con el mismo framing multiagente en la Fase 6 — "Atlas, Hefesto, Prometeo" — descartado sin reabrir `ADR-007`/`ADR-008`/`ADR-009`; a diferencia de los tres pedidos anteriores, las Fases 1-3 sí señalaban un hueco técnico real).
- [x] `adr/ADR-010-qa-browser-intelligence-sin-multiagente.md` — decisión: Fase 1 (Playwright) incorporada íntegra esta versión; Fases 2-3 (exploración autónoma, QA visual) programadas para v3.4.0; Fase 4 (self-healing) reducida a "propone, nunca aplica solo" para v3.5.0; Fase 5 (Knowledge System) descartada como sistema nuevo — ya cubierta por `LECCIONES.md`/`technical-governance`; mitad multiagente de la Fase 6 descartada, mitad de infraestructura programada para v3.5.0.
- [x] `skills-custom/browser-qa-e2e/` — skill nueva: pruebas E2E reales con Playwright MCP (login, navegación, CRUD, formularios, tablas, captura de errores, reporte HTML). `SKILLS.md` pasa de 17 a 18.
- [x] `deploy-checklist` — quinta condición no negociable: evidencia de `browser-qa-e2e` si el proyecto tiene UI web y es Nivel 2/3.
- [x] `STACK.example.md` — sección Testing ampliada con ubicación de la suite y última corrida.
- [x] `gitignore.template` — excluye `qa/reports/`, `playwright-report/`, `test-results/` (no `qa/tests/` ni `qa/baselines/`, que sí se versionan).
- [x] `RIESGOS.md` — R-018 nuevo (habilitación desproporcionada de la skill nueva).

## Corto plazo — ya incluido en v4.0.0

- [x] `adr/ADR-011-multiplataforma-opencode-codex-vscode.md` — reabre parcialmente `ADR-007` (solo la exclusividad de OpenCode, no la de agente único) a pedido directo del operador, con necesidad real evidenciada (fork paralelo `TitanesLiteCodex` para Codex CLI) — a diferencia de los tres pedidos externos anteriores que este mismo criterio rechazó (`ADR-008`, `ADR-009`, `ADR-010`, ver "Descartado" abajo).
- [x] `adapters/{opencode,codex,vscode}/` — vuelve a existir, con exactamente 3 plataformas (no una lista abierta), cada una con necesidad real confirmada. `opencode.template.json` se mueve a `adapters/opencode/`, sin cambios de mecánica.
- [x] `AGENTS.md` — nuevo punto de entrada universal (raíz del kit y de cada proyecto generado), leído de forma nativa por las 3 plataformas — apoyado en que `AGENTS.md`/`SKILL.md` se consolidaron como estándares abiertos multiplataforma desde que se escribió `ADR-005` (julio 2026).
- [x] `MASTER_PROMPT.md` — Paso 0 gana detección de plataforma, fusionada con la detección de situación que ya existía; pasos A3/B3/7.1 ramifican la selección de modelo por plataforma.
- [x] `MODELOS.md` — Paso 1 (descubrimiento) ramificado por plataforma; Paso 2/3 sin cambios, ya eran agnósticos desde `ADR-002`.
- [x] `scripts/elegir-modelo.sh`, `nuevo-proyecto.sh`, `adoptar-proyecto.sh`, `actualizar-proyecto.sh`, `instalar-global.sh` — reescritos para detectar y operar sobre la plataforma correspondiente, sin restringir el valor del modelo en ningún caso (confirmado con prueba funcional, no solo por diseño).
- [x] `scripts/_lib-cronos.sh` — librería nueva, compartida entre los 3 scripts de ciclo de vida de proyecto, para que no diverjan entre sí.
- [x] `~/.cronos/LECCIONES.md` — memoria evolutiva pasa a vivir en una ruta neutral de plataforma, compartida entre las 3 en vez de duplicada.
- [x] `.cronos/` por proyecto — copia local sincronizable del núcleo, necesaria porque VS Code/Copilot no tiene mecanismo global (modifica el Principio 6 de `AGENCY.md`, con la excepción documentada ahí mismo).
- [x] `RIESGOS.md` — R-008 reabierto con mitigación nueva (no cerrado por decisión unilateral); R-009 referenciado como lección reaplicada, no reabierto; R-019/R-020/R-021 nuevos.
- [x] `scripts/verificar-kit.sh` — de 6 a 7 chequeos: valida JSON **y TOML** de cada adaptador, corre ShellCheck siguiendo `_lib-cronos.sh` (antes solo avisaba que no la seguía), y confirma que la estructura de `adapters/` está completa.

## Corto plazo — ya incluido en v4.1.0

- [x] `adr/ADR-012-deteccion-proactiva-promocion-skills.md` — extiende `capability-gap-analysis` en dos ejes, a pedido directo del operador, sin reabrir el límite que `ADR-008`/R-016 ya establecieron para "Skill Forge": propone antes, nunca instala/promueve sin confirmación.
- [x] `.cronos/gaps-detectados.md` — registro de trabajo nuevo por proyecto (estado, no núcleo — nunca sincronizado por `actualizar-proyecto.sh`), para que la detección de un gap repetido no dependa solo de la memoria conversacional de la sesión.
- [x] `skills-custom/self-critique-loop/SKILL.md` — paso 6 nuevo (solo Nivel 2/3): chequeo liviano de gap al cerrar cada tarea, registra en `gaps-detectados.md`.
- [x] `skills-custom/capability-gap-analysis/SKILL.md` — se activa apenas hay una segunda entrada parecida en el proyecto, no solo al cerrar; chequea `~/.cronos/LECCIONES.md` para detectar repetición cross-proyecto antes de proponer; dos destinos posibles (local vs. global) según esa evidencia, cada uno con su propio checkpoint de confirmación.
- [x] `scripts/promover-skill.sh` — nuevo. Copia una skill de `.cronos/skills/` de un proyecto a `skills-custom/` del kit fuente y a los directorios globales que existan; deja una fila "pendiente de revisión curada" en `SKILLS.md` en vez de fingir curaduría automática.
- [x] `MASTER_PROMPT.md` — Paso 0.3 nuevo: lee `~/.cronos/LECCIONES.md` al arrancar cualquier proyecto (antes solo se escribía al cerrar) — infraestructura necesaria para que el chequeo cross-proyecto de arriba tenga con qué comparar.
- [x] `GOBERNANZA.md` — fila RACI nueva: "Promover skill de proyecto a catálogo global" (Product Owner A/R).
- [x] `RIESGOS.md` — R-016 extendido (mitigación central intacta: nunca instala/promueve sin confirmación); R-022 nuevo (calidad de skills promovidas, honesto sobre el trade-off).

## v4.2.0 — ya incluido

- [x] `adr/ADR-013-subagentes-temporales-controlados.md` — permite delegación acotada sin
  restaurar los Titanes permanentes ni transferir autoridad de Cronos.
- [x] `adapters/opencode/opencode.template.json` — habilita `task` para Cronos y limita la
  profundidad de subagentes a uno.
- [x] `AGENTS.md`, `AGENCY.md`, `MASTER_PROMPT.md` y `scripts/instalar-global.sh` — propagan las
  reglas de delegación controlada, revisión posterior y prohibición de secretos, Git, despliegues,
  migraciones, gasto y aprobación por subagentes.

## Pendiente — próxima versión (v3.4.0)

- [ ] Extensión de `advanced-qa-strategy`: exploración autónoma guiada por objetivo (Fase 2 de `ADR-010`, acotada — reutiliza Playwright MCP + el patrón de `/cronos-verificar-objetivo`, sin adoptar un framework "Browser Use" separado) y QA visual con baselines versionados (Fase 3).
- [ ] `RIESGOS.md` — nueva entrada `R-XXX` para el riesgo candidato QA-C (falsos positivos de QA visual por renderizado no determinístico, ver `docs/PROPUESTA-QA-BROWSER-INTELLIGENCE.md` §11), a incorporar junto con la Fase 3.
- [ ] Validar con un proyecto Nivel 2/3 real que `browser-qa-e2e` (v3.3.0) funciona de punta a punta antes de sumar estas dos capas — mismo criterio de "validar antes de ampliar" que ya aplicó Omega.

## Pendiente — próxima versión (v3.5.0)

- [ ] Self-healing reducido ("propone, nunca aplica solo") sobre `browser-qa-e2e`/`advanced-qa-strategy` — Fase 4 de `ADR-010`.
- [ ] Extensión de `external-integrations`: credenciales de entorno de prueba para Firebase/Supabase/similares, nunca contra producción — mitad de infraestructura de la Fase 6 de `ADR-010`.
- [ ] Cierre del pendiente de CI real (ver "largo plazo" más abajo) ampliado para incluir la suite de `browser-qa-e2e` del proyecto, no solo `scripts/verificar-kit.sh` del kit.
- [ ] `RIESGOS.md` — nuevas entradas `R-XXX` para los riesgos candidatos QA-A (self-healing enmascarando regresiones) y QA-B (credenciales de prueba contra servicios reales, ver `docs/PROPUESTA-QA-BROWSER-INTELLIGENCE.md` §11), a incorporar junto con estas capacidades.

## Pendiente — sin versión específica (verificación y validación continua)

Ítems que no son una capacidad nueva a entregar en un número de versión, sino verificación pendiente de algo ya escrito — se listaban antes bajo una etiqueta de versión que terminó ocupando el trabajo de QA/Browser Intelligence (ver arriba), así que se sacan de ahí:

- [ ] **R-002 — Verificación empírica de propagación de reglas de oro a la sesión primaria.** La capa de configuración ya se verificó (2026-07-16, contra `opencode-ai` v1.18.3 — ver `docs/AUDITORIA-10-10-verificacion-R002.md`): `instructions` del `opencode.json` global sí llega a la configuración resuelta de un proyecto sin `instructions` propio. Queda un único paso, que requiere una sesión real de OpenCode con modelo configurado: confirmar que Cronos puede listar las reglas de oro sin que se las repitan (`README.md`, "Verificación recomendada", paso 2).
- [ ] Primera convocatoria real del Consejo Estratégico con un segundo sombrero delegado a otra persona, no solo el diseño en papel.
- [ ] R-012 — Documentar explícitamente que la carpeta extraída del kit debe persistir en disco.
- [ ] Validar en la práctica que la recomendación de modelo "distinto para la fase de seguridad" (R-015, `MODELOS.md`) se sigue de verdad en al menos un proyecto Nivel 2/3 real, no solo que quede documentada.
- [ ] Primer proyecto Nivel 2/3 real usando `design-benchmark` y `capability-gap-analysis` — validar con uso real antes de dar la propuesta de Omega por definitivamente cerrada (mismo criterio que ya aplica el kit a todo lo nuevo).
- [ ] Primer proyecto Nivel 2/3 real usando `browser-qa-e2e` de punta a punta — condición para avanzar con la Fase 2/3 de `ADR-010` (ver "Pendiente — próxima versión (v3.4.0)" arriba).
- [ ] **R-019 — Verificación empírica de los adaptadores de Codex CLI y VS Code.** Ambos se verificaron contra documentación pública al 2026-08-03 (ver `adr/ADR-011`), no contra una sesión real — mismo tipo de paso pendiente que R-002 ya tuvo para OpenCode antes del 2026-07-16. Requiere una sesión real de cada plataforma: confirmar que Cronos puede listar las reglas de oro sin que se las repitan, y que el cambio de modelo vía `scripts/elegir-modelo.sh` efectivamente se refleja en `/status` (Codex CLI) o en el comportamiento real de la sesión.
- [ ] Primer proyecto real usando Codex CLI o VS Code de punta a punta con este kit — validar con uso real antes de dar la cobertura multiplataforma de v4.0.0 por definitivamente probada (mismo criterio que ya aplica el kit a todo lo nuevo).
- [ ] Primera skill real que complete el ciclo entero de v4.1.0 (detectada en `gaps-detectados.md` → propuesta local confirmada → repetida en un segundo proyecto → promovida con `promover-skill.sh`) — validar con uso real antes de dar por probado que el flujo completo, no solo cada paso por separado, funciona como se diseñó.

## Pendiente — mediano plazo (v3.x)

- [ ] Telemetría de uso propia (R-013) — requiere diseño de hooks en tiempo de ejecución, no solo archivos estáticos.
- [ ] Checksums de integridad para Superpowers/`ui-ux-pro-max` en `STACK.example.md`.
- [ ] Postura de contingencia explícita para Superpowers y `ui-ux-pro-max` (R-007).
- [ ] Medir si el `self-critique-loop` converge en la práctica dentro de dos vueltas (criterio de corte definido en la skill) o si ese límite necesita ajustarse con datos reales de uso.

## Pendiente — largo plazo (v4.0+)

- [ ] CI real (GitHub Actions u equivalente) corriendo `scripts/verificar-kit.sh` en cada cambio, en vez de correrlo a mano.
- [ ] Consejo Estratégico con más de un sombrero efectivamente delegado a otra persona (no solo diseñado para poder delegarse).
- [ ] Revisión completa de si el modelo de "un agente con fases" sigue siendo el correcto a esa escala de uso, con datos reales de proyectos Nivel 3 construidos con él.

## Descartado / fuera de alcance por ahora

- Volver a una arquitectura multiagente — la consolidación de v3.0.0 fue un pedido explícito, no un experimento reversible sin nueva decisión deliberada (ver ADR-007). Reafirmado en v3.1.0 (ADR-008) ante un pedido externo que lo proponía bajo otro nombre ("Titan Council", "Arquitecto Principal Multiagente"), de nuevo en v3.2.0 (ADR-009) ante un tercer nombre ("Strategic Council", "Titan Core"), y de nuevo en v4.0.0 (ADR-011): reabrir la exclusividad de OpenCode no reabre esto — son decisiones independientes, y nadie pidió esta.
- ~~Adaptadores multiplataforma — mismo criterio: uso exclusivo de OpenCode por decisión explícita, no lock-in accidental (ver R-008, cerrado). Reafirmado en ADR-009 pese a que el pedido nombraba explícitamente una plataforma (Roo Code) que ya había cerrado.~~ **Ya no aplica desde v4.0.0** — a diferencia de los pedidos que sí siguen descartados en esta lista, este vino directamente del operador con necesidad real evidenciada, no como propuesta externa especulativa. Ver `ADR-011` y la sección "ya incluido en v4.0.0" arriba para el porqué exacto de la distinción.
- PMO Empresarial / Portfolio Management — pedido en v3.2.0 (Master Task V4.0), descartado en `ADR-009`: asume una escala de multi-proyecto/multi-equipo que no existe con un operador.
- Reunión periódica formal del Consejo Estratégico — se prefiere gobernanza por evento (ver `GOBERNANZA.md`), no por calendario, mientras el equipo siga siendo pequeño.
- Registro de auditoría (audit log) de cada acción — de momento `tasks.md` + `CHANGELOG.md` + `RIESGOS.md` alcanzan; se reconsidera si el equipo crece.
- Knowledge Graph con trazabilidad formal ADR→Riesgo→Skill→Proyecto — pedido en v3.2.0, descartado en `ADR-009` por el mismo motivo que el audit log: referencias cruzadas livianas alcanzan a esta escala.
- "Integración Titanes" (Cronos, Atlas, Hefesto, Prometeo como agentes de integración) — pedido en v3.2.0/v3.3.0 ("Cronos Omega — Autonomous QA & Browser Intelligence", Fase 6), descartado en `ADR-010`: cuarta vez que llega el framing multiagente bajo un nombre distinto (ver ADR-007, ADR-008, ADR-009) — ninguna reabre ADR-007. La mitad de infraestructura real de esa misma Fase 6 (CI/CD, GitHub, Firebase, Supabase) sí se incorpora, sin agentes nuevos — ver v3.5.0 arriba.
- Sistema de conocimiento nuevo dedicado a hallazgos de QA (ADRs/patrones/checklist autogenerados) — pedido en v3.3.0 (Fase 5 de `ADR-010`), descartado: `LECCIONES.md` (con su taxonomía patrón/antipatrón/incidente/playbook desde v3.2.0) y `technical-governance` ya cubren esto sin archivos nuevos — un ADR generado automáticamente de un bug, además, contradice el propio criterio de `GOBERNANZA.md` para qué hace válido a un ADR.
- Framework de automatización de navegador separado de Playwright MCP (tipo "Browser Use") — pedido en v3.3.0 (Fase 2 de `ADR-010`), descartado por ahora: Playwright MCP ya expone snapshot de accesibilidad y acciones suficientes para exploración guiada por objetivo; sumar una segunda herramienta con propósito superpuesto sin confirmar que la primera no alcanza repite la inflación de superficie que R-016 ya señaló para el Skill Forge. Se reevalúa solo si un proyecto real demuestra el límite.
- Self-healing de tests con auto-aplicación (sin gate humano) — pedido en v3.3.0 (Fase 4 de `ADR-010`), descartado en su forma original: contradice el Principio 8 de `AGENCY.md` ("Nada de humo") y agrava R-015. La versión reducida ("propone, nunca aplica solo") queda programada para v3.5.0.
