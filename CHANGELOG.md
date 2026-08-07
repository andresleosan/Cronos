# Changelog — Cronos

El kit original (sin número de versión) se trata como línea base `1.0.0`. Hasta la v2.0.1, este archivo documentaba la "Agencia Los Titanes" (10 subagentes + orquestador); desde v3.0.0, documenta "Cronos" (un único agente que le da nombre a todo el kit). El historial de versiones anteriores se conserva sin editar como registro — ver ADR-007 para el porqué del cambio de arquitectura.

## [4.2.0] — 2026-08-06

### Cambiado
- Cronos pasa de prohibir toda delegación a permitir subagentes temporales controlados, sin restaurar Titanes permanentes ni transferir autoridad final.
- Máximo tres subagentes simultáneos y `subagent_depth: 1` para impedir delegación anidada.
- Cada encargo repite reglas de seguridad, pruebas, alcance, secretos, Git, producción, migraciones y gasto.
- OpenCode usa `agent.cronos.permission.task: allow`; se retira el bloque deprecado `agent.tools` de la plantilla.
- Se exige canary de herencia y canary de escritura aislada, ambos revisados y verificados otra vez por Cronos.

### Seguridad y rollback
- Subagentes no leen secretos, no modifican Git, no despliegan, no migran, no generan gasto y no aprueban tareas.
- Rollback verificado desde `C:\Users\USER\AppData\Local\Temp\opencode\cronos-subagents-backup-20260806`.

## [4.1.0] — 2026-08-06

Origen: el operador preguntó si Cronos podía "vivir de manera general y siempre ir mejorando" —
entrar a su carpeta raíz para tomar o crear skills según trabajos nuevos, "autoentrenarse", y
distinguir cuándo algo amerita una capacidad nueva. Antes de construir nada, se aclararon dos
puntos técnicos con el operador (un modelo de IA no cambia sus pesos por nada de lo que pasa en una
sesión; Cronos no persiste entre sesiones, cada una arranca leyendo lo acumulado en archivos) y se
identificó que esto ya se había intentado una vez, bajo el nombre "Skill Forge"
(`docs/PROPUESTA-OMEGA.md`), y fue acotado deliberadamente en `ADR-008`/R-016 a una versión mínima
que solo propone, nunca instala sola. Se le presentaron al operador las opciones concretas de
autonomía (mismo criterio que ya usó `ADR-011`: no decidir esto unilateralmente) y eligió, en las
dos preguntas: (1) detección más proactiva — no solo al cerrar el proyecto — pero manteniendo la
confirmación explícita siempre, y (2) que Cronos note cuándo una skill se repite en 2+ proyectos y
pregunte si corresponde promoverla a global, en vez de que el operador tenga que acordarse.

### Agregado
- **`adr/ADR-012-deteccion-proactiva-promocion-skills.md`** — documenta la extensión, con
  referencia explícita a `ADR-008`/R-016/"Skill Forge" y por qué esto no los reabre: el checkpoint
  de confirmación explícita, en los dos ejes nuevos, no se debilitó en ningún punto — fue elegido
  así por el operador entre alternativas más autónomas que sí se ofrecieron y se descartaron.
- **`.cronos/gaps-detectados.md`** (nuevo por proyecto, creado por `nuevo-proyecto.sh`/
  `adoptar-proyecto.sh`, nunca sincronizado por `actualizar-proyecto.sh` — es estado del proyecto,
  mismo trato que `BRIEF.md`/`tasks.md`) — registro de trabajo de una línea por gap notado, para que
  la detección de "esto se repitió" no dependa solo de la memoria conversacional de una sesión que
  puede cruzar varios días.
- **`scripts/promover-skill.sh`** — copia una skill de `.cronos/skills/` de un proyecto a
  `skills-custom/` del kit fuente y a los directorios globales de OpenCode/Codex CLI que ya
  existan; valida el frontmatter mínimo (`name`, `description`) antes de copiar; deja una fila
  "pendiente de revisión curada" en `SKILLS.md` en vez de fingir que ya pasó por la misma curación
  que las 18 skills originales. No pregunta si corresponde promover — esa confirmación ya tiene que
  haber pasado antes, en la conversación con el operador.

### Cambiado
- **`skills-custom/self-critique-loop/SKILL.md`** — paso 6 nuevo (solo Nivel 2/3, mismo criterio de
  proporcionalidad que ya aplica el resto del loop): chequeo de diez segundos al cerrar cada tarea,
  registra en `gaps-detectados.md` si algo no tuvo cobertura existente.
- **`skills-custom/capability-gap-analysis/SKILL.md`** — se activa apenas `gaps-detectados.md`
  muestra una segunda entrada parecida, no solo al cerrar el proyecto (Paso 7.5 sigue existiendo
  igual, para el resumen final). Antes de proponer, chequea `~/.cronos/LECCIONES.md` por evidencia
  de que el mismo gap ya apareció en un proyecto *distinto* — sin esa evidencia, propone una skill
  **local** a `.cronos/skills/` del proyecto actual; con ella, propone directamente promoción a
  **global**. Los dos caminos piden confirmación explícita por separado — confirmar el local no
  confirma automáticamente una promoción futura.
- **`MASTER_PROMPT.md`** — Paso 0.3 nuevo: lee `~/.cronos/LECCIONES.md` al arrancar cualquier
  proyecto (antes, ese archivo solo se escribía al cerrar, nunca se leía al empezar) — sin este
  paso, el chequeo cross-proyecto de arriba no tendría con qué comparar.
- **`SKILLS.md`** — fila de `capability-gap-analysis` actualizada; sección nueva "Skills
  promovidas, pendientes de revisión curada", con el marcador que usa `promover-skill.sh` para
  agregar filas.
- **`GOBERNANZA.md`** — fila RACI nueva: "Promover skill de proyecto a catálogo global" → Product
  Owner A/R, Arquitecto técnico C — es una decisión de qué capacidades carga la agencia hacia
  adelante, no una de arquitectura pura.
- **`RIESGOS.md`** — R-016 extendido (mitigación central sin cambios: nunca instala ni promueve sin
  confirmación explícita, en cada uno de los dos pasos por separado). R-022 nuevo: una skill
  promovida por uso repetido tiene evidencia de necesidad real, pero no de que su `description` esté
  bien escrita para el catálogo — mitigado dejándola aparte hasta revisión, no mezclada en silencio.
- **`ROADMAP.md`** — sección "ya incluido en v4.1.0"; pendiente nuevo de validar el ciclo completo
  con un caso real (detección → local → repetición → promoción).
- **`VERSION`**, `AGENCY.md`, `GOBERNANZA.md`, `agent.cronos.description`: alineados a `4.1.0`.

### Por qué versión menor y no mayor
Aditiva de punta a punta: ningún comportamiento existente cambia si el operador no interactúa con
lo nuevo, y ninguna promesa de compatibilidad de versiones anteriores se toca. Mismo criterio que ya
separó v3.1.0/v3.2.0/v3.3.0 (capacidad nueva) de v3.0.0/v4.0.0 (cambios de arquitectura que
reabrieron algo previamente cerrado).

## [4.0.2] — 2026-08-05

Origen: el operador corrió el kit en OpenCode y se encontró con `Agent cronos's configured model
opencode/mimo-v2-5-free is not valid` — el string de respaldo de `agent.cronos.model` había dejado
de ser válido en su instalación, y en vez de ignorarse, bloqueaba con un error. Pidió explícitamente
que el kit "no se case con ninguna IA" y trabaje siempre con lo que esté seleccionado a mano.

### Arreglado
- **`adapters/opencode/opencode.template.json`**: se sacan por completo los campos `model` (raíz)
  y `agent.cronos.model` — antes documentados como "solo un respaldo para que el archivo sea JSON
  válido, no una recomendación", pero ese respaldo podía volverse inválido con el tiempo (un modelo
  se retira o cambia de nombre) y OpenCode lo rechaza con error en vez de ignorarlo. Sin el campo,
  OpenCode usa el modelo que ya esté seleccionado manualmente — cero posibilidad de que el kit
  fuerce un valor roto.
- **`adapters/codex/config.toml.template`**: mismo riesgo, mismo arreglo preventivo — `model` y
  `model_provider` pasan a estar comentados (documentados, no borrados) en vez de declarados con un
  valor real, para que Codex CLI use el default de la cuenta en vez de un string que puede quedar
  obsoleto.
- **`scripts/elegir-modelo.sh`**: el reemplazo de `model`/`model_provider` en `.codex/config.toml`
  ahora reconoce tanto la línea activa como la comentada (antes solo buscaba una línea activa, así
  que con el campo comentado el `sed` no encontraba nada y no aplicaba el cambio en silencio) y, si
  ninguna de las dos existe, inserta las líneas nuevas junto al encabezado de la sección Modelo —
  nunca al final del archivo, porque en TOML una clave suelta después de un `[tabla]` pasa a
  pertenecer a esa tabla, no a la raíz, y agregarla mal ahí habría roto la configuración sin avisar.
  Probado con `python3 -m tomllib` después del cambio para confirmar que sigue siendo TOML válido y
  que `model`/`model_provider` quedan en la raíz del archivo.
- **`MODELOS.md`, `adapters/opencode/README.md`**: texto actualizado para reflejar que ya no hay
  ningún valor de respaldo — antes decían "nunca asumas que este string está disponible", ahora
  simplemente no hay ningún string que asumir.
- **`VERSION`**, `AGENCY.md`, `GOBERNANZA.md`, `agent.cronos.description`: alineados a `4.0.2`.

## [4.0.1] — 2026-08-05

Origen: el operador corrió `nuevo-proyecto.sh --dry-run` (sin nombre de proyecto) desde Git Bash en
Windows y el script intentó crear una carpeta real en `/s/Respaldo/Proyectos` — una ruta de un
disco que ya no usa (cambió de `S:\Respaldo\Proyectos` a una organización nueva bajo `F:\`), y que
además nunca debió tratarse como fija: era una personalización de una sesión anterior que quedó
hardcodeada en el script en vez de vivir en la configuración del operador.

### Arreglado
- **`scripts/nuevo-proyecto.sh`**: `BASE_DIR` deja de ser una ruta fija (`/s/Respaldo/Proyectos`)
  y pasa a ser configurable: por defecto usa la carpeta actual (`pwd`, mismo criterio que ya usan
  `adoptar-proyecto.sh`/`actualizar-proyecto.sh`), y admite fijarse a una ruta propia con la
  variable de entorno `CRONOS_PROYECTOS_DIR` (documentado en el propio script). Elimina la
  dependencia de una ruta personal que se vuelve obsoleta apenas el operador reorganiza sus discos.
- **`scripts/nuevo-proyecto.sh`**: `--dry-run` (o cualquier otra opción) ya no se acepta
  silenciosamente como si fuera el nombre del proyecto cuando falta el argumento posicional — ahora
  valida que el primer argumento no empiece con `--` y, si falla, muestra el uso correcto más un
  aviso explícito de cuál fue el problema, en vez de intentar crear un proyecto real llamado
  `--dry-run`.
- **`VERSION`**, `AGENCY.md`, `GOBERNANZA.md`, `agent.cronos.description` de
  `adapters/opencode/opencode.template.json`: alineados a `4.0.1`.

### Nota de alcance
`adoptar-proyecto.sh` y `actualizar-proyecto.sh` no tenían este problema — ya operaban sobre la
carpeta actual (`pwd`), no sobre una ruta fija — así que no necesitaron el mismo cambio.

## [4.0.0] — 2026-08-03

Origen: pedido directo del operador — modificar el kit para que funcione en OpenCode, Codex
CLI y VS Code, con énfasis explícito en que la selección de modelo no quedara restringida a
ninguna plataforma en particular. A diferencia de los tres pedidos anteriores que tocaban
este mismo tema (`ADR-008`, `ADR-009`, `ADR-010` — todos externos, especulativos, empaquetados
junto con multiagente/consejo simulado, y descartados sin reabrir `ADR-007`), este vino del
operador que mantiene y usa el kit, con necesidad real ya evidenciada: existe un fork paralelo
(`TitanesLiteCodex`) construido aparte específicamente para Codex CLI, porque este kit no lo
cubría — la misma clase de duplicidad que `RIESGOS.md` ya trata como riesgo cuando aparece
dentro de un proyecto. Investigación previa a cualquier cambio: estado actual (2026-08-03) de
`opencode.json`, `.codex/config.toml` y la configuración de GitHub Copilot en VS Code
(`AGENTS.md`, `.github/copilot-instructions.md`, `.vscode/mcp.json`, selector de modelos con
BYOK), confirmando además que `AGENTS.md` y el formato `SKILL.md` se consolidaron como
estándares abiertos multiplataforma desde que se escribió `ADR-005` (julio 2026) — lo que en
ese momento exigía un adaptador pesado por plataforma hoy exige uno mucho más delgado.

### Agregado
- **`adr/ADR-011-multiplataforma-opencode-codex-vscode.md`** — reabre parcialmente `ADR-007`
  (solo el punto 3, exclusividad de OpenCode; el punto 1, agente único, no se toca). Incluye
  la comparación explícita con los tres pedidos anteriores que este mismo criterio rechazó, y
  las alternativas consideradas que exige `GOBERNANZA.md` para un ADR de este impacto.
- **`AGENTS.md`** (raíz del kit y de cada proyecto generado) — punto de entrada universal,
  leído de forma nativa por las 3 plataformas (confirmado por documentación, no solo
  diseñado). Incluye las reglas de oro condensadas inline como defensa en profundidad, mismo
  criterio que `ADR-003` ya aplicó en su momento a un problema equivalente.
- **`adapters/`** (vuelve a existir, ver `ADR-011`) — exactamente 3 subcarpetas, no una lista
  abierta: `opencode/` (`opencode.template.json`, movido desde la raíz sin cambios de
  mecánica), `codex/` (`config.toml.template`, nuevo), `vscode/`
  (`copilot-instructions.template.md` + `mcp.template.json`, nuevos). Cada uno con su propio
  `README.md` marcando honestamente qué está verificado empíricamente (solo OpenCode) y qué
  solo contra documentación pública (Codex CLI, VS Code).
- **`scripts/_lib-cronos.sh`** — funciones compartidas entre `nuevo-proyecto.sh`,
  `adoptar-proyecto.sh` y `actualizar-proyecto.sh`, para que la lógica de qué se copia y desde
  dónde no diverja entre los tres con el tiempo.
- **`~/.cronos/LECCIONES.md`** — nuevo home neutral de plataforma para la memoria evolutiva,
  compartido entre las 3 en vez de vivir solo dentro de la instalación global de OpenCode.
- **`.cronos/` por proyecto** — copia local sincronizable del núcleo (`AGENCY.md`,
  `MASTER_PROMPT.md`, `SKILLS.md`, `MODELOS.md`, `LOOPS.md`, `skills/`), necesaria porque VS
  Code/Copilot no tiene mecanismo global scripteable como sí tienen OpenCode y Codex CLI.
  Modifica el Principio 6 de `AGENCY.md`, con la excepción documentada ahí mismo.
- **`RIESGOS.md`** — R-019 (adaptadores de Codex CLI/VS Code sin verificación empírica),
  R-020 (deriva de `.cronos/` si no se corre `actualizar-proyecto.sh`), R-021 (VS Code sin
  respaldo global) — los tres marcados `abierto`, no aspiracionalmente resueltos.
- **`GUIA-PARA-PRINCIPIANTES.md`** — secciones nuevas "Si preferís Codex CLI" y "Si preferís
  VS Code", reutilizando los pasos compartidos con la ruta de OpenCode ya existente.
- **`scripts/verificar-kit.sh`** — chequeo 7/7 nuevo (estructura de `adapters/` completa) y
  validación TOML (antes solo JSON) en el chequeo 1/7.

### Cambiado
- **`AGENCY.md`** — "Versión y compatibilidad" deja de decir "uso exclusivo de OpenCode";
  Principio 6 gana la excepción de `.cronos/`; Principios 10/11 generalizados a las 3
  plataformas; tabla de "Componentes globales" reescrita con columna de plataforma explícita;
  diagrama de "Estructura de un proyecto generado" actualizado con `AGENTS.md`/`.cronos/`/los
  3 archivos de configuración posibles.
- **`MASTER_PROMPT.md`** — Paso 0 gana detección de plataforma (0.1), fusionada con la
  detección de situación que ya existía (0.2) — un solo paso, no dos, aprendiendo de la
  crítica que `ADR-006` ya se había hecho a sí mismo. Pasos A3/B3 ramifican la recomendación y
  escritura de modelo por plataforma. A3.1/B3.1 (Capa 2 de `LOOPS.md`) quedan acotados a
  "solo OpenCode" explícitamente en vez de asumirlo. B1 actualizado: `/init` ya no es
  exclusivo de OpenCode.
- **`MODELOS.md`** — Paso 1 (descubrimiento) ramificado en 3 subsecciones por plataforma; Paso
  2 (criterio por fase) y Paso 3 (recomendar, no decidir solo) sin cambios de fondo, ya eran
  agnósticos desde `ADR-002`. Nota de alcance agregada al apartado de plugins de fallback:
  investigación específica de OpenCode, no extendida a las otras dos en esta ronda.
- **`scripts/elegir-modelo.sh`** — reescrito para detectar qué configuración de plataforma
  existe en el proyecto (pregunta si hay más de una) y operar sobre la que corresponda. La
  rama de OpenCode mantiene exactamente la misma lógica de antes (`jq`); la rama nueva de
  Codex CLI edita `.codex/config.toml` con reemplazo de línea (no parseo TOML completo,
  documentado como tal) y backup con timestamp, igual que ya hacía la rama de OpenCode. Ningún
  valor de modelo se valida contra una lista — confirmado con prueba funcional real (strings
  de modelo inventados, aceptados sin objeción en ambas plataformas), no solo por lectura del
  código.
- **`scripts/nuevo-proyecto.sh`, `adoptar-proyecto.sh`, `actualizar-proyecto.sh`** —
  reescritos sobre `_lib-cronos.sh`; ganan `--solo <plataforma>` (por defecto configuran las
  3); ya no requieren que `instalar-global.sh` se haya corrido antes (el núcleo se copia
  directo desde el kit fuente a `.cronos/`), aunque se sigue recomendando para la capa extra
  de defensa en profundidad en OpenCode/Codex CLI.
- **`scripts/instalar-global.sh`** — instala también en `~/.codex/` (antes, solo
  `~/.config/opencode/`); crea `~/.cronos/LECCIONES.md`; genera un `AGENTS.md` global nuevo
  para ambas plataformas (en OpenCode, refuerzo de un mecanismo ya verificado; en Codex CLI,
  mecanismo principal, ya que no tiene un array `instructions` propio). Admite `--solo
  opencode|codex`.
- **`opencode.template.json`** → movido a `adapters/opencode/opencode.template.json` (sin
  cambios de mecánica); `agent.cronos.description` actualizado a "Cronos 4.0.0".
- **`README.md`** — reescrito: quita "Solo OpenCode", agrega instrucciones de instalación y
  uso para las 3 plataformas en cada sección, "Estructura de este kit" actualizada con
  `AGENTS.md`/`adapters/`/`_lib-cronos.sh`, "Verificación recomendada" separa lo verificado
  contra sesión real (OpenCode) de lo verificado solo por documentación (Codex CLI, VS Code).
- **`SKILLS.md`** — aclara que el formato `SKILL.md` es un estándar abierto multiplataforma,
  no una convención de OpenCode; nota sobre soporte más nuevo/menos maduro en VS Code/Copilot.
- **`LOOPS.md`** — nota de alcance nueva al final: el contenido detallado (Capa 1/Capa 2) es
  investigación específica de OpenCode; para Codex CLI/VS Code se documenta mecánica general
  sin el mismo nivel de verificación, y el checkpoint de Capa 2 no se ofrece ahí todavía.
- **`skills-custom/security-baseline/SKILL.md`** — "Protecciones que ya da OpenCode" pasa a
  "Protecciones que ya da la plataforma", separando qué está confirmado para OpenCode de qué
  no se confirmó (todavía) para Codex CLI/VS Code — evita que el checklist mínimo asuma una
  red de seguridad que esas dos plataformas no tienen confirmada.
- **`STACK.example.md`, `LECCIONES.example.md`, `AUDITORIA.example.md`** — referencias a
  versión/ruta de OpenCode generalizadas a las 3 plataformas donde correspondía.
- **`RIESGOS.md`** — R-008 reabierto (mitigación nueva, no cerrado por decisión unilateral);
  R-009 referenciado como lección reaplicada en el diseño de `ADR-011`, sin reabrirse.
- **`ROADMAP.md`** — "Adaptadores multiplataforma" sale de "Descartado / fuera de alcance"
  (histórico preservado, tachado y anotado) y pasa a "ya incluido en v4.0.0"; nuevos pendientes
  de verificación empírica para Codex CLI/VS Code.
- **`GOBERNANZA.md`** — "Estado real hoy" actualizado; nota sobre bajo qué sombrero se tomó la
  decisión de `ADR-011` (Arquitecto técnico, mismo proceso que ya cubría esto).
- **`adr/README.md`** — fila nueva para 011; notas de continuidad agregadas a 004/005/006/007
  para que la tabla siga siendo honesta sobre qué se reabrió y qué no.
- **`VERSION`**: `3.4.0` → `4.0.0`.

### Corregido (encontrado durante esta misma auditoría, no eran bugs nuevos introducidos)
- **`README.md`** tenía un resto de voseo preexistente ("querés" → "quieres") en la sección de
  `adoptar-proyecto.sh`, sin relación con el trabajo de esta versión — no detectado por
  ninguna corrida anterior de `scripts/verificar-kit.sh` porque esa línea específica no había
  cambiado desde antes del fix de locale/mayúsculas de v3.3.3. Corregido al pasar.

### Nota de alcance — qué NO se verificó empíricamente en esta versión
Los adaptadores de Codex CLI y VS Code se verificaron contra documentación pública vigente al
2026-08-03 (fuentes citadas en cada `README.md` de adaptador), no contra una sesión real con
credenciales de modelo — mismo criterio de honestidad que `LOOPS.md` ya venía aplicando al
ecosistema de plugins de OpenCode desde v1.5.0, extendido ahora a mecánica de la que depende
la propagación de las reglas de oro (no solo a un plugin opcional). Queda como pendiente
explícito en `ROADMAP.md` (R-019) correr el equivalente de la auditoría que sí se le hizo a
OpenCode (`docs/AUDITORIA-10-10-verificacion-R002.md`) contra sesiones reales de las otras dos
plataformas antes de apoyarse en ellas para un proyecto Nivel 3.

### Por qué versión mayor y no menor
A diferencia de v3.1.0/v3.2.0/v3.3.0/v3.4.0 (todas aditivas: capacidad nueva sin romper ni
recomprometer nada de lo existente), esta versión cambia una promesa de compatibilidad que el
kit venía sosteniendo activamente desde v3.0.0 ("Solo OpenCode", declarada en `README.md`,
`AGENCY.md` y `MASTER_PROMPT.md`) y reestructura la ubicación de un archivo que scripts y
documentación referenciaban por ruta fija (`opencode.template.json`). Mismo criterio que ya
justificó el salto a v3.0.0 en su momento (`ADR-007`): un cambio de arquitectura que reabre
una decisión previamente cerrada, no una extensión aditiva sobre lo que ya había.

## [3.4.0] — 2026-07-31

Origen: pedido del operador — Flujo B (proyecto existente/externo) no tenía un script propio
para la parte mecánica de B3, a diferencia del Flujo A (`nuevo-proyecto.sh`) y de las
actualizaciones de core (`actualizar-proyecto.sh`). Cronos venía copiando `opencode.json`
a mano dentro de la sesión, sin backup ni `--dry-run`.

### Agregado
- **`scripts/adoptar-proyecto.sh`** (nuevo): engancha al core un proyecto que ya tiene
  código pero nunca fue creado con la agencia. Corre desde dentro del proyecto, después del
  checkpoint B2.1 (`MEJORAS.md` ya confirmado). Copia `opencode.json` y `.gitignore` desde
  el template del core **solo si el proyecto todavía no tiene los suyos** — a diferencia de
  `actualizar-proyecto.sh`, nunca pisa uno ya existente, porque en Flujo B ese archivo puede
  no tener nada que ver con Cronos. Crea `.agencia-version` para que `actualizar-proyecto.sh`
  funcione en el proyecto de ahí en adelante. Se niega a correr si `.agencia-version` ya
  existe (evita "readoptar" un proyecto ya enganchado; dirige a `actualizar-proyecto.sh` en
  ese caso). No toca `BRIEF.md`, `STACK.md`, `tasks.md`, `AUDITORIA.md` ni `MEJORAS.md` — esos
  siguen siendo obra de Cronos en sesión, nunca de un script. Admite `--dry-run`.
- `README.md` (sección 3) y `MASTER_PROMPT.md` (paso B3) actualizados para referenciar el
  script en vez de la instrucción manual de copia.

### Por qué versión menor y no parche
Agrega comportamiento nuevo real (un script nuevo, una skill mecánica que antes no existía)
sin romper nada del core existente ni cambiar el comportamiento de `nuevo-proyecto.sh` o
`actualizar-proyecto.sh` — mismo criterio que `ADR-010` ya aplicó a `browser-qa-e2e` en
v3.3.0: aditivo y sustancial, no un bugfix.

## [3.3.3] — 2026-07-18

Origen: auditoría externa sobre el kit empaquetado v3.3.2, pedida para llegar a 10/10. Lo
que empezó como un solo bug reportado (falso positivo en el chequeo de voseo) escaló, al
corregirlo, a un segundo bug del mismo chequeo y a voseo real que ambos bugs habían estado
ocultando desde antes de v3.3.2 — no introducido por esta versión, sino nunca detectado.

### Arreglado — dos bugs en `scripts/verificar-kit.sh`, chequeo 2/6 (voseo)
1. **Falso positivo por locale.** Bajo locale C/POSIX (la que trae este contenedor por
   defecto), `grep` trataba cada vocal acentuada como bytes no-palabra, así que `\b` veía
   un límite de palabra falso entre la vocal y la letra siguiente. Efecto: `pedí\b`
   matcheaba dentro de "pedía" (imperfecto de "pedir", no voseo), marcando `FALLO` sin que
   hubiera voseo real en `adr/ADR-010-...md` y `docs/PROPUESTA-QA-BROWSER-INTELLIGENCE.md`.
2. **Falso negativo por mayúsculas.** El mismo chequeo corría sin `-i`, así que el voseo al
   inicio de una oración o de un ítem de lista ("Anotá...", "Definí...", "Revisá...") nunca
   se detectaba, sin importar la locale — la mayúscula inicial no matcheaba contra la lista
   en minúscula. Este bug es más serio que el primero: no generaba falsos `FALLO` molestos,
   generaba falsos `OK` — el chequeo decía "sin voseo" mientras había voseo real sin marcar.

Fix de ambos: el chequeo ahora fuerza una locale UTF-8 real (`C.UTF-8`/`en_US.UTF-8`, la
primera disponible, con aviso si no hay ninguna) y corre con `-i`.

### Arreglado — voseo real encontrado gracias al fix del punto 2
El bug de mayúsculas llevó a auditar el kit entero a mano (no solo confiar en que el
chequeo, ya arreglado, diera `OK`), porque un chequeo que recién empieza a ver bien no
garantiza que ya vio todo — su propia lista de formas sigue siendo manual y fija (ver nota
de alcance más abajo). Se encontraron y corrigieron a tuteo 14 restos de voseo reales en 7
archivos, presentes desde antes de v3.3.2 y nunca detectados por ninguna versión anterior
de este chequeo: `MASTER_PROMPT.md` (4: "esperá"→"espera", "seguí"→"sigue" ×2,
"registrá"→"registra", "preguntame"→"pregúntame"), `LOOPS.md` (4: "confirmalo"→"confírmalo",
"confirmá"→"confirma", "seguí"→"sigue" en un ejemplo entre comillas, "escribí"→"escribe",
"terminá"→"termina" en otro ejemplo entre comillas), `docs/AUDITORIA-10-10-verificacion-R002.md`
(2: "Anotá"→"Anota", "pegá"→"pega"), `README.md` (1: "Correlo"→"Córrelo"),
`GUIA-PARA-PRINCIPIANTES.md` (1: "Confirmame"→"Confírmame"), y
`skills-custom/frontend-craft/SKILL.md` (2: "Definí"→"Define", "generá"→"genera",
"aplicá"→"aplica"). La lista de formas del chequeo se amplió con las palabras que faltaban
(`esperá`, `registrá`, `terminá`, `generá`, `aplicá`, `anotá`, `definí`, `correlo`,
`confirmame`, `confirmalo`, `preguntame`) para que esta clase específica de miss no se
repita. Se descartó agregar `repetí` a la lista pese a aparecer una vez en
`docs/PROPUESTA-OMEGA.md`: ahí es primera persona ("¿Qué repetí?", "qué repetí yo"), no
voseo — agregarlo habría creado un falso positivo nuevo.

### Cambiado
- `opencode.template.json`: `agent.cronos.description` pasa de `"Cronos 3.3 — ..."` a
  `"Cronos 3.3.3 — ..."` (patch completo, no solo mayor.menor). **Esto revierte a propósito
  la decisión de v3.3.2**, que fijó mayor.menor específicamente para que un bump de patch no
  desalineara el campo. Pedido explícito del operador: quiere ver el patch exacto reflejado
  dentro de OpenCode, no una versión redondeada. Costo aceptado a cambio: de ahora en más,
  cada bump de versión —incluidos los de patch— debe tocar también este campo.
- `scripts/verificar-kit.sh`, chequeo 6/6: en consecuencia, deja de comparar contra
  mayor.menor y ahora exige coincidencia exacta con `VERSION` (patch incluido). Si un bump
  de patch futuro olvida actualizar `agent.cronos.description`, este chequeo lo marca como
  `FALLO` — la misma protección automática que ya existía para `AGENCY.md`/`GOBERNANZA.md`,
  ahora extendida a nivel de patch en vez de mayor.menor.

### Nota de alcance — límite real de este chequeo, no resuelto acá
El chequeo 2/6 sigue siendo una lista fija de formas conocidas, no un detector general de
voseo. Esta versión corrigió los dos bugs mecánicos que le impedían aplicar bien esa lista
(locale y mayúsculas) y amplió la lista con lo que se encontró — pero cualquier forma de
voseo real que no esté en la lista (otro verbo, otra conjugación) sigue sin poder
detectarse. "Pasa el chequeo 2/6" significa "no tiene ninguna de las ~50 formas listadas",
no "no tiene voseo". No genera ADR (mismo criterio que v3.3.1/v3.3.2: texto/config y
chequeo del propio verificador, no arquitectura ni comportamiento del agente — ver
`adr/README.md`), pero si en algún momento se decide invertir en un detector genérico
(morfológico o basado en modelo, no lista fija), eso sí sería candidato a ADR por el
cambio de enfoque que implicaría.

## [3.3.2] — 2026-07-18

Pedido explícito: que la versión del kit se vea dentro de OpenCode, no solo en `VERSION`/`CHANGELOG.md`.

### Cambiado
- `opencode.template.json`: `agent.cronos.description` pasa de `"Cronos — agente único: ..."`
  a `"Cronos 3.3 — agente único: ..."` — mayor.menor solamente (sin patch), para que un bump de
  patch (3.3.1 → 3.3.2, este mismo cambio) no lo desalinee; solo un bump de menor o mayor lo hace.
  La clave técnica del agente (`agent.cronos`, el identificador que usan `opencode debug agent
  cronos`, `scripts/elegir-modelo.sh` y el resto de la documentación de verificación) **no cambia**
  — llevar el número de versión al identificador técnico rompería esos scripts y la evidencia ya
  documentada en `docs/AUDITORIA-10-10-verificacion-R002.md`, y habría que repetir el rename en
  cada bump de versión futuro. El número de versión vive en el campo pensado para eso
  (`description`), no en la clave.
- `scripts/verificar-kit.sh`: el chequeo 6/6 (versión en prosa alineada con `VERSION`) se extiende
  para cubrir también `agent.cronos.description` de `opencode.template.json` — mismo tipo de
  desalineo silencioso que ya causó que `AGENCY.md` quedara en `3.1.0` después del bump a `3.2.0`
  (auditoría 10/10, 2026-07-16), ahora prevenido también para este campo.

### Nota de alcance
No genera ADR — cambio de texto/config, no de arquitectura ni de comportamiento (ver `adr/README.md`).

## [3.3.1] — 2026-07-17

Pedido explícito: que ningún documento del kit mencione el nombre de quien lo usa hoy, para
que el kit funcione como un proyecto universal, usable por cualquier persona sin adaptar texto
a mano primero. Es un cambio de texto, no de arquitectura ni de comportamiento — no genera ADR
(no es una decisión costosa de revertir, ver `adr/README.md`).

### Cambiado
- Todas las menciones al nombre propio del operador actual, en los ~25 archivos donde aparecía
  (`AGENCY.md`, `MASTER_PROMPT.md`, `GOBERNANZA.md`, `LOOPS.md`, `MODELOS.md`, `RIESGOS.md`,
  `SKILLS.md`, `CHANGELOG.md` (historial incluido), `adr/ADR-008` a `ADR-010`, `docs/PROPUESTA-*`,
  `commands/*`, y varias `skills-custom/*/SKILL.md`), pasan a **"el operador"** — el mismo término
  genérico que el kit ya usaba en algunos puntos (`AGENCY.md`, Principio 11: "quien lo use").
- Diagrama Mermaid de `AGENCY.md`: el nodo que usaba como identificador interno el nombre propio
  de quien operaba la agencia en ese momento pasa a `Operador` (el identificador interno del nodo,
  no solo la etiqueta visible, para que el nombre no quede ni en el código fuente del diagrama).
- `GOBERNANZA.md`: la tabla de sombreros sigue mostrando que hoy los cuatro roles los ejerce una
  sola persona — ahora sin nombrarla.

### Nota de alcance
No se tocó el nombre de la agencia ("Cronos"), ni los nombres de los Titanes históricos citados
como referencia (Atlas, Prometeo, Hefesto, etc. — ya no son agentes desde `ADR-007`, quedan solo
como equivalencia histórica en tablas), ni ningún otro dato del proyecto — el pedido fue
específicamente sobre el nombre propio de una persona, no una re-anonimización general del kit.

## [3.3.0] — 2026-07-16

Audita un cuarto pedido externo ("CRONOS OMEGA — EVOLUCIÓN AUTONOMOUS QA + BROWSER INTELLIGENCE"),
que pedía un módulo Playwright, un módulo "Browser Use", QA visual, self-healing tests, un sistema
de conocimiento propio, e integración explícita con "Cronos, Atlas, Hefesto, Prometeo" (Fase 6) —
cuarta vez que llega el framing multiagente ya rechazado en `ADR-007`/`ADR-008`/`ADR-009`, bajo un
nombre distinto. A diferencia de los dos pedidos anteriores (Omega, V4.0 Enterprise), este sí
señalaba un hueco técnico real en las Fases 1-3: Cronos ya mencionaba Playwright MCP en tres
archivos del kit (`AGENCY.md`, `opencode.template.json`, `advanced-qa-strategy`) sin que ninguno
especificara cómo se usa. Ver `docs/PROPUESTA-QA-BROWSER-INTELLIGENCE.md` para el diagnóstico
fase por fase y `adr/ADR-010-qa-browser-intelligence-sin-multiagente.md` para la decisión completa.
Por tener comportamiento nuevo real y no trivial, la incorporación se escalona en tres versiones
menores en vez de un solo salto: esta entrega solo la Fase 1 (funcional). Fases 2-3 (exploración
autónoma acotada, QA visual) quedan para v3.4.0; Fase 4 reducida (self-healing que propone, nunca
aplica solo) y la mitad de infraestructura de la Fase 6 quedan para v3.5.0 — ver `ROADMAP.md`.

### Agregado
- `skills-custom/browser-qa-e2e/` — skill nueva: pruebas E2E reales con Playwright MCP (login
  automático, navegación entre módulos, CRUD, validación de formularios, verificación de tablas,
  captura de errores con pantallazo, reporte HTML). Se activa en Nivel 2/3 con UI web, cuando
  `STACK.md` declara Playwright MCP habilitado. `SKILLS.md` pasa de 17 a 18 skills documentadas.
- `adr/ADR-010-qa-browser-intelligence-sin-multiagente.md` — decisión central de esta versión.
- `docs/PROPUESTA-QA-BROWSER-INTELLIGENCE.md` — diagnóstico fase por fase que originó ADR-010.
- `RIESGOS.md` R-018 (`browser-qa-e2e` habilitado sin proporcionalidad al nivel del proyecto),
  nuevo. Otros tres riesgos candidatos (self-healing, credenciales de entorno de prueba, falsos
  positivos de QA visual) quedan documentados sin numerar en `docs/PROPUESTA-QA-BROWSER-INTELLIGENCE.md`
  §11, a darse de alta como entradas `R-XXX` reales recién junto con las fases que los originan
  (v3.4.0/v3.5.0) — no antes, para que ninguna referencia a `R-XXX` en el kit quede sin la entrada
  real detrás (ver `scripts/verificar-kit.sh`, chequeo 5/6).

### Cambiado
- `skills-custom/deploy-checklist/SKILL.md`: quinta condición no negociable de despliegue —
  evidencia de `browser-qa-e2e` si el proyecto tiene UI web y es Nivel 2/3.
- `STACK.example.md`: sección Testing renombrada a `## Testing (\`browser-qa-e2e\`, si el proyecto
  tiene UI web y es Nivel 2/3)`, con 2 campos nuevos (ubicación de la suite, última corrida).
- `gitignore.template`: agrega `qa/reports/`, `playwright-report/`, `test-results/` (los reportes
  se regeneran en cada corrida; `qa/tests/` y `qa/baselines/` sí se versionan cuando existan).
- `adr/README.md`: agrega la fila de ADR-010.
- `ROADMAP.md`: cierra el pedido "Autonomous QA & Browser Intelligence" con referencia a
  `ADR-010`; documenta en "Descartado" el framework de navegador separado ("Browser Use"), el
  sistema de conocimiento nuevo, el self-healing con auto-aplicación, y la mitad multiagente de la
  Fase 6 — mismo patrón que ya usaron `ADR-008`/`ADR-009` para sus respectivos pedidos.

### No incorporado todavía (programado, ver `ROADMAP.md` v3.4.0/v3.5.0)
- Exploración autónoma guiada por objetivo (Fase 2, acotada) y QA visual con baselines (Fase 3) —
  extensión de `advanced-qa-strategy`.
- Self-healing reducido ("propone, nunca aplica solo") — extensión de `browser-qa-e2e`.
- Credenciales de entorno de prueba para Firebase/Supabase — extensión formal de
  `external-integrations` (el principio ya vive, sin formalizar, en `browser-qa-e2e/SKILL.md`).
- Ejecución de la suite desde CI/CD real — pendiente de "largo plazo" en `ROADMAP.md`, ahora con
  alcance ampliado explícito (kit + proyecto, no solo `scripts/verificar-kit.sh`).

### Descartado sin ambigüedad (ver ADR-010 para el razonamiento completo)
- Fase 6 del pedido, mitad multiagente ("Atlas", "Hefesto", "Prometeo" como agentes de
  integración) — no se reabre `ADR-007`.
- Fase 5 del pedido (Knowledge System con ADRs/checklist autogenerados) — ya cubierto por
  `LECCIONES.md` + `technical-governance`.
- Framework de navegador "Browser Use" como herramienta separada de Playwright MCP.
- Self-healing con auto-aplicación (sin gate humano) tal como estaba escrito en el pedido original.

## [3.2.0] — 2026-07-15

Audita un segundo pedido externo ("MASTER TASK — LOS TITANES ENTERPRISE V4.0"), llegado un día
después de Omega, que proponía Strategic Council (6 consejos), Titan Core, PMO Empresarial,
registros de modelos y skills con ciclo de vida formal, Knowledge Graph, y una capa
multiplataforma para OpenCode/Claude Code/Codex CLI/Roo Code/Cursor. 9 de 12 fases pedidas se
descartan por ya estar cubiertas o por contradecir `ADR-007`/`ADR-008` — ver
`docs/PROPUESTA-V4-ENTERPRISE.md` para el mapeo fase por fase. 3 debilidades reales se
incorporan, ninguna relacionada con el framing multiagente/enterprise del pedido. Ver
`adr/ADR-009-v4-enterprise-sin-reabrir-diseno.md` para la decisión completa.

### Agregado
- `adr/ADR-009-v4-enterprise-sin-reabrir-diseno.md` — decisión central de esta versión.
- `docs/PROPUESTA-V4-ENTERPRISE.md` — diagnóstico fase por fase que originó ADR-009.
- `LECCIONES.example.md` — 4 categorías nuevas (patrón/antipatrón/incidente/playbook) y sección
  "Cómo se poda" con regla concreta de partición por año (30 entradas o 12 meses).
- `GOBERNANZA.md` — sección "Métricas mínimas" y 4º disparador cuantitativo de convocatoria del
  Consejo (los 3 anteriores eran todos cualitativos).

### Cambiado
- `RIESGOS.md` R-017: `aceptado` → `mitigado`, con regla de poda concreta en vez de "revisar en
  cada convocatoria".
- `ROADMAP.md`: cierra el pedido "V4.0 Enterprise" con referencia a `ADR-009`; documenta en
  "Descartado" el PMO, el Knowledge Graph, y la segunda reafirmación de ADR-007 (multiagente y
  multiplataforma).
- `adr/README.md`: agrega las filas de ADR-008 y ADR-009, que faltaban desde v3.1.0. Se pidió un
  `ADR_INDEX.md` nuevo como mejora complementaria; se descartó por duplicar un índice que ya
  existía — mismo criterio aplicado al resto del pedido V4.0.

### No incorporado (ver ADR-009 para el razonamiento completo)
- Strategic Council / Titan Core / PMO Empresarial / MODEL_REGISTRY.md / SKILL_REGISTRY.md con
  ciclo de vida formal / Knowledge Graph / capa multiplataforma — los 9 puntos restantes del
  Master Task V4.0, descartados sin ambigüedad.

## [3.1.0] — 2026-07-15

Cronos Omega: incorpora 3 capacidades nuevas (benchmark de diseño, memoria evolutiva entre
proyectos, seguimiento de costo) a partir de auditar un pedido externo ("Master Task — Cronos
Omega V5 Ultimate") que proponía volver a una arquitectura multiagente. Se mantiene el agente
único de v3.0.0 — ADR-007 no se reabre. Ver `adr/ADR-008-omega-capacidades-sin-multiagente.md`
para la decisión completa y `docs/PROPUESTA-OMEGA.md` para el diagnóstico que la originó.

### Agregado
- `skills-custom/design-benchmark/` — recolecta referencias visuales reales antes de que
  `frontend-craft` empiece a construir; produce un Design DNA para `STACK.md`.
- `skills-custom/cost-intelligence/` — estima el costo mensual de servicios de pago antes de
  integrarlos; señala si falta alerta de facturación configurada.
- `skills-custom/capability-gap-analysis/` — corre al cerrar un proyecto Nivel 2/3; registra
  lecciones en `LECCIONES.md` y propone (nunca instala sola) skills nuevas ante un gap real y
  recurrente.
- `LECCIONES.md` / `LECCIONES.example.md` — memoria evolutiva entre proyectos, nuevo componente
  global (no destructivo en reinstalaciones, ver `scripts/instalar-global.sh`).
- `adr/ADR-008-omega-capacidades-sin-multiagente.md` — decisión central de esta versión.
- `docs/PROPUESTA-OMEGA.md` — diagnóstico y diseño que originó ADR-008.
- `RIESGOS.md` R-016 (Skill Forge sin curaduría) y R-017 (`LECCIONES.md` sin límite de tamaño),
  ambos nuevos.
- `GOBERNANZA.md`, sección "Alternativas consideradas en decisiones de impacto" — formaliza como
  regla lo que ya era práctica de facto desde ADR-001; resuelve el pedido de "Titan Council" sin
  crear un mecanismo de opiniones simuladas.

### Cambiado
- `SKILLS.md`: 14 → 17 skills documentadas.
- `MASTER_PROMPT.md`: paso A2.2/B3 nuevo (benchmark de diseño), 7.2 referencia `cost-intelligence`
  al integrar servicios de pago, paso 7.5 nuevo (cierre de proyecto: `capability-gap-analysis` +
  `LECCIONES.md`).
- `AGENCY.md`: `LECCIONES.md` agregado a la tabla de componentes globales; punto 10 nuevo en
  Responsabilidades de Cronos; línea de versión actualizada.
- `STACK.example.md`: secciones nuevas "Identidad visual" y "Costo".
- `AUDITORIA.example.md`: sección nueva "Costo"; ampliación de deuda técnica.
- `scripts/instalar-global.sh`: paso no destructivo que crea `LECCIONES.md` solo si no existe ya.
- `ROADMAP.md`: reafirma que volver a multiagente sigue fuera de alcance (ver ADR-008); ítems de
  v3.1.0 movidos a "ya incluido".
- `VERSION`: `3.0.0` → `3.1.0`.

### Eliminado
- Nada. v3.1.0 es puramente aditivo — ningún archivo ni capacidad de v3.0.0 se eliminó (ver
  ADR-008, sección "Consecuencias").

## [3.0.0] — 2026-07-14

Consolidación completa: de 10 subagentes especializados + 1 orquestador a un único agente (Cronos)
que absorbe las 10 especialidades como fases de un mismo ciclo de trabajo, con un ciclo de
autocrítica explícito (`self-critique-loop`) en vez de auditoría cruzada entre agentes separados.
Renombre de la agencia a "Cronos". Uso exclusivo de OpenCode. Ver
`adr/ADR-007-consolidacion-agente-unico.md` para el detalle completo de la decisión.

### Agregado
- `SKILLS.md` — catálogo curado de las 14 skills del kit (7 nuevas + 7 heredadas), con criterio de
  cuándo se activa cada una y qué reemplaza de la arquitectura anterior.
- 7 skills nuevas en `skills-custom/`, cada una concentrando la disciplina que antes vivía embebida
  en la plantilla de un Titán específico: `self-critique-loop`, `security-baseline`,
  `backend-patterns`, `database-design`, `performance-baseline`, `deploy-checklist`,
  `external-integrations`.
- `adr/ADR-007-consolidacion-agente-unico.md` — decisión central de esta versión.
- `RIESGOS.md` R-015 (nuevo): autoauditoría sin segunda mirada independiente — trade-off consciente
  de la consolidación a agente único, con su mitigación documentada en `MODELOS.md`.
- `AGENCY.md`, sección "El ciclo de autocrítica" — el mecanismo central que reemplaza la
  coordinación entre Titanes separados.
- `MASTER_PROMPT.md`, paso 7.1 — recomendación de modelo al iniciar cada fase de trabajo, con
  recordatorio de cambio si el modelo activo dejó de ser el más adecuado.

### Cambiado
- `AGENCY.md` y `MASTER_PROMPT.md` reescritos de punta a punta para un único agente `mode: primary`
  en vez de un orquestador + 10 subagentes.
- `opencode.template.json`: una sola entrada `agent.cronos`, con todos los patrones de
  `permission.bash` que antes estaban repartidos entre Tetis (`*migrate*`), Crío (patrones
  anti-secretos) y Jápeto (`*--prod*`) consolidados en un único bloque.
- `MODELOS.md`: criterio de asignación cambia de "por Titán" a "por fase del trabajo dentro de una
  misma sesión" — ver ADR-002, nota de continuidad.
- `LOOPS.md`: referencias a Titanes individuales reemplazadas por referencias a Cronos y al
  `self-critique-loop`; sin cambios en la investigación de fondo sobre `/loop`/`/goal`.
- `commands/titanes-continuar.md` → `commands/cronos-continuar.md`; `commands/titanes-verificar-objetivo.md`
  → `commands/cronos-verificar-objetivo.md` (comandos renombrados a la nueva marca, mismo contenido
  de fondo con referencias actualizadas).
- `scripts/elegir-modelos.sh` (plural, por Titán) → `scripts/elegir-modelo.sh` (singular, con
  recordatorio de fase).
- `scripts/instalar-global.sh`, `scripts/nuevo-proyecto.sh`, `scripts/actualizar-proyecto.sh`:
  rutas actualizadas de `~/.config/opencode/agencia-los-titanes/` a `~/.config/opencode/cronos/`;
  ya no copian `titanes/*.template.md` (no existen); `instalar-global.sh` excluye explícitamente los
  documentos de gobierno (`GOBERNANZA.md`, `RIESGOS.md`, `ROADMAP.md`, `GUIA-PARA-PRINCIPIANTES.md`)
  de la copia a `~/.config/opencode/`, consistente con la tabla de componentes de `AGENCY.md`.
- `scripts/verificar-kit.sh`: eliminado el chequeo de consistencia entre `titanes/*.template.md` y
  `fragments/` (ya no aplica); renumerado de 6 a 5 chequeos.
- `RIESGOS.md`: R-005, R-008, R-009 y R-010 cerrados por dejar de aplicar (ver cada entrada para el
  motivo puntual); R-002 simplificado (ya no hay subagentes vía `task`, solo la sesión primaria).
- `GOBERNANZA.md` y `ROADMAP.md`: referencias a Titanes individuales y a adaptadores multiplataforma
  actualizadas a la nueva arquitectura.
- `STACK.example.md`, `AUDITORIA.example.md`, `MEJORAS.example.md`: quitadas las columnas "Titán(es)
  responsable(s)" y "Titanes activos", reemplazadas por referencias a fases del trabajo.
- `gitignore.template`: comentario de cabecera actualizado.

### Eliminado
- `titanes/` (las 10 plantillas de Titán) — absorbidas como fases del ciclo de trabajo de Cronos.
- `fragments/` y `scripts/generar-plantillas.py` — sin las 10 plantillas, no hay nada que componer.
- `adapters/` completo (`claude-code/`, `codex-cli/`, `opencode/`, `roo-code-EOL/`) — uso exclusivo
  de OpenCode, sin capa de abstracción multiplataforma (ver ADR-007, revierte ADR-005/ADR-006).
- Paso "0.5 — Detecta la plataforma" de `MASTER_PROMPT.md` — ya no hace falta detectar nada.
- Paso "A3 — Especialización" (generación de `titanes-proyecto/<titan>.md`) — sin subagentes que
  especializar, `STACK.md` es la única fuente de contexto de proyecto que hace falta.

### Nota sobre continuidad de riesgos y ADRs
Ningún riesgo cerrado en esta versión se borró del archivo — se marcaron como cerrados con el
motivo puntual, para no perder el registro de por qué existieron. Mismo criterio con los ADRs
005 y 006: se conservan, marcados como "superada por ADR-007", en vez de eliminarse.

## [2.0.1] — 2026-07-12

A pedido del operador: `npx autoskills --dry-run` fallaba con error (no con "no detectó nada") en un
proyecto Nivel 1/2/3 recién creado — adaptar el flujo para que autoskills corra cuando de verdad
puede correr. Esta versión cierra ese hallazgo (R-014) y, en el camino, corrige una inconsistencia
real que dejó el propio v2.0.0 (ver "Corregido").

### Agregado
- `RIESGOS.md` R-014: `npx autoskills --dry-run` falla con error en una carpeta sin manifiesto de
  dependencias — `autoskills` detecta stack leyendo `package.json`/Gradle/config existentes, y en un
  proyecto recién creado no tiene nada que leer. No es un caso que `autoskills` mismo maneje con
  gracia (falla, no devuelve "sin resultados").
- `scripts/verificar-kit.sh`: chequeo nuevo 6/6 — toda referencia a `R-XXX` en el kit debe existir de
  verdad como entrada `### R-XXX` en `RIESGOS.md`. Este chequeo habría detectado el problema de abajo
  antes de empaquetar v2.0.0.

### Cambiado
- `MASTER_PROMPT.md` (paso A2) y `titanes/atlas.template.md`: si el stack candidato usa Node.js/npm,
  Atlas ahora scaffoldea un `package.json` mínimo (`npm init -y` + dependencias ya conocidas por
  `BRIEF.md`) **antes** de correr `autoskills`, en vez de correrlo directo sobre una carpeta vacía.
  Cualquier error/timeout/salida vacía se trata igual que "no detectó nada" — sin reintentar el mismo
  comando. Stacks sin manifiesto de dependencias (vanilla JS + Google Apps Script, por ejemplo)
  siguen sin detectar nada por diseño de `autoskills` mismo, no por este cambio.
- `README.md` y `titanes/crio.template.md` sin cambios de contenido en esta versión — ya reflejaban
  criterios compatibles; se revisaron y no hizo falta tocarlos.
- `adapters/claude-code/agents/atlas.md` regenerado desde el núcleo (recibe el fix de arriba).
- `adapters/codex-cli/agents/atlas.toml`: agregada a mano la misma guía de scaffolding de
  `package.json` antes de `autoskills` (este adaptador no se genera automáticamente, ver su propio
  `README.md`).

### Corregido
- **Inconsistencia real dejada por v2.0.0:** el fix de autoskills se aplicó al núcleo
  (`MASTER_PROMPT.md`, `titanes/atlas.template.md`) pero `adapters/claude-code/agents/atlas.md` no se
  había regenerado después — quedó con la guía vieja ("ejecuta siempre autoskills, sin excepción, no
  necesitas comprobar si hay `package.json`"), literalmente el comportamiento que causaba el error.
  Corregido regenerando el adaptador.
- **`RIESGOS.md` R-014 se citaba en 4 archivos sin existir como entrada real en `RIESGOS.md`** —
  agregado el chequeo 6/6 de `verificar-kit.sh` específicamente para que esta clase de bug no se
  repita sin que algo lo note.
- **Punto ciego real en el propio regex de `scripts/verificar-kit.sh` (paso 3/6):** patrones como
  `segui[^r]` no matcheaban la forma acentuada real `seguí` en el locale de este entorno — grep trata
  la tilde como límite de palabra (`\b`), así que `dá\b` generaba falsos positivos dentro de palabras
  normales como "dándole", y patrones sin tilde no capturaban su equivalente con tilde. Se quitaron
  los patrones de 2-3 letras de alto riesgo y se agregaron las formas acentuadas reales que sí
  aparecían en el kit (`seguí`, `seguís`, `sabés`).
- Voseo real que el regex anterior había dejado pasar en v2.0.0, encontrado con el regex corregido:
  "seguí" en `MASTER_PROMPT.md`, "seguís" en `titanes/hefesto.template.md` (y su copia generada en
  `adapters/claude-code/agents/hefesto.md`), y "decidís"/"documentás"/"sabés"/"seguí" en
  `adapters/codex-cli/agents/atlas.toml` y `adapters/claude-code/CLAUDE.md` — estos últimos cuatro no
  habían sido tocados por la limpieza de voseo de v2.0.0 porque son archivos nuevos de esa misma
  versión, escritos después del barrido general.
- Typo "todavío" → "todavía" en `titanes/atlas.template.md` (arrastrado a su copia generada en el
  adaptador de Claude Code).

### Verificado empíricamente (no solo documentado)
- `scripts/verificar-kit.sh` completo (6/6) corrido después de cada fix, no solo al final.
- No se pudo instalar `autoskills` en este entorno de verificación (sin acceso de red al registro de
  npm de terceros desde aquí) — el fix se diseñó y se razonó contra el comportamiento documentado de
  la herramienta (lee manifiestos de dependencias, falla si no hay ninguno), pero **queda pendiente
  correrlo de verdad contra `npx autoskills --dry-run` en un proyecto Node.js recién scaffoldeado**
  (ver `RIESGOS.md` R-014, estado "cerrado — pendiente de verificación empírica").

## [2.0.0] — 2026-07-12

A pedido del operador: auditoría empresarial integral contra 15 pilares de arquitectura empresarial
(`AUDITORIA-EMPRESARIAL-v1.5.0.md`) y diseño de una propuesta v2.0 (`PROPUESTA-AGENCIA-TITANES-v2.0.md`)
con Consejo Estratégico, ADRs, KPIs, gestión de riesgos, roadmap, memoria organizacional,
multi-plataforma y gobierno de agentes/modelos/skills. Esta versión implementa, de esa propuesta y
esa auditoría, todo lo que no requiere una sesión real de OpenCode para cerrarse (ver "Fuera de
alcance" más abajo para lo único que sí la requiere).

### Verificado antes de cambiar nada
- Confirmado por `md5sum` que el bloque "Reglas de oro (resumen)" era byte-idéntico en 8 de los 10
  `titanes/*.template.md` (personalizado en una sola línea en Crío y Temis) antes de extraerlo a
  `fragments/reglas-oro.md`.
- Confirmado por `grep` el alcance exacto del voseo remanente que v1.4.0 dejó pendiente: los 10
  `titanes/*.template.md` (vía la oración compartida "...podés usar..."), los 2 `commands/*.md`,
  `skills-custom/frontend-craft/SKILL.md`, un mensaje de `instalar-global.sh`, y una línea de
  `README.md` (esta última no estaba en el alcance de la limpieza de v1.4.0 por haberse agregado
  después, en v1.5.0, junto con `ui-ux-pro-max`).
- Verificado en vivo (búsqueda web, julio de 2026) el estado real de las tres plataformas nombradas
  en el pedido de multi-plataforma que no fueran OpenCode: Claude Code (subagentes vía Markdown +
  frontmatter YAML en `.claude/agents/`, confirmado), Codex CLI (agentes vía TOML en
  `.codex/agents/`, `sandbox_mode`/`approval_policy`, confirmado), y Roo Code — que resultó haber
  cerrado operaciones el 15 de mayo de 2026 (ver "Hallazgo nuevo" más abajo).

### Agregado
- `RIESGOS.md` — registro de riesgos centralizado (13 entradas iniciales), consolidando lo que antes
  vivía disperso en `MODELOS.md`, `LOOPS.md` y `README.md`.
- `ROADMAP.md` — dirección del kit hacia adelante por horizontes (corto/mediano/largo plazo), primera
  vez que existe algo así (antes solo había `CHANGELOG.md`, hacia atrás).
- `GOBERNANZA.md` — patrón de gobernanza por "sombreros" (Product Owner, Arquitecto técnico, Oficial
  de seguridad, Aprobador de operaciones) con matriz RACI, sin cambiar quién ejerce cada uno hoy.
- `adr/` — 6 ADRs retroactivos (ADR-001 a ADR-004: decisiones ya tomadas en v1.0-v1.4) y 2 nuevos
  (ADR-005: núcleo + adaptadores; ADR-006: Paso 0.5 de detección de plataforma).
- `fragments/reglas-oro.md`, `fragments/ejecucion-continua-base.md` + `scripts/generar-plantillas.py`
  — fuente única de los bloques compartidos entre los 10 `titanes/*.template.md`, con verificación de
  consistencia (`--check`) integrada a `scripts/verificar-kit.sh`.
- `scripts/verificar-kit.sh` — primera suite de verificación propia del kit: JSON válido (`jq`),
  consistencia de plantillas contra `fragments/`, ausencia de voseo, ShellCheck sobre los 5 scripts,
  y que `GUIA-PARA-PRINCIPIANTES.md` no referencie un `.zip` de versión puntual. Sin CI todavía — se
  corre a mano (ver "Fuera de alcance").
- `--dry-run` en `scripts/actualizar-proyecto.sh` (muestra diff contra `opencode.json`/`.gitignore`
  actuales) y `scripts/nuevo-proyecto.sh` (muestra qué se crearía) — probado en un HOME temporal
  contra los dos escenarios (proyecto nuevo, proyecto ya al día).
- `adapters/` — patrón núcleo + adaptadores (ADR-005): `adapters/opencode/` (reencuadre del kit
  existente como adaptador de referencia, ya verificado), `adapters/claude-code/` (10 agentes
  generados por `generar-agentes.py` desde el núcleo + `CLAUDE.md` + boceto de hook `PreToolUse`),
  `adapters/codex-cli/` (3 de 10 agentes TOML de ejemplo + `AGENTS.md`), `adapters/roo-code-EOL/`
  (documenta el cierre de Roo Code y los sucesores candidatos, Cline y Kilo Code).
- `GUIA-PARA-PRINCIPIANTES.md` incorporada a la raíz del kit (antes vivía fuera del paquete
  versionado — ver `RIESGOS.md` R-011).
- Diagrama Mermaid y glosario mitológico del equipo, y criterio de "cuándo agregar un Titán nuevo",
  en `AGENCY.md`.
- Reglas de `permission.bash` contra lectura de secretos vía `bash` (`cat *.env*`, `cat *secret*`,
  `cat *credential*`, `env`, `printenv*`, `history`) en la raíz de `opencode.template.json` y en los
  bloques propios de Crío (nuevo), Tetis y Jápeto (extendidos) — cierra el Hallazgo Crítico C1.

### Cambiado
- `VERSION`: `1.5.0` → `2.0.0`.
- Voseo corregido en los 10 `titanes/*.template.md`, los 2 `commands/*.md`, `frontend-craft/SKILL.md`,
  `instalar-global.sh` y `README.md` (ver "Verificado antes de cambiar nada").
- `MASTER_PROMPT.md`: nuevo "Paso 0.5 — Detecta la plataforma" antes del Paso 0 existente (ADR-006).
- `AGENCY.md`: Principio 13 nuevo (gobernanza por sombreros); tabla de componentes globales
  actualizada con todo lo agregado en esta versión.
- `README.md`: sección "Verificación recomendada" actualizada (Mejora I5: repetirla en cada bump de
  OpenCode, no solo del kit) y estructura del kit actualizada con los componentes nuevos.
- `titanes/crio.template.md`: checklist actualizado documentando la nueva protección de
  `permission.bash` contra secretos vía `bash`, con la limitación explícita de qué no cubre.

### Corregido
- Bug de portabilidad en `scripts/verificar-kit.sh` durante su propio desarrollo: una variable con
  tilde (`FALLÓ`) rompía el parseo de bash en este entorno — renombrada a `FALLO` (ASCII puro), más
  seguro para el público de Git Bash en Windows que ya asume el resto del kit.
- Hallazgo de ShellCheck (SC2164) en el propio `scripts/verificar-kit.sh` nuevo: `cd "$RAIZ"` sin
  manejo de fallo — corregido a `cd "$RAIZ" || exit 1`. El resto de los scripts (los 4 preexistentes)
  pasó ShellCheck sin hallazgos.

### Verificado empíricamente (no solo documentado)
- Instalación completa (`instalar-global.sh --force`), creación de proyecto (`nuevo-proyecto.sh`, con
  y sin `--dry-run`), y `actualizar-proyecto.sh --dry-run` (con versión igual y con versión distinta),
  todo corrido en un HOME temporal — igual que la disciplina de prueba que ya usaban versiones
  anteriores, ahora con `--dry-run` incluido en la prueba.
- `opencode.template.json` validado como JSON después de los cambios de seguridad (`jq empty`).
- `scripts/generar-plantillas.py --check` corrido antes y después de cada cambio a `fragments/`, para
  confirmar que la regeneración produce exactamente el diff esperado y nada más (probado explícitamente
  contra `atlas.template.md`, con diff mostrado línea por línea).

### Hallazgo nuevo sobre esta misma versión (verificación externa, julio 2026)
**Roo Code cerró operaciones el 15 de mayo de 2026** — la extensión de VS Code, Roo Code Cloud y Roo
Code Router quedaron archivados; el equipo pivotó a un producto cloud distinto ("Roomote"). Uno de
los cuatro nombres de plataforma pedidos para v2.0 ya no existe como tal al momento de construir esta
versión. Documentado en `adapters/roo-code-EOL/README.md` con los dos sucesores candidatos (Cline,
Kilo Code — este último reconstruido sobre OpenCode server), ninguno evaluado todavía contra este kit.
Es, en sí mismo, el mejor argumento a favor de ADR-005 (adaptadores verificados de forma viva, no una
lista fija de plataformas).

### Fuera de alcance de esta versión
- **El Hallazgo Crítico C2 (propagación de reglas de oro a subagentes) sigue sin cerrarse.** Es el
  único ítem de toda esta ronda que no se puede resolver editando archivos — requiere una sesión real
  de OpenCode que solo el operador puede correr (ver `README.md`, "Verificación recomendada", paso 2, y
  `RIESGOS.md` R-002). Sigue abierto desde v1.3.0, sin cambios en esta versión.
- Los adaptadores de Claude Code y Codex CLI son borradores sin verificar contra sesiones reales — ver
  "Pendiente de verificar" en cada `adapters/<plataforma>/README.md`.
- CI real (que corra `scripts/verificar-kit.sh` automáticamente) no se implementó — el script existe
  y se corrió a mano para esta versión, pero nada lo dispara todavía en cada cambio futuro.
- Telemetría de uso (Mejora Opcional O2) y checksums de integridad de dependencias de terceros
  (Mejora Opcional O4) quedan para una versión futura — ver `ROADMAP.md`.


A pedido del operador: investigar y verificar en la web el estado real de `/loop` y `/goal` en
OpenCode, conectar esa investigación con el uso diario de los Titanes (no dejarla solo escrita y
sin usar), y sumar una skill de UI/UX para que Hefesto deje de partir del default de un framework.
Esta versión hace las tres cosas, y de paso corrige dos bugs reales encontrados en el camino.

### Verificado antes de cambiar nada
`LOOPS.md` ya existía en el kit recibido, fechado 2026-07-10 (el mismo día), y afirmaba estar
investigado y verificado contra el estado público de OpenCode. Antes de dar eso por sentado, se
repitió la investigación de forma independiente:
- Confirmado que el repo real del proyecto es `anomalyco/opencode` (ex-SST, rebrandeado a Anomaly)
  — no `opencode-ai/opencode`, un proyecto Go distinto y ya archivado que continuó como "Crush" bajo
  el equipo de Charm. Es un error fácil de cometer por la similitud del nombre.
- Confirmado el convenio de comandos personalizados contra `opencode.ai/docs/commands` y
  `opencode.ai/docs/config`: `commands/` (plural) es la convención vigente, tanto global
  (`~/.config/opencode/commands/`) como por proyecto (`.opencode/commands/`); `command/` en
  singular "también se soporta por compatibilidad hacia atrás" según la documentación oficial.
- Confirmados, uno por uno, los cuatro issues de `anomalyco/opencode` que cita `LOOPS.md`: #27162 y
  #27167 ("Add native session goals with /goal", cerrados, con la misma cita textual sobre por qué
  no es implementable como comando), #29721 ("feat: add /goal command", cerrado como "not planned"
  el 28 de mayo de 2026), y el PRD #27339 ("Goal Mode plugin pair and TUI plugin runtime", abierto).
- Confirmados, uno por uno, los seis plugins de terceros de la tabla de `LOOPS.md`
  (`ByBrawe/opencode-loop`, `mirsella/opencode-goal`, `prevalentWare/opencode-goal-plugin`,
  `willytop8/OpenCode-goal-plugin`, `VerbalChainsaw/opencode-autogoal`, `oh-my-goal`) contra sus
  repos/páginas de npm reales — incluidos detalles puntuales como los flags `--safe`/`--stop-file`/
  `--branch` de ByBrawe y el default `allow_goal_execution_from_plan: false` de prevalentWare.
- Ningún hallazgo contradijo lo que ya decía `LOOPS.md` — la investigación original resultó precisa.
  Lo que faltaba no era corregir el archivo, sino conectarlo con el resto del kit (ver "Agregado").
- Igual que ya aclaraba `LOOPS.md` sobre sí mismo: esto es investigación de documentación pública,
  repetida en una segunda pasada independiente el mismo día — no una prueba empírica contra una
  sesión real de OpenCode con credenciales de modelo. Sigue pendiente, igual que antes.
- Sobre `ui-ux-pro-max-skill` (`nextlevelbuilder/ui-ux-pro-max-skill`, sugerida por el operador):
  confirmado que es un repo real, activo, MIT, con releases y CI, y con soporte nativo documentado
  para OpenCode (`uipro init --ai opencode`) entre una lista larga de agentes compatibles. Se revisó
  su documentación pública (README, incluida la afirmación de que el motor de búsqueda no hace
  llamadas de red y usa solo librería estándar de Python) — no se auditó el código fuente completo
  ni se ejecutó el instalador, porque este entorno de trabajo no tiene acceso de red desde la
  herramienta de ejecución de comandos. Se trata en el kit con la misma disciplina que Superpowers:
  instalación deliberada, versión fijada, nunca automática ni por inercia (ver `README.md`).
- Se intentó acceder a `mobbin.com/discover/sites/latest` (pedido explícito del operador) para traer
  plantillas concretas: el sitio bloquea el acceso automatizado (bot detection confirmado). Queda
  documentada como referencia de navegación humana en `frontend-craft` y en
  `titanes/hefesto.template.md` — no como fuente que un Titán pueda scrapear por su cuenta.

### Agregado
- **`AGENCY.md`, Principio 12 (nuevo):** un loop o un objetivo automatizado nunca reemplaza la
  aprobación humana en lo crítico. `LOOPS.md` ya citaba este principio por adelantado desde que se
  escribió; no existía todavía en `AGENCY.md` — ahora sí.
- **`MASTER_PROMPT.md`, checkpoints A4.1 (Flujo A) y B3.1 (Flujo B):** ofrecen la Capa 2 de
  `LOOPS.md` (plugin de continuación automática) como paso opcional en proyectos Nivel 2/3, después
  de asignar modelos y antes de construir — nunca se activa sin confirmación explícita del operador.
  `LOOPS.md` ya los citaba por su número desde que se escribió; no existían todavía.
- **Sección "Ejecución continua" en los 10 `titanes/*.template.md`:** cada Titán documenta ahora
  cómo usar `/titanes-continuar` y `/titanes-verificar-objetivo`, con una línea adicional para
  quienes sostienen un veto o gate (Crío: un hallazgo crítico bloquea el loop igual que bloquea todo
  lo demás; Temis: cerrar "aprobada" exige la misma evidencia con o sin loop; Jápeto: ningún loop se
  configura con un despliegue a producción como condición de éxito; Tetis: una migración destructiva
  nunca se marca "completa" dentro de un loop sin backup verificado). `LOOPS.md` decía que este
  detalle "vive en cada `titanes/*.template.md`" desde que se escribió; no existía todavía.
- **`titanes/hefesto.template.md` reescrito** con un proceso de diseño de tres capas: `ui-ux-pro-max`
  (si está instalada) como punto de partida cuantitativo, la nueva skill `frontend-craft` como
  criterio cualitativo encima, y Mobbin como referencia visual manual (no automatizable). Incluye
  dónde documentar el sistema de diseño resultante (`STACK.md` o `design-system.md`).
- **`skills-custom/frontend-craft/` (nueva, 7ma skill custom):** el paso de criterio que un
  generador de sistemas de diseño no resuelve solo — qué hace que una elección visual sea específica
  de este brief y no el default de cualquier proyecto del mismo rubro, con un piso de calidad no
  negociable (responsive, accesibilidad, foco de teclado, contraste) independiente del riesgo
  tomado en lo demás.
- **`ui-ux-pro-max` documentado como componente global opcional** en `AGENCY.md` (tabla de
  componentes) y `README.md` (instalación con versión fijada, misma disciplina que Superpowers). No
  es de la agencia — es de terceros, MIT, y se instala deliberadamente, nunca por inercia.
- **`AGENCY.md` y `README.md`: fila/sección nueva para `LOOPS.md` y para los comandos globales**
  (`commands/titanes-continuar.md`, `commands/titanes-verificar-objetivo.md`) en las tablas de
  componentes y estructura del kit — existían como archivos pero no estaban documentados ahí.

### Corregido
- **`scripts/instalar-global.sh` nunca copiaba los comandos personalizados.** `LOOPS.md` afirmaba
  que "`scripts/instalar-global.sh` los copia a `~/.config/opencode/commands/`, igual que ya hace
  con `skills/`" — pero el script no tenía ese paso. En la práctica, `/titanes-continuar` y
  `/titanes-verificar-objetivo` nunca quedaban instalados globalmente en ninguna instalación hecha
  con `instalar-global.sh` hasta esta versión, sin que nada avisara del problema.
- **`command/` renombrado a `commands/`** (plural), la convención vigente de OpenCode para comandos
  globales y por proyecto — la anterior en singular solo se mantiene por compatibilidad hacia atrás
  según la documentación oficial. `scripts/instalar-global.sh` actualizado para copiar desde ahí.
- **Carpeta anidada duplicada eliminada del empaquetado.** El .zip recibido para esta versión
  (`agencia-los-titanes-v1_4_0.zip`) contenía una copia completa y desactualizada de sí misma un
  nivel adentro (`agencia-los-titanes/agencia-los-titanes/`, sin `LOOPS.md` ni `command/` — parece
  un resto de haber comprimido la carpeta padre por error). No afectaba el funcionamiento del kit
  en la carpeta correcta, pero duplicaba ~200KB sin motivo y podía confundir si alguien navegaba el
  .zip a mano. El .zip de esta versión no la incluye.

### Fuera de alcance de esta versión
- No se instaló ni se corrió `ui-ux-pro-max` ni ningún plugin de Capa 2 de `LOOPS.md` contra una
  sesión real de OpenCode — este entorno de trabajo no tiene acceso de red desde la herramienta de
  ejecución de comandos. Queda para la primera vez que el operador (o Cronos, con su confirmación) las
  instale de verdad, siguiendo la "Verificación recomendada" de `README.md`, igual que ya se hace
  con el esquema de `permission`/`tools`.
- No se tocó `opencode.template.json`: ni la Capa 2 de loop/goal ni `ui-ux-pro-max` se configuran
  ahí — la primera porque `LOOPS.md` es explícito en que no debe venir activada por defecto, la
  segunda porque OpenCode la descubre vía su `skill` tool nativo, igual que las demás skills.

## [1.4.0] — 2026-07-09

A pedido del operador: el kit dependía de que quien lo usara tuviera acceso a los mismos proveedores de IA que él (GLM, Qwen, DeepSeek, Kimi, MiniMax), y esos catálogos —sobre todo los niveles gratuitos— cambian con frecuencia. Esta versión reemplaza esa dependencia por un **proceso de descubrimiento**: Cronos consulta qué hay realmente disponible en cada máquina y decide con un criterio, en vez de partir de una lista fija de nombres.

### Verificado antes de cambiar nada
Se instaló OpenCode v1.17.15 (misma versión ya verificada en `1.3.0`) y se probaron en vivo los comandos de descubrimiento antes de rediseñar nada sobre ellos:
- `opencode auth list` — confirma qué proveedores están conectados en la máquina actual.
- `opencode models` — confirmado que la lista SÍ depende de lo conectado: en una máquina de prueba con solo OpenAI conectado, la salida fue únicamente `opencode/*` (el nivel gratuito propio de OpenCode, sin cuenta con otro proveedor) + `openai/*` — ningún otro proveedor apareció. Esto era necesario confirmarlo porque no era obvio si el comando lista "todo lo que existe" o "lo que de verdad se puede usar"; es lo segundo.
- `opencode models <id> --verbose` — confirmado que trae costo por token, tamaño de contexto y capacidades (razonamiento, tool-calling, adjuntos) por modelo — suficiente para que Cronos razone sobre ajuste, no solo sobre el nombre.
- El modelo gratuito `opencode/big-pickle` se confirmó con costo $0, contexto de 200k, razonamiento y tool-calling activos — se adoptó como respaldo de arranque (ver "Cambiado").
- Se re-confirmó con `opencode debug agent tetis`/`japeto` que cambiar el string de `model` no afecta la resolución de `permission.bash` verificada en `1.3.0` — son mecanismos independientes.

### Cambiado
- **`opencode.template.json`: los 11 `model` (uno por Titán + el default raíz) pasan de los proveedores específicos del operador a `opencode/big-pickle`.** Deja de ser "el modelo recomendado" y pasa a ser exactamente lo que dice `MODELOS.md`: un respaldo de arranque para que el archivo sea JSON válido desde el primer momento (antes de que Cronos pueda correr su propio descubrimiento), elegido por ser gratuito y no requerir cuenta con ningún proveedor externo — así el respaldo funciona para cualquier persona, no solo para quien tenga acceso a los proveedores que el operador eligió en su momento.
- **`MODELOS.md` se reescribe por completo:** de "tabla de 11 filas con un modelo específico por Titán" a un documento de cuatro pasos (descubrir con `opencode models`/`auth list` → aplicar un criterio de qué necesita cada Titán → proponerle la asignación completa al operador antes de escribir nada → pensar el alterno ante caída de proveedor con lo que haya disponible). La tabla vieja queda como "ejemplo ilustrativo" al final, explícitamente marcada como no vigente y no copiable sin correr el descubrimiento de nuevo.
- **`MASTER_PROMPT.md`, paso A4 (y su equivalente en B3):** pasa de "¿mismo modelo para todos o uno por uno?" (que ya asumía que los defaults de la plantilla eran razonables) a un flujo de tres partes — descubrir lo disponible, proponer una asignación con motivo por cada Titán, y esperar confirmación del operador antes de escribir `opencode.json` — mismo tipo de checkpoint que A2.1.
- **`scripts/elegir-modelos.sh`:** antes de preguntar, ahora corre `opencode auth list` y `opencode models` en vivo y los muestra junto con el criterio de `MODELOS.md` — antes solo mostraba el archivo estático. Si `opencode` no está en el PATH, avisa y sigue igual (no rompe el resto del script).
- **`AGENCY.md`:** Principio 10 reescrito para no describir una "lista fija" que ya no existe. Nuevo **Principio 11**: el kit no depende de proveedores específicos — el criterio de asignación tiene que sobrevivir a que los modelos disponibles cambien, no solo funcionar mientras el operador use los mismos de julio de 2026.

### Nota de alcance
Los strings de proveedor específicos (`glm/glm-5.2`, `qwen/qwen3.7-max`, etc.) no desaparecen del todo: quedan en el "ejemplo ilustrativo" de `MODELOS.md`, explícitamente fechados y marcados como no vigentes, para que se entienda el TIPO de decisión esperada sin invitar a copiarlos a ciegas.

Aprovechando que se tocaron estos archivos, se corrigieron también restos de voseo (`tenés`, `agregalos`, `probalo`, `volvé`, `querés`, `sumás`, `preferís`, `dudás`, `aplicá`, `decílo`) en `MODELOS.md`, `MASTER_PROMPT.md`, `README.md` y `scripts/elegir-modelos.sh`, en línea con el castellano latino neutro ya pedido para `GUIA-PARA-PRINCIPIANTES.md`. No se hizo una limpieza exhaustiva del resto del kit (algunos restos menores pueden seguir en archivos no tocados en esta versión, ej. algunos `titanes/*.template.md`) — sería una tarea aparte si se quiere.

## [1.3.1] — 2026-07-08

El operador corrió el mismo encargo (mejorar el kit a partir de `AUDITORIA-claude-v1.2.0.md` / `MEJORAS-claude-v1.2.0.md`) en una sesión paralela, que llegó a su propio resultado independiente versionado `1.2.1`. Esta entrada documenta la comparación línea por línea entre esa `1.2.1` y esta `1.3.0`, qué se adoptó de ahí, y dos hallazgos nuevos (uno sobre la otra versión, uno sobre esta) que aparecieron solo al comparar.

### Adoptado de la v1.2.1 (créditos donde corresponde)
- **`scripts/elegir-modelos.sh`: modo "mismo modelo para todos" antes del recorrido uno-por-uno.** Buena idea de la v1.2.1 que esta versión no tenía. Se adoptó conservando el diseño más defensivo que ya tenía este script: solo escribe cuando el valor efectivamente cambia (ver "Corregido" más abajo, por qué esto importa). También se sincroniza el `model` raíz cuando cambia el agente `primary` (`cronos`), igual que hacía la v1.2.1.
- **Sección "Verificación recomendada" en `README.md`**, con los comandos exactos para que el operador confirme en su propia instalación lo que esta versión ya confirmó (Hallazgo 4) y lo que sigue sin confirmar (Hallazgo 5). Antes, esto solo vivía en `CHANGELOG.md` y en el chat — no en un lugar que sobreviva a futuras reinstalaciones.
- **Aviso sobre `scripts/actualizar-proyecto.sh` pisando modelos personalizados.** Ese script siempre reemplazó `opencode.json` con los defaults del core (comportamiento correcto y sin cambios desde `1.1.0`), pero ninguna versión anterior de este `CHANGELOG.md` documentaba que esto también deshace lo que `elegir-modelos.sh` haya personalizado. Ahora documentado en `README.md` y `MODELOS.md`.
- **Principio 10 en `AGENCY.md`**: "Un proveedor caído no debería dejar a un Titán sin salida" — eleva el modelo alterno de `MODELOS.md` a principio de primer nivel en vez de dejarlo solo como nota dentro del principio 9.

### No adoptado (con motivo)
- **El resumen de reglas de oro como instrucción a Cronos en tiempo de especialización** (su enfoque) **en vez de contenido estático en `titanes/*.template.md`** (el de esta versión). Se evaluó y se descartó adoptarlo: su enfoque depende de que Cronos recuerde ejecutar esa instrucción cada vez que especializa un Titán — exactamente el mismo tipo de dependencia (que un LLM siga una instrucción de forma consistente) que hace incierto el Hallazgo 5 que ambas versiones intentan mitigar. El enfoque estático de esta versión no tiene ese punto de falla: el resumen está en el archivo por construcción, no por que alguien se acuerde de escribirlo.
- Redacción del requisito de Node en el README de la v1.2.1 ("pedía Node 22+ a mediados de 2026", en pasado, como si fuera un dato posiblemente vencido). Esta versión mantiene "Node.js 22 LTS o superior" como requisito actual verificado, sin ambigüedad de tiempo verbal.

### Hallazgo nuevo sobre la v1.2.1 (informativo — no es un archivo que esta versión distribuya)
- **Bug confirmado empíricamente en su `scripts/instalar-global.sh`:** su lógica de aviso-ante-colisión no distingue "esto lo instaló la agencia antes" de "esto lo instaló otra cosa" — compara solo si la carpeta ya existe. Resultado: desde la *segunda* instalación en adelante (es decir, cualquier reinstalación normal para traer mejoras del kit), sus 6 skills propias quedan marcadas como "colisión" y jamás se vuelven a copiar — la instalación global se congela en el contenido de la primera vez que se instaló, en silencio. Confirmado corriendo su script dos veces seguidas en un `HOME` temporal: una mejora agregada a `product-strategy/SKILL.md` entre la primera y la segunda corrida nunca llegó a `~/.config/opencode/`. La solución de esta versión (marcador en `skills/.agencia-los-titanes-skills`, ver `1.3.0`) no tiene este problema porque distingue explícitamente "lo instalamos nosotros" de "ya existía" — probado con el mismo método (dos instalaciones seguidas) antes de entregar `1.3.0`.
- **Bug latente confirmado en su `scripts/elegir-modelos.sh`:** si un agente no tiene `model` explícito en `opencode.json` (ej. un Titán nuevo agregado a mano que hereda el default raíz) y aceptas el default con Enter, escribe el string literal `"null"` como modelo — corrompiendo ese agente hasta la próxima corrección manual. No ocurre con el `opencode.template.json` tal como se distribuye (los 11 agentes ya traen `model` explícito), pero sí en cuanto se agregue un Titán sin ese campo. El script de esta versión no puede corromper así un valor: solo escribe cuando el usuario tipea algo no vacío, nunca reescribe con un default derivado. Confirmado agregando un Titán de prueba sin `model` y aceptando todos los defaults.
- Ambos hallazgos son coherentes con algo que la propia `1.2.1` admite en su `CHANGELOG.md`: `elegir-modelos.sh` se probó ahí con un *shim* de `jq`, no con el binario real, por falta de red en ese entorno — una limitación reconocida explícitamente, no ocultada. Esta versión tuvo acceso a `npm`/`apt` en su entorno y pudo instalar OpenCode real y `jq` real para probar contra binarios reales en vez de simulados; probablemente explica por qué estos dos bugs no se detectaron ahí.

### Hallazgo nuevo sobre esta misma versión (autocrítica, a partir de comparar)
- `AGENCY.md` reconoce ahora, en la sección "Reglas de oro", algo que ninguna de las dos versiones había hecho explícito: ni el resumen de reglas de oro en `titanes/*.template.md` ni `instructions` tienen confirmado que efectivamente lleguen al contexto de un subagente invocado por Cronos vía la herramienta `task` — `opencode.template.json` no define ningún `prompt` de agente que apunte a estos archivos en ninguna de las dos versiones. Los dos intentos de resolver el Hallazgo 5 (el de esta versión y el de la `1.2.1`) son salvaguardas razonables mientras esa pregunta de fondo sigue sin la prueba empírica que solo el operador puede correr.

## [1.3.0] — 2026-07-07

A partir de una segunda auditoría externa del kit (`AUDITORIA-claude-v1_2_0.md` / `MEJORAS-claude-v1_2_0.md`, por Claude, a pedido del operador) sobre la v1.2.0 ya en buen estado. A diferencia de la ronda anterior, esta vez varios hallazgos se verificaron empíricamente instalando OpenCode v1.17.15 y corriendo `opencode debug agent <nombre>` contra el `opencode.template.json` real — no solo leyendo documentación. Ver la sección "Verificado" más abajo para qué quedó confirmado y qué sigue abierto.

### Cambiado
- **`opencode.template.json`: se quita el `bash` redundante de `tools` en Tetis y Jápeto (Hallazgo 4).** Ambos ya declaraban `permission.bash` granular además del booleano legado `tools.bash: true` para la misma herramienta — una combinación que ningún ejemplo oficial de OpenCode documenta. Verificado con `opencode debug agent tetis`/`japeto` (antes y después del cambio) que la lista de permisos resuelta es idéntica en ambos casos: las reglas granulares (`*migrate*: ask`, `*--prod*: ask`) ya se aplicaban correctamente y el booleano legado no las pisaba. El cambio no altera ningún comportamiento — deja explícito lo que antes dependía de una precedencia no documentada.
- **`MASTER_PROMPT.md` (A4 y su equivalente en B3): ahora se pregunta explícitamente por el modelo de cada Titán** en vez de copiar `opencode.template.json` sin más (Mejora 8, capa conversacional). Nota de diseño: se implementó como una edición directa de Cronos sobre el `opencode.json` ya copiado, no como los placeholders `{{MODELO_<TITAN>}}` que proponía `MEJORAS-claude-v1_2_0.md`. Motivo: `scripts/nuevo-proyecto.sh` copia `opencode.json` al proyecto ANTES de que Cronos llegue a hablar con el operador — si el archivo tuviera placeholders sin resolver en ese punto, OpenCode fallaría al arrancar. `opencode.template.json` conserva modelos literales y funcionales como punto de partida; `MODELOS.md` + la pregunta de Cronos + `scripts/elegir-modelos.sh` logran el mismo resultado sin ese riesgo.
- **`scripts/instalar-global.sh`: avisa antes de sobrescribir una skill que la agencia no instaló ella misma (Mejora 5),** en vez de sobrescribir en silencio. Para no generar fricción en cada reinstalación normal (la agencia reinstala sus propias 6 skills en cada actualización), se agregó un marcador (`skills/.agencia-los-titanes-skills`) que registra cuáles carpetas instaló la agencia — solo avisa cuando el nombre existe y NO está en ese registro. Se agregó `--force` para instalaciones no interactivas.

### Agregado
- **`MODELOS.md`** (nuevo): catálogo de modelos por Titán con un alterno sugerido de otro proveedor para recuperación manual ante caída de proveedor (Mejora 7), y fuente única que `MASTER_PROMPT.md` y `scripts/elegir-modelos.sh` usan como opciones (Mejora 8). Incluye una nota: Cronos y Crío usan hoy el mismo proveedor (GLM) — si cae, se quedan sin modelo el orquestador y el veto de seguridad al mismo tiempo. También documenta por qué automatizar esto con un plugin de fallback de terceros no es recomendable todavía (reportes recientes de plugins que se quedan reintentando el mismo modelo en vez de saltar al alterno).
- **`scripts/elegir-modelos.sh`** (nuevo): reasigna el modelo de uno o varios Titanes en un `opencode.json` ya existente, sin recrear el proyecto (Mejora 8, capa script). Muestra el modelo actual de cada Titán como default (Enter = lo mantiene), hace backup automático con timestamp antes de escribir, y valida que `opencode.json` sea JSON válido antes de tocarlo. Requiere `jq`. Probado de punta a punta: reasignar uno, no reasignar ninguno, sin `opencode.json` presente, sin `jq` instalado.
- **Resumen de "reglas de oro" (5 líneas) en cada uno de los 10 `titanes/*.template.md`**, justo después de "Rol" (Mejora 2) — antes esas reglas vivían solo en `AGENCY.md`. Es una redundancia deliberada: si algún día se confirma que un Titán invocado sin pasar por Cronos no recibe `AGENCY.md` completo (ver Hallazgo 5 más abajo), esta sección ya le llega igual porque es parte de su propia plantilla.
- **Checklist de Crío**: nueva línea reconociendo que OpenCode ya pide confirmación (`ask`) por defecto antes de leer `.env`/`.env.*` a nivel de la herramienta `read`, verificado con `opencode debug agent` (Mejora 6) — con una aclaración: la documentación pública describe este default como "deny", pero lo observado en la versión instalada (v1.17.15) es "ask". Puede ser una diferencia real de comportamiento entre versiones o una imprecisión de la documentación; de cualquier forma, sigue siendo una capa de protección activa que Crío puede dar por confirmada.
- **`AGENCY.md`**: sección nueva "Versión y compatibilidad" que ancla contra qué versión de OpenCode se verificó el core (Hallazgo 1 / Mejora 3), con referencia a `MODELOS.md`.
- **`STACK.example.md`**: sección nueva "Entorno" con campo para la versión de OpenCode del proyecto y un campo formal para la versión de Superpowers instalada (antes solo se pedía en prosa en `README.md`, sin un campo dedicado en el formato).
- **`README.md`**: versión mínima de Node.js (22 LTS, según el propio requisito publicado de `autoskills`) en Requisitos (Hallazgo 2 / Mejora 4); nota sobre `jq` como requisito de `scripts/elegir-modelos.sh`; estructura del kit y notas finales actualizadas.

### Verificado empíricamente (no solo documentado)
- **Hallazgo 4 (mitad de la Mejora 1): confirmado seguro.** `opencode debug agent` mostró que las reglas granulares de Tetis/Jápeto se aplican tal como están escritas, sin importar el booleano legado coexistiendo en `tools`.
- **Hallazgo 5 (la otra mitad de la Mejora 1, la de severidad alta): sigue sin confirmar.** `opencode debug agent`/`opencode debug config` exponen permisos, modelo y tools resueltos, pero no el contenido de `instructions`/system prompt que efectivamente recibe un subagente — verificar eso requiere la prueba barata que ya proponía la auditoría (invocar un Titán aislado y pedirle que liste las reglas de oro), y esa prueba solo se puede correr con una sesión real de OpenCode con credenciales de modelo configuradas. Se encontró un indicio no concluyente (un issue de GitHub de un usuario reportando que los subagentes sí heredan las `instructions` globales por defecto), pero no hay confirmación oficial. La Mejora 2 se implementó de todas formas, sin esperar esa confirmación: es barata y funciona como red de seguridad en cualquiera de los dos escenarios.
- **Hallazgo 7: confirmado vigente.** El fallback nativo entre modelos distintos sigue sin existir en OpenCode (varios pedidos de feature abiertos, el más reciente de abril de 2026), y hay reportes recientes y concretos de plugins de fallback de terceros que se quedan reintentando el mismo modelo en vez de saltar al alterno. La recomendación de resolverlo con documentación manual (`MODELOS.md`) en vez de un plugin sin probar a fondo sigue vigente.

### Corregido
- Bug encontrado al probar la Mejora 5 antes de entregarla: si el usuario respondía "no sobrescribir" ante una colisión de nombre, el marcador la registraba igual como "instalada por la agencia", así que la siguiente corrida dejaba de avisar sobre esa misma colisión. Corregido antes de entregar, con una prueba de punta a punta en un `HOME` temporal (mismo método que ya usó `1.2.0` para `instalar-global.sh`).

### Fuera de alcance de esta versión
No se tocaron `AUDITORIA.example.md`, `MEJORAS.example.md` ni las 6 `skills-custom/*/SKILL.md`: la auditoría de origen no encontró nada pendiente ahí.

## [1.2.0] — 2026-07-05

A partir de una auditoría externa del kit (Atlas + Crío + Temis en conjunto, formato `AUDITORIA.md`/`MEJORAS.md` de la propia agencia). Verificado contra `1.0.0` y `1.1.0`: ningún archivo se eliminó en ninguna transición, y todo lo que cambió en `1.1.0` ya estaba descrito correctamente en su entrada de este changelog — esta versión no corrige una regresión de `1.1.0`, cierra brechas que ya existían desde `1.0.0` y que ninguna de las dos versiones anteriores había tocado.

### Cambiado
- **Flujo B (proyecto existente) ahora especializa a los Titanes igual que el Flujo A.** Nuevo paso B3 en `MASTER_PROMPT.md`: después del checkpoint B2.1, documenta el stack real en `STACK.md` y escribe `titanes-proyecto/<titan>.md` para los Titanes confirmados, igual que A3/A4. Antes, solo el Flujo A dejaba ese contexto por escrito — en el Flujo A ya existía desde `1.0.0`; el Paso 7 (compartido por ambos flujos) siempre asumió que ya existía, así que en proyectos auditados esa especialización dependía de que Cronos la improvisara por su cuenta. Renombra el antiguo B3 ("Genera `tasks.md`...") a B4.
- **Permisos de OpenCode: se agrega el esquema `permission` junto a `tools`.** `opencode.template.json` ahora incluye `permission.bash` con reglas `deny`/`ask` por patrón (`rm -rf *`, `git push --force*`, `sudo *`), reforzado en Tetis (`*migrate*`) y Jápeto (`*--prod*`). Se conserva `tools` tal cual para la distinción `write`/`edit` (Ceo/Hiperión/Temis) porque el `permission.edit` de OpenCode no puede replicar esa distinción hoy — ambos esquemas conviven a propósito, no es un descuido. Antes, `bash: true` significaba ejecución sin ninguna confirmación para cualquier comando en 8 de los 10 Titanes: la regla de "nunca borres datos ni despliegues sin mi confirmación" (`AGENCY.md`) no tenía ningún respaldo técnico, solo texto. **Verifica con `opencode debug agent <nombre>` que las reglas se aplican como esperas antes de confiar en ellas.**
- **`AGENTS/` (carpeta de Titanes especializados) se renombra a `titanes-proyecto/`.** Coincidía casi textualmente con `AGENTS.md`, el archivo que genera `/init` de OpenCode — fácil de confundir al hablar o al navegar el árbol de archivos. Afecta: `AGENCY.md`, `MASTER_PROMPT.md`, `scripts/nuevo-proyecto.sh`, `scripts/actualizar-proyecto.sh`. Proyectos ya creados conservan su `AGENTS/` existente — nadie renombra silenciosamente algo específico de un proyecto ya creado.
- **"Reglas de oro" (`AGENCY.md`) pasa a ser la única fuente de verdad.** `MASTER_PROMPT.md` tenía su propia lista parafraseada ("Reglas que nunca rompes") que ya había divergido: `AGENCY.md` exigía backup verificado en *toda* migración, `MASTER_PROMPT.md` solo en las *destructivas*. Se adoptó la redacción más precisa (la de `titanes/tetis.template.md`) en `AGENCY.md`, y `MASTER_PROMPT.md` ahora referencia esa lista en vez de repetirla — evita que las dos vuelvan a decir cosas distintas.
- Emoji de Tetis: 🌊 → 💧, para distinguirlo de Océano (ambos usaban 🌊).

### Agregado
- Checklist de Crío (`titanes/crio.template.md`): dependencias con vulnerabilidades conocidas (`npm audit` o equivalente), rate-limiting/protección contra abuso en endpoints propios (no solo el manejo de límites de APIs externas, que ya cubre Océano), y logs/consola como superficie de "datos sensibles expuestos" — antes solo cubría respuestas de API y base de datos.
- `gitignore.template`: patrones para credenciales de Firebase/Google Apps Script/GCP (`*-firebase-adminsdk-*.json`, `serviceAccountKey.json`, `.clasprc.json`, `.firebase/`, `firebase-debug.log`) — stack usado en la mayoría de proyectos reales de la agencia, no cubierto hasta ahora.

### Corregido
- Los 6 `skills-custom/*/SKILL.md` no tenían tildes ni eñes desde `1.0.0` (inconsistente con el resto del kit, y contrario al principio 7 de `AGENCY.md`, "Español siempre"). Corregido en los 6 archivos; los campos `name:` del frontmatter no se tocaron.
- `scripts/instalar-global.sh` copiaba el núcleo archivo por archivo — cada archivo nuevo del core obligaba a editar el script a mano (pasó en `1.1.0`: 4 líneas de `cp` nuevas). Ahora copia todo `.md` de la raíz excepto `README.md` en un loop; probado de punta a punta en un `HOME` temporal.
- `scripts/nuevo-proyecto.sh`: `read -p` sin `-r` (SC2162) — una barra invertida en la respuesta de confirmación podía corromperla.

## [1.1.0] — 2026-07-04

### Cambiado
- **Intercambio de responsabilidades entre Tetis y Ceo (Coeus).** Ceo (Coeus) ahora es CEO/Producto (visión, backlog, `BRIEF.md`); Tetis ahora es Bases de Datos (esquemas, migraciones, índices, veto en esquema de datos). Antes, el apodo "Ceo" (de Coeus) convivía con la descripción "Tetis: CEO/Producto" y podía confundirse con facilidad — ahora el apodo coincide con el rol real y no hay ambigüedad. Afecta: `AGENCY.md`, `MASTER_PROMPT.md`, `titanes/tetis.template.md`, `titanes/coeus.template.md`, `titanes/prometeo.template.md`, `titanes/japeto.template.md`, `opencode.template.json`, y las skills `product-strategy`, `mvp-roadmap-planning`, `scalability-patterns`.
- `opencode.json` por Titán: el modelo y los permisos de herramientas (`write`/`edit`/`bash`) ahora siguen al rol, no al nombre — Tetis hereda los permisos de bases de datos (`edit`+`bash`), Ceo hereda los de producto (solo `write`).
- Instalación de Superpowers: ya no se apunta a `refs/heads/main` a ciegas. `README.md` e `instalar-global.sh` ahora piden confirmar el tag más reciente en las releases del proyecto y fijar ese tag tanto en la URL de instalación como en el `plugin` resultante de `opencode.json`.

### Agregado
- `AUDITORIA.example.md` y `MEJORAS.example.md`: formatos de referencia para el Flujo B (proyectos existentes), igual que ya existía `STACK.example.md` para el Flujo A.
- Checkpoint explícito de confirmación del operador: A2.1 en el Flujo A (después de clasificar el nivel del proyecto, antes de especializar Titanes) y B2.1 en el Flujo B (después de escribir `MEJORAS.md`, antes de generar `tasks.md`). Antes, la aprobación humana explícita solo se pedía justo antes del deploy.
- `gitignore.template`: patrones estándar (`.env`, credenciales, `node_modules`, artefactos de build) que `nuevo-proyecto.sh` instala como `.gitignore` en cada proyecto nuevo. Atlas lo completa con lo específico del stack; Crío verifica su existencia en auditoría.
- Sección "Gestión de secretos" en `STACK.example.md`.
- Regla para Tetis (bases de datos): toda migración debe ser reversible y requiere backup verificado antes de aplicarse en producción, coordinado con Jápeto — quinta condición de despliegue añadida a `titanes/japeto.template.md`.
- `scripts/actualizar-proyecto.sh`: trae la versión más reciente del core global (`opencode.template.json`, `.gitignore`) a un proyecto ya creado, con backup automático de lo que reemplaza, sin tocar `BRIEF.md`, `STACK.md`, `tasks.md` ni `AGENTS/`.
- `VERSION`: número de versión del core, para que cada proyecto pueda registrar con qué versión se creó (`.agencia-version`) y detectar si quedó desactualizado.
- Principio 9 en `AGENCY.md`: "La agencia se versiona."

### Corregido
- `scripts/nuevo-proyecto.sh` ya no sobrescribe `BRIEF.md`, `tasks.md` u `opencode.json` en silencio si la carpeta destino ya tenía contenido; ahora pide confirmación o requiere `--force`.
- `scripts/instalar-global.sh` ahora verifica que `git`, `node` y `npx` existan antes de instalar, y avisa con claridad si falta alguno.
