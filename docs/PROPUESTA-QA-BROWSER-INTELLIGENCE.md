# PROPUESTA — Evaluación del pedido "Cronos Omega — Autonomous QA & Browser Intelligence"

Documento de diseño para gate de aprobación (checkpoint tipo A3, `GOBERNANZA.md`: Arquitecto técnico). No modifica el kit todavía — es el `STACK.md`/`tasks.md` de este meta-proyecto. Una vez aprobado, se implementa archivo por archivo, en el orden del roadmap (§14).

## 0. Nota sobre el framing y el nombre de versión

Este es el cuarto pedido externo con forma de "Master Task" que llega a Cronos (`ADR-008` para el primero, `ADR-009` para el segundo). Todos comparten un rasgo: piden, en algún punto, volver a nombrar Titanes como agentes separados. Acá es la Fase 6 ("Integración Titanes": Cronos, Atlas, Hefesto, Prometeo). Ese punto se descarta sin reabrir `ADR-007` — ver `adr/ADR-010-qa-browser-intelligence-sin-multiagente.md`, ya escrito con el mismo criterio que `ADR-008`/`ADR-009`.

Lo que distingue a este pedido de los dos anteriores: **no es mayormente redundante**. Omega y V4.0 pedían gobernanza que, auditada, ya existía con otro nombre. Este pedido, en sus Fases 1-3, señala un hueco técnico real: Cronos menciona Playwright MCP en tres lugares del kit (`AGENCY.md`, `opencode.template.json`, `advanced-qa-strategy`) sin que ninguno diga cómo se usa en la práctica. Por eso esta propuesta no es "3 debilidades reales, resto descartado" como `ADR-009` — es una skill nueva de verdad, con superficie real, que por disciplina de versionado (`CHANGELOG.md`, semver) no entra en un solo bump: se escalona en `3.3.0 → 3.4.0 → 3.5.0` (§14), no un salto a "Omega" ni a "4.0".

## 1. Diagnóstico actual (qué existe hoy, verificado contra el kit real, v3.2.0)

- `opencode.template.json` ya declara `mcp.playwright` (`@playwright/mcp`, `enabled: false`) — instalado como scaffold, apagado por defecto, sin ningún proyecto de referencia que lo haya encendido todavía.
- `AGENCY.md`, paso 3 del ciclo de autocrítica ("sombrero de QA"), ya dice explícitamente: *"corre las pruebas relevantes (unitarias, E2E con Playwright MCP si aplica)"*.
- `skills-custom/advanced-qa-strategy/SKILL.md` ya da por sentado, en su propia descripción, que existe *"el testing funcional que Cronos ya hace con Playwright MCP en el paso de QA del self-critique-loop"* — y aclara que esta skill *complementa*, no reemplaza, ese testing funcional.
- `STACK.example.md`, sección Testing, ya tiene el campo `¿Playwright MCP habilitado?: sí/no — por qué`.
- `LOOPS.md` ya documenta `/cronos-verificar-objetivo <condición> --comando "<verificación>"` — un comando nativo que recibe una instrucción de alto nivel y exige evidencia verificable antes de reportar algo como cumplido, con manejo explícito de "bloqueado" y "necesita más alcance". Es, en espíritu, exactamente lo que la Fase 2 del pedido busca ("Verifica que Mercado Inteligente funcione correctamente" → navegación autónoma → evidencia), solo que hoy no tiene ninguna herramienta de navegador detrás.
- `LECCIONES.md` (desde v3.1.0) + su taxonomía patrón/antipatrón/incidente/playbook (desde v3.2.0, `ADR-009`) ya es el mecanismo de memoria evolutiva entre proyectos — la Fase 5 del pedido ("conocimiento reutilizable") pide, con otro nombre, algo que ya existe.
- `deploy-checklist` ya tiene 4 condiciones no negociables de despliegue, ninguna referida a QA de navegador.
- `ROADMAP.md`, horizonte "largo plazo (v4.0+)", ya tiene pendiente *"CI real (GitHub Actions u equivalente) corriendo `scripts/verificar-kit.sh` en cada cambio"* — sin diseño concreto de cómo correría una suite de pruebas de un proyecto (a diferencia de `verificar-kit.sh`, que audita el kit mismo, no los proyectos que construye).
- No existe, en ningún archivo, ningún mecanismo de: reporte HTML de pruebas, comparación visual, detección de regresión visual, exploración autónoma guiada por objetivo con navegador real, ni self-healing de ningún tipo.

**Conclusión del diagnóstico:** la intención de Playwright como herramienta de QA ya está aceptada desde `ADR-007` (v3.0.0) — lo que falta es el diseño. Este pedido, descontado el framing multiagente de la Fase 6, es básicamente esa tarea pendiente.

## 2. Debilidades reales encontradas (independientes del pedido)

| # | Debilidad | Evidencia |
|---|---|---|
| D1 | Playwright MCP está referenciado en 3 archivos distintos sin que ninguno defina el flujo real (qué prueba, en qué orden, con qué evidencia de salida) | `AGENCY.md` L~ (paso QA), `opencode.template.json` (`mcp.playwright`), `advanced-qa-strategy/SKILL.md` |
| D2 | `deploy-checklist` no tiene ninguna condición relacionada con QA de UI end-to-end, pese a que la mayoría de los proyectos de Nivel 2/3 (`CRUDs completos, dashboards, ERP, CRM, SaaS`) tienen UI web | `skills-custom/deploy-checklist/SKILL.md` |
| D3 | El pendiente de CI real en `ROADMAP.md` (largo plazo) no distingue entre "verificar el kit" (`verificar-kit.sh`) y "correr la suite de un proyecto" — son cosas distintas y el ítem tal como está redactado solo cubre la primera | `ROADMAP.md`, horizonte largo plazo |
| D4 | No hay ninguna instrucción sobre credenciales de prueba contra servicios reales (Firebase/Supabase) en un contexto de QA automatizado — `external-integrations` cubre integraciones de producto, no credenciales de entorno de pruebas | `skills-custom/external-integrations/SKILL.md` |

## 3. Capacidades faltantes reales (gap real vs. el pedido — lo que sí se construye)

- Skill estructurada de QA funcional con Playwright (Fase 1): login, navegación, CRUD, formularios, tablas, captura de errores, reporte HTML.
- Capa de exploración autónoma guiada por objetivo dentro de `advanced-qa-strategy` (Fase 2, acotada — ver §4).
- Capa de QA visual con baselines versionados dentro de `advanced-qa-strategy` (Fase 3).
- Quinta condición de `deploy-checklist` ligada a evidencia de QA de navegador cuando el proyecto tiene UI web.
- Extensión del pendiente de CI en `ROADMAP.md` para que distinga "verificar el kit" de "correr la suite Playwright del proyecto".
- Regla explícita de credenciales de entorno de prueba (nunca contra producción) para Firebase/Supabase/similares, dentro de `external-integrations`.

## 4. Fase por fase del pedido original — qué se incorpora, qué se reduce, qué se descarta

| Fase del pedido | Auditoría | Acción |
|---|---|---|
| **Fase 1 — Playwright** (login, CRUD, formularios, tablas, capturas, reporte HTML, ejecutable manual/CI/desde Cronos) | Hueco real — ver D1. Todo lo pedido es razonable y proporcional a un proyecto Nivel 2/3 con UI web. "Ejecutable desde Cronos" ya es el modelo (Cronos usa Playwright MCP como herramienta dentro de su propio turno, igual que ya usa subagentes de Superpowers "como herramienta... no como agentes de la agencia", `SKILLS.md`). "Ejecutable manual" = correr la suite fuera de una sesión de Cronos, con `@playwright/test` normal. "Ejecutable desde CI/CD" = D3, ver Fase 6. | **Incorporar íntegro** como skill nueva `browser-qa-e2e` |
| **Fase 2 — Browser Intelligence** ("Browser Use", instrucción de alto nivel → navegación autónoma → hallazgos) | Real en la intención, sobredimensionada en el mecanismo. El patrón "instrucción de alto nivel → verificación con evidencia" ya existe (`/cronos-verificar-objetivo`, `LOOPS.md`). Lo que falta es la herramienta de navegador detrás — que ya está (Playwright MCP, con su propio snapshot de accesibilidad y acciones). Un framework "Browser Use" aparte sería una segunda herramienta con propósito superpuesto sin haber confirmado que la primera no alcanza — mismo patrón de inflación que R-016 ya nombra para el Skill Forge. | **Incorporar acotado**: capa nueva de `advanced-qa-strategy` que reutiliza Playwright MCP + el patrón de `/cronos-verificar-objetivo`, con el mismo límite de alcance que `LOOPS.md` ya exige ("una sola tarea/módulo por vez", nunca "todo el proyecto de punta a punta", nunca una condición de éxito que incluya deploy o migración destructiva) |
| **Fase 3 — QA Visual** (capturas, comparación, cambios inesperados, elementos faltantes, desalineaciones) | Hueco real, sin superposición con nada existente. | **Incorporar íntegro** como segunda capa nueva de `advanced-qa-strategy`, con baselines versionados en el repo del proyecto (no en el kit) |
| **Fase 4 — Self Healing Tests** (detectar cambios menores, autocorregirse, generar propuestas, mantener estabilidad) | Riesgo real de enmascarar regresiones si se implementa tal como está escrito ("autocorregirse" sin gate humano). Contradice el Principio 8 de `AGENCY.md` ("Nada de humo") y agrava R-015. La industria del testing conoce este patrón como fuente común de falsos positivos silenciosos: un test que se "cura" solo deja de ser una señal confiable de que algo se rompió. | **Incorporar muy reducido**: Cronos puede detectar que un test falló por un cambio trivial de UI (selector/atributo/texto) y **proponer** el ajuste como diff — nunca aplicarlo sin confirmación, mismo patrón que `capability-gap-analysis` ya usa para skills nuevas. Cada propuesta aceptada o rechazada se registra en `LECCIONES.md` (categoría patrón/antipatrón) para decidir con datos reales, tras varios proyectos, si vale la pena mantenerlo |
| **Fase 5 — Knowledge System** (ADRs automáticos, lecciones, patrones, checklist de prevención) | Redundante con lo que ya existe: `LECCIONES.md` con taxonomía patrón/antipatrón/incidente/playbook (desde v3.2.0) cubre "lecciones aprendidas" y "patrones recurrentes"; `technical-governance` ya cubre ADRs — de proyecto, no del kit, y siempre con alternativas consideradas escritas por Cronos, no autogeneradas de un bug. Generar ADRs automáticamente contradice el propio criterio de `GOBERNANZA.md` para qué es un ADR válido. | **Descartar como sistema nuevo.** Los hallazgos de QA recurrentes se enrutan a `LECCIONES.md` (mecanismo ya existente); un hallazgo que amerita una decisión de arquitectura de proyecto sigue el camino ya existente de `technical-governance` |
| **Fase 6 — Integración Titanes** (Cronos, Atlas, Hefesto, Prometeo, CI/CD, GitHub, Firebase, Supabase) | La mitad de la fase (Atlas/Hefesto/Prometeo) repite, con nombres del pedido original de la agencia, el framing multiagente ya rechazado tres veces (`ADR-007`, `ADR-008`, `ADR-009`). La otra mitad (CI/CD, GitHub, Firebase, Supabase) es integración de infraestructura real, sin nada de multiagente en sí misma. | **Descartar la mitad multiagente sin reabrir ADR-007.** **Incorporar la mitad de infraestructura** como extensión de `deploy-checklist` (gate de QA + ejecución en CI) y `external-integrations` (credenciales de entorno de prueba para Firebase/Supabase) |

## 5. Arquitectura — resumen (ADR completo en `adr/ADR-010-qa-browser-intelligence-sin-multiagente.md`)

Sigue el mismo patrón que absorbió a los 10 Titanes en v3.0.0 y a Omega en v3.1.0: **una capacidad nueva es una skill (o una extensión de una skill existente) que Cronos aplica dentro de su propio turno, nunca un agente ni una herramienta externa que decide por su cuenta.** Concretamente:

- Playwright MCP (ya scaffolded) es la única herramienta de navegador. Cronos la invoca como tool dentro de su propia sesión — mismo principio que ya aplica a los subagentes de ejecución de Superpowers ("herramienta dentro del propio turno de Cronos, no agentes de la agencia").
- Ninguna decisión que las reglas de oro de `AGENCY.md` reservan para el operador (deploy, migración destructiva, hallazgo crítico) se automatiza — ni por la exploración autónoma de la Fase 2, ni por el self-healing de la Fase 4. Ambas heredan, sin excepción, las reglas de oro de `/loop`/`/goal` ya escritas en `LOOPS.md`.

## 6. Nuevas skills / extensiones propuestas

| Skill | Tipo | Nivel | Qué agrega |
|---|---|---|---|
| **`browser-qa-e2e`** *(nueva)* | Base técnica, opt-in | 2/3 | Fase 1 completa: login, navegación, CRUD, formularios, tablas, capturas de error, reporte HTML |
| `advanced-qa-strategy` *(extensión)* | Avanzada | 3 | +2 capas: exploración autónoma guiada por objetivo (Fase 2 acotada) y QA visual con baselines (Fase 3) |
| `deploy-checklist` *(extensión)* | Base | 2/3 | +1 condición no negociable: evidencia de `browser-qa-e2e` si el proyecto tiene UI web |
| `external-integrations` *(extensión)* | Base | Cualquiera | Regla explícita: credenciales de entorno de prueba para Firebase/Supabase/similares, nunca contra producción |
| `capability-gap-analysis` *(sin cambios)* | Base | Cierre 2/3 | Ya cubre el registro en `LECCIONES.md` de hallazgos de QA recurrentes — se reutiliza tal cual |

`SKILLS.md` pasa de 17 a 18 skills documentadas.

## 7. Nuevos flujos en `MASTER_PROMPT.md`

- Paso 7 (ciclo de autocrítica), sombrero de QA: si `STACK.md` tiene `¿Playwright MCP habilitado?: sí`, referencia explícita a `browser-qa-e2e` antes de exigir evidencia — mismo patrón que ya usa el paso de frontend con `frontend-craft`.
- Nuevo paso opcional, **7.x — QA exploratorio y visual antes de una release grande** (Nivel 3, no en cada tarea chica): mismo criterio de proporcionalidad que ya usa el paso 4 del `self-critique-loop` para el sombrero de rendimiento ("antes de una release grande, no en cada tarea chica").
- `deploy-checklist` (invocado siempre antes de desplegar): quinta condición nueva.

## 8. MCPs necesarios

| MCP | Estado | Decisión |
|---|---|---|
| `@playwright/mcp` | Ya declarado en `opencode.template.json`, `enabled: false` | Se mantiene tal cual — se habilita por proyecto (`STACK.md`), nunca por defecto |
| "Browser Use" o equivalente | No declarado | **No se agrega.** Se reevalúa solo si un proyecto real demuestra que las acciones/snapshot de Playwright MCP no alcanzan para la exploración guiada por objetivo — mismo criterio de "no instalar por inercia" que ya aplica a la Capa 2 de `LOOPS.md` |
| Servicio de visual regression pago (Percy/Chromatic/Applitools) | No declarado | **No se agrega por defecto.** Camino opcional solo para Nivel 3 con presupuesto, evaluado vía `cost-intelligence` — la comparación visual base se resuelve con las capacidades propias de Playwright (`toHaveScreenshot`) sin costo adicional |

## 9. Estructura de carpetas

Sin carpetas nuevas a nivel del kit fuera de la skill misma — consistente con el principio de `AGENCY.md` de que "un proyecto contiene solo lo específico de ese proyecto":

```
cronos/                                  # kit fuente (sin cambios de fondo en su forma)
├── skills-custom/
│   └── browser-qa-e2e/
│       └── SKILL.md                     # nueva
├── docs/
│   └── PROPUESTA-QA-BROWSER-INTELLIGENCE.md   # este documento
└── adr/
    └── ADR-010-qa-browser-intelligence-sin-multiagente.md   # nuevo

proyecto-generado/                       # dentro de CADA proyecto que la habilite
├── STACK.md                             # sección Testing ampliada
├── qa/
│   ├── playwright.config.*
│   ├── tests/                           # specs: login, CRUD, formularios, tablas
│   ├── baselines/                       # screenshots de referencia — SÍ se versiona (git)
│   └── reports/                         # reporte HTML generado — NO se versiona (gitignore)
└── .gitignore                           # gitignore.template + entrada nueva para qa/reports/
```

## 10. Dependencias

| Dependencia | Costo | Nota |
|---|---|---|
| `@playwright/mcp` | Gratis, MIT | Ya scaffolded |
| `@playwright/test` (a nivel de proyecto, no del kit) | Gratis, Apache 2.0 | Motor de ejecución real de la suite; versión fijada en `STACK.md`, mismo criterio que Superpowers/`ui-ux-pro-max` |
| Navegadores headless (Chromium/Firefox/WebKit) | Gratis | Vienen con `@playwright/test`, sin instalación separada |
| Runner de CI (GitHub Actions u equivalente) | Variable — dentro del free tier para repos privados chicos | Estimarlo por proyecto vía `cost-intelligence` si el uso crece |
| Servicio de visual regression pago | Opcional, no por defecto | Solo si `cost-intelligence` lo justifica en un proyecto Nivel 3 puntual |

Ninguna dependencia nueva a nivel del kit — todo lo de costo real vive a nivel de proyecto, mismo patrón que ya usa `STACK.md` para Superpowers/`ui-ux-pro-max`.

## 11. Riesgos (nuevas entradas para `RIESGOS.md`)

### R-018: Playwright MCP habilitado sin proporcionalidad al nivel del proyecto
Categoría: deriva arquitectónica · Probabilidad: media · Impacto: bajo
Mitigación: `browser-qa-e2e` solo se ofrece en Nivel 2/3 (mismo criterio de proporcionalidad que Superpowers y la Capa 2 de `LOOPS.md`); en Nivel 1 sería fricción innecesaria y no se activa.
Estado: mitigado por diseño

### Riesgo candidato QA-A: self-healing enmascarando regresiones reales (se numera como R-XXX recién cuando se implemente, v3.5.0)
Categoría: punto único de fallo (de criterio) · Probabilidad: media si se implementa mal · Impacto: alto
Mitigación: nunca auto-aplica — solo propone, con confirmación explícita obligatoria (§4, Fase 4). Cada propuesta aceptada/rechazada se registra en `LECCIONES.md` para decidir con datos reales si la capacidad vale la pena mantenerla.
Estado: mitigado (por el límite de diseño, no probado aún con uso real — ver roadmap)

### Riesgo candidato QA-B: credenciales de entorno de prueba contra servicios reales (Firebase/Supabase) (se numera como R-XXX recién cuando se implemente, v3.5.0)
Categoría: punto único de fallo · Probabilidad: media · Impacto: crítico si ocurre (datos reales de producción tocados por una corrida de QA)
Mitigación: `external-integrations` exige explícitamente credenciales de un entorno de prueba dedicado, nunca las de producción — coordina con `security-baseline` el mismo tratamiento que ya reciben otras credenciales.
Estado: mitigado por regla explícita, pendiente de verificación empírica en un proyecto real

### Riesgo candidato QA-C: falsos positivos de QA visual por renderizado no determinístico (se numera como R-XXX recién cuando se implemente, v3.4.0)
Categoría: cuello de botella (de confianza en la señal) · Probabilidad: alta (fuentes, animaciones, fechas dinámicas) · Impacto: bajo-medio (ruido que erosiona confianza en la suite, no un dato perdido)
Mitigación: esperas explícitas antes de capturar, máscaras de zonas dinámicas conocidas (relojes, contenido generado), y baselines actualizados deliberadamente cuando un cambio de diseño es intencional — nunca "aceptar todo" para silenciar el ruido.
Estado: abierto — depende de uso real para calibrar cuánto ruido queda tras la mitigación

## 12. Costos

Sin costo de licencia nuevo: Playwright y su MCP son open source (MIT/Apache 2.0), y los navegadores headless vienen incluidos. El único costo variable real es el de minutos de CI si se corre la suite en cada push — dentro del free tier de GitHub Actions para la mayoría de los repos privados chicos de un operador único; si un proyecto crece lo suficiente para que esto importe, se estima con `cost-intelligence`, mismo criterio que ya aplica a cualquier otro servicio de pago. Un servicio de visual regression pago (Percy/Chromatic/Applitools) es un costo mensual real pero **no se adopta por defecto** — solo si un proyecto Nivel 3 puntual lo justifica.

## 13. Plan de despliegue

1. `scripts/instalar-global.sh` copia `skills-custom/browser-qa-e2e/` a `~/.config/opencode/skills/`, igual que el resto del catálogo — sin pasos nuevos de instalación, reutiliza el mecanismo existente.
2. Por proyecto: Cronos ofrece habilitar `mcp.playwright` (`enabled: true`) en el `opencode.json` del proyecto durante A3/B3 de `MASTER_PROMPT.md`, cuando el proyecto es Nivel 2/3 y tiene UI web — checkpoint de confirmación explícita del operador, mismo patrón que ya usa la Capa 2 de `LOOPS.md`.
3. La capa de self-healing (Fase 4 reducida) requiere una segunda confirmación explícita y separada, por ser la parte más experimental — no se activa junto con `browser-qa-e2e` base sin que el operador la pida.
4. Nada de esto se aplica de forma retroactiva a proyectos ya creados salvo que se corra `scripts/actualizar-proyecto.sh` y se confirme explícitamente.

## 14. Roadmap de implementación (escalonado, no un solo salto)

| Versión | Contenido | Se valida antes de seguir con |
|---|---|---|
| **v3.3.0** | `browser-qa-e2e` (Fase 1 completa) + quinta condición de `deploy-checklist` + campos nuevos en `STACK.example.md` + `ADR-010` | Un proyecto Nivel 2/3 real corriendo la suite de punta a punta, con reporte HTML generado y revisado |
| **v3.4.0** | Extensión de `advanced-qa-strategy`: exploración autónoma guiada por objetivo (Fase 2 acotada) + QA visual con baselines (Fase 3) | Que la exploración autónoma respete el límite de alcance de `LOOPS.md` en la práctica (una tarea/módulo por vez, nunca el proyecto entero) y que las baselines no generen ruido inmanejable (ver riesgo candidato QA-C, §11) |
| **v3.5.0** | Self-healing reducido (propone, no aplica) + extensión de `external-integrations` (credenciales de entorno de prueba) + cierre del pendiente de CI real de `ROADMAP.md` con la suite del proyecto | Uso real de varios proyectos antes de considerar ampliar el alcance del self-healing más allá de "propone" |

Cada paso requiere convocatoria del Consejo (`GOBERNANZA.md`, disparador "bump de versión del core") antes de pasar al siguiente — mismo patrón que ya rige el resto del kit.

## 15. Plan de mantenimiento

- Versión de `@playwright/mcp` y `@playwright/test` fijada explícitamente en `STACK.md` de cada proyecto — mismo criterio que Superpowers/`ui-ux-pro-max`; se revisa en cada convocatoria del Consejo.
- Baselines de QA visual se actualizan deliberadamente cuando un cambio de diseño es intencional (nunca "aceptar todo" para apagar una alerta) — responsabilidad de quien confirma el checkpoint de deploy.
- Entradas de `LECCIONES.md` generadas por hallazgos de QA (recurrentes o por self-healing) siguen la misma regla de poda ya vigente desde `ADR-009` (30 entradas o 12 meses).
- `RIESGOS.md` R-018 se revisa en cada convocatoria del Consejo, mismo ciclo que el resto del registro. Los riesgos candidatos QA-A/B/C se formalizan como entradas numeradas recién cuando sus fases correspondientes se implementen (v3.4.0/v3.5.0) — mismo criterio de "no documentar riesgo de una capacidad que todavía no existe" que ya aplica RIESGOS.md.

## 16. Criterios de éxito

- Evidencia real (reporte HTML + captura) disponible para cada tarea de UI que pasó por el sombrero de QA en un proyecto con `browser-qa-e2e` habilitado — nunca "probablemente funciona" (Principio 8).
- Cero despliegues a producción de un proyecto Nivel 2/3 con UI web sin la quinta condición de `deploy-checklist` cumplida.
- Al menos un proyecto Nivel 2/3 real usando `browser-qa-e2e` de punta a punta antes de dar la v3.3.0 por definitivamente cerrada — mismo criterio que `ROADMAP.md` ya exige para Omega antes de cerrarlo.
- Ninguna propuesta de self-healing aplicada sin confirmación explícita, verificable en `LECCIONES.md` (cada propuesta queda registrada, aceptada o rechazada).
- Ninguna corrida de QA usando credenciales de producción de Firebase/Supabase, verificable contra `STACK.md`/`.env.example` de cada proyecto que lo use.

## 17. Recomendación final

Aprobar como evolución incremental de Cronos, escalonada `3.2.0 → 3.3.0 → 3.4.0 → 3.5.0` (no como salto a "Omega" ni a una versión mayor), manteniendo el agente único de `ADR-007`. Incorporar las Fases 1-3 con diseño real donde el kit hoy solo tenía una mención de una línea. Reducir drásticamente la Fase 4 (self-healing) a "propone, nunca aplica solo". Enrutar la Fase 5 (Knowledge System) hacia `LECCIONES.md` y `technical-governance`, ya existentes, sin crear un sistema nuevo. Descartar la mitad multiagente de la Fase 6 sin reabrir `ADR-007`/`ADR-008`/`ADR-009`, e incorporar su mitad de infraestructura real (CI/CD, GitHub, Firebase, Supabase) como extensión de `deploy-checklist` y `external-integrations`.

**Confirmado por el operador (2026-07-16).** Implementado: v3.3.0 (§14) — `browser-qa-e2e` completa. Fases 2-5 quedan para v3.4.0/v3.5.0, ver `ROADMAP.md`.
