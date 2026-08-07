# Cómo usar Cronos

Tres plataformas soportadas: **OpenCode, Codex CLI y VS Code (GitHub Copilot)** — ver
`adr/ADR-011-multiplataforma-opencode-codex-vscode.md` para el porqué y `adapters/README.md` para
la mecánica de cada una. Elige la sección que te aplique en cada paso; si usas más de una, todos
los pasos admiten hacerlas todas a la vez (es el comportamiento por defecto de los scripts).

## 1. Instalación global (una sola vez por máquina)
```bash
chmod +x scripts/*.sh
./scripts/instalar-global.sh
```
Esto copia las skills de la agencia y el núcleo (`AGENCY.md`, `MASTER_PROMPT.md`, etc.) a
`~/.config/opencode/` **y** `~/.codex/` — cada una tiene un mecanismo de instrucciones global que
se fusiona con lo que haya en cada proyecto — y crea `~/.cronos/LECCIONES.md`, la memoria evolutiva
compartida entre las tres plataformas. Usa `--solo opencode` o `--solo codex` si solo vas a usar
una. **VS Code/Copilot no tiene instalación global** (no existe, a la fecha de esta verificación,
un mecanismo confiable y scripteable — ver `adapters/vscode/README.md`); su configuración se genera
por proyecto en el paso 2/3.

Después, instala Superpowers real (Jesse Vincent / Prime Radiant) — **solo OpenCode**, no se
instala por script, se le pide directamente al agente — pero fija una versión concreta en vez de
seguir `main` a ciegas:

1. Confirma el tag más reciente en https://github.com/obra/superpowers/releases (o `git ls-remote --tags https://github.com/obra/superpowers.git`).
2. Abre OpenCode en cualquier carpeta y pégale esto, sustituyendo `TAG` por ese tag:
```
Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/TAG/.opencode/INSTALL.md
```
3. Verifica que en tu `opencode.json` el plugin quedó fijado a ese mismo tag (formato `superpowers@git+https://github.com/obra/superpowers.git#TAG`, documentado por el propio proyecto) y no apuntando a la rama principal.
4. Anota la versión instalada en `STACK.md` de cada proyecto ("Superpowers: vX.X.X") para poder auditar actualizaciones futuras — actualiza deliberadamente revisando el changelog, nunca en automático.

Por qué: `refs/heads/main` puede cambiar de contenido en cualquier momento sin aviso; si dos personas instalan en fechas distintas (o vuelves a instalar en otra máquina meses después), el agente puede terminar ejecutando instrucciones distintas sin que nadie lo note.

Si el trabajo incluye frontend, considera instalar también `ui-ux-pro-max` (`nextlevelbuilder/ui-ux-pro-max-skill`, MIT, no es de la agencia, **solo OpenCode**) — genera sistemas de diseño (paleta, tipografía, patrones) por tipo de producto, y Cronos ya sabe consultarla si está presente (ver la skill `frontend-craft`). Igual que Superpowers, es opcional y se instala deliberadamente con versión fijada, nunca `@latest` a ciegas:

1. Confirma la versión más reciente en https://github.com/nextlevelbuilder/ui-ux-pro-max-skill/releases.
2. `npm install -g ui-ux-pro-max-cli@<versión-confirmada>`
3. `uipro init --ai opencode --global` (o sin `--global` para instalarla solo en un proyecto puntual).
4. Anota la versión en `STACK.md`, mismo campo que ya existe para Superpowers.

Esta skill no es de la agencia — no se auditó su código fuente completo, solo su documentación pública. El propio proyecto documenta que el motor de búsqueda no hace llamadas de red y solo usa la librería estándar de Python; igual, instálala tú mismo de forma deliberada y revisa qué hace en la primera corrida, en vez de confiar a ciegas.

## Requisitos
- Al menos una de las tres plataformas instalada: **OpenCode** (este kit está verificado contra
  `opencode-ai` v1.18.3, ver `AGENCY.md`, "Versión y compatibilidad" — si la tuya difiere mucho,
  revisa `opencode.ai/docs`), **Codex CLI** (`npm install -g @openai/codex` o el instalador oficial;
  verificado por documentación al 2026-08-03, ver `adapters/codex/README.md`), o **VS Code** con la
  extensión de **GitHub Copilot** (verificado por documentación al 2026-08-03, ver
  `adapters/vscode/README.md`). No hace falta ninguna suscripción de pago para arrancar con
  OpenCode: trae modelos gratuitos propios (`opencode/*`) que alcanzan para probar el kit.
- Node.js 22 LTS o superior (requisito de `npx autoskills`; confírmalo con `node --version` — una versión más vieja falla de forma confusa en vez de avisar claramente).
- `jq` instalado, solo si vas a usar `scripts/elegir-modelo.sh` con OpenCode (lo usa para editar `opencode.json` sin arriesgarse a corromperlo). Para Codex CLI ese mismo script no necesita `jq`.
- Python 3.x, solo si instalas `ui-ux-pro-max` (su motor de búsqueda lo requiere; es opcional, no hace falta para el resto del kit).
- En Windows: corre los scripts `.sh` desde Git Bash o WSL.
- Ningún proveedor de IA específico, en ninguna de las 3 plataformas: Cronos descubre qué hay
  disponible (mecanismo propio de cada una) y recomienda modelo según eso — ver `MODELOS.md`. Este
  kit no restringe qué modelo puedes escribir en ningún archivo de configuración.

## 2. Proyecto nuevo
```bash
./scripts/nuevo-proyecto.sh nombre-del-proyecto
cd nombre-del-proyecto
```
Por defecto genera la configuración de las 3 plataformas (usa `--solo opencode|codex|vscode` para
generar solo una). Después, según la plataforma:
```bash
opencode                 # OpenCode
codex                    # Codex CLI
code .                   # VS Code — abrí la vista de Chat de Copilot en modo Agent
```
Como la agencia ya está cargada (globalmente en OpenCode/Codex CLI si corriste el paso 1, y siempre
vía `AGENTS.md`+`.cronos/` del propio proyecto), dile a Cronos que arranque: "Eres Cronos, este es
un proyecto nuevo, empieza el descubrimiento."

## 3. Proyecto existente o de un cliente
```bash
cd proyecto-existente
opencode   # o codex, o code .
/init
```
`/init` genera un `AGENTS.md` real del repo en OpenCode y en Codex CLI; en VS Code/Copilot el
equivalente es `/init` o `/create-instructions`. Luego pídele a Cronos que entre en modo auditoría,
o simplemente descríbele qué quieres mejorar. Cronos escribe `AUDITORIA.md` y `MEJORAS.md`, y
espera tu confirmación en el checkpoint B2.1 antes de tocar código.

Con `MEJORAS.md` ya confirmado, engancha el proyecto al core:
```bash
cd proyecto-existente
../ruta/a/cronos/scripts/adoptar-proyecto.sh
```
Copia, por defecto para las 3 plataformas (`--solo <plataforma>` para limitarlo), la configuración
correspondiente más `AGENTS.md`/`.cronos/` desde el template del core **solo si el proyecto todavía
no tiene los suyos** (nunca pisa uno ya existente, a diferencia de `actualizar-proyecto.sh`), y crea
`.agencia-version` para que el proyecto quede enganchado a partir de acá. No toca `BRIEF.md`,
`STACK.md`, `tasks.md`, `AUDITORIA.md` ni `MEJORAS.md` — eso lo sigue escribiendo Cronos en sesión.
Si ya tenías configuración propia y quieres el modelo recomendado del core, corre después
`scripts/elegir-modelo.sh`. Admite `--dry-run`.

## 4. Actualizar un proyecto ya creado a la última versión del core
Si el kit fuente avanzó de versión y quieres que un proyecto existente reciba esas mejoras:
```bash
cd proyecto-existente
../ruta/a/cronos/scripts/actualizar-proyecto.sh
```
Muestra el diff antes de aplicar nada y pide confirmación. Actualiza la configuración de cada
plataforma presente en el proyecto, más `AGENTS.md` y `.cronos/` (con backup de lo que reemplaza).
No toca `BRIEF.md`, `STACK.md` ni `tasks.md` — eso es específico de cada proyecto y nunca se
sobrescribe solo. **Ojo:** la configuración de plataforma sí vuelve al modelo de respaldo del core
(no al que hayas elegido), así que si ya habías personalizado el modelo, vuelve a correr
`scripts/elegir-modelo.sh` después de actualizar.

## 5. Cambiar el modelo de Cronos
Para cambiar el modelo en un proyecto ya creado sin editar la configuración a mano — por ejemplo,
al cambiar de fase de trabajo o al sumar un modelo nuevo a tu stack disponible:
```bash
cd proyecto-existente
../ruta/a/cronos/scripts/elegir-modelo.sh
```
Detecta qué plataforma(s) tiene configuradas el proyecto (te pregunta si hay más de una, o usa
`--plataforma opencode|codex`) y antes de preguntar nada muestra lo disponible en vivo: en OpenCode,
`opencode auth list` + `opencode models`; en Codex CLI, el modelo/proveedor actual de
`.codex/config.toml` y cualquier `model_providers` ya declarado (el selector `/model` en sí solo
existe dentro de una sesión). Backup automático antes de escribir. En VS Code no hay nada que
escribir — el script te lo recuerda y te apunta al selector de modelos de la vista de Chat de
Copilot. Ninguna plataforma restringe qué valor puedes escribir acá.

## Verificación recomendada (una vez, tras instalar o actualizar)
Los permisos y las reglas de este kit dependen de cómo cada plataforma los aplica en la práctica, no solo de lo que dicen los templates de `adapters/`. Antes de apoyarte en el kit para un proyecto Nivel 3:

**OpenCode** (el único de los tres con esta verificación corrida contra una sesión real, no solo documentación — ver `docs/AUDITORIA-10-10-verificacion-R002.md`):
1. `opencode debug agent cronos` — confirma que `*migrate*`, `*--prod*` y los patrones anti-secretos (`cat *.env*`, `env`, `printenv*`, etc.) piden confirmación de verdad. Verificado en la instalación con la que se armó esta versión (`opencode-ai` v1.18.3); repite la prueba en la tuya antes de confiar en un proyecto Nivel 3.
2. Pídele a Cronos, en una sesión nueva, que liste las "reglas de oro" de `AGENCY.md` sin que se las repitas. Esta prueba **sigue sin poder correrse de forma automatizada** — hace falta una sesión real con credenciales de modelo (ver `RIESGOS.md` R-002, el riesgo más antiguo y más severo de todo el historial del kit). Si no puede listarlas, es la señal de que hace falta reforzar `AGENCY.md`/`MASTER_PROMPT.md` todavía más, o confirmar que las instrucciones están llegando a la sesión.

**Codex CLI y VS Code** (verificados solo por documentación pública al 2026-08-03 — ver `RIESGOS.md` R-019, `adr/ADR-011`):
1. En una sesión nueva de cada una, pídele a Cronos que liste las reglas de oro sin que se las repitas — mismo criterio que el punto 2 de OpenCode arriba, y la única forma real de confirmar que `AGENTS.md`/`.cronos/` está llegando al contexto.
2. En Codex CLI, después de cambiar de modelo con `scripts/elegir-modelo.sh`, confirma con `/status` dentro de la sesión que el cambio se aplicó de verdad.

Ninguna de estas pruebas toma más de un par de minutos, y todas tocan justo los mecanismos que sostienen las reglas de "aprobación humana" y "veto de seguridad" de `AGENCY.md` — vale la pena no darlas por sentadas. Repite las de OpenCode no solo en cada versión del kit, sino en cada actualización mayor/menor de OpenCode.

## Estructura de este kit
- `AGENTS.md` *(nuevo en v4.0.0)* — punto de entrada universal, leído de forma nativa por las 3 plataformas; se copia a la raíz de cada proyecto generado.
- `AGENCY.md` — filosofía, componentes globales, el ciclo de autocrítica, clasificación de proyectos, reglas y diagrama de arquitectura.
- `MASTER_PROMPT.md` — el flujo universal de Cronos (proyecto nuevo, ya comenzado con la agencia, o existente/externo), con detección de plataforma en el Paso 0.
- `SKILLS.md` — catálogo curado de las 18 skills del kit y el criterio de cuándo usar cada una — formato portable entre las 3 plataformas.
- `LOOPS.md` — qué son (y qué no) `/loop` y `/goal`: comandos nativos de Capa 1 vs. plugins de terceros de Capa 2. Contenido detallado específico de OpenCode — ver nota de alcance al final del archivo para Codex CLI/VS Code.
- `MODELOS.md` — cómo Cronos descubre qué modelos hay disponibles en cada plataforma y con qué criterio recomienda uno por fase.
- `STACK.example.md` — formato que Cronos sigue al documentar el stack (Flujo A).
- `AUDITORIA.example.md` / `MEJORAS.example.md` — formato que Cronos sigue en Modo Auditoría (Flujo B).
- `LECCIONES.example.md` *(nuevo en v3.1.0)* — formato de la memoria evolutiva entre proyectos; la instancia real (`LECCIONES.md`) vive en `~/.cronos/`, compartida entre las 3 plataformas desde v4.0.0.
- `skills-custom/` — 18 skills propias de la agencia: 10 base (`self-critique-loop`, `security-baseline`, `backend-patterns`, `database-design`, `frontend-craft`, `performance-baseline`, `deploy-checklist`, `external-integrations`, `design-benchmark`, `browser-qa-e2e`) + 8 avanzadas (`product-strategy`, `mvp-roadmap-planning`, `advanced-architecture`, `advanced-qa-strategy`, `scalability-patterns`, `technical-governance`, `cost-intelligence`, `capability-gap-analysis`).
- `commands/*.md` — comandos globales de Capa 1 para ejecución continua (`/cronos-continuar`, `/cronos-verificar-objetivo`) — **mecanismo nativo solo de OpenCode**, ver `adapters/codex/README.md`/`adapters/vscode/README.md` para el reemplazo simple en las otras dos.
- `adapters/` *(vuelve en v4.0.0, ver `adr/ADR-011`)* — mecánica específica de cada plataforma: `opencode/opencode.template.json`, `codex/config.toml.template`, `vscode/copilot-instructions.template.md` + `mcp.template.json`. Cada uno con su propio `README.md`.
- `gitignore.template` — patrones estándar de secretos/artefactos que `nuevo-proyecto.sh` instala como `.gitignore`.
- `VERSION` / `CHANGELOG.md` — versión del core y su historial de cambios (incluye el historial completo de la "Agencia Los Titanes" hasta v2.0.1).
- `RIESGOS.md`, `ROADMAP.md`, `GOBERNANZA.md`, `adr/` — gobierno del kit mismo: riesgos abiertos, dirección futura, patrón de gobernanza, decisiones arquitectónicas. No se instalan en ninguna plataforma — son para quien mantiene la agencia, no instrucciones de sesión.
- `GUIA-PARA-PRINCIPIANTES.md` — guía de instalación y primer uso sin experiencia previa de programación, con rutas para las 3 plataformas.
- `scripts/instalar-global.sh` — instala el núcleo en `~/.config/opencode/` y `~/.codex/`, y crea `~/.cronos/LECCIONES.md` (una vez por máquina).
- `scripts/nuevo-proyecto.sh` — crea un proyecto nuevo con la configuración de plataforma + `.cronos/` liviano. Admite `--dry-run`, `--solo <plataforma>`.
- `scripts/adoptar-proyecto.sh` — engancha al core un proyecto existente que nunca fue creado con la agencia (Flujo B), después del checkpoint B2.1. Admite `--dry-run`, `--solo <plataforma>`.
- `scripts/actualizar-proyecto.sh` — trae la versión más reciente del core a un proyecto ya creado. Admite `--dry-run`, `--solo <plataforma>`.
- `scripts/elegir-modelo.sh` — cambia el modelo de Cronos en un proyecto ya creado, sin recrearlo, detectando la plataforma.
- `scripts/_lib-cronos.sh` *(nuevo en v4.0.0)* — funciones compartidas entre los 3 scripts de arriba, para que no diverjan entre sí. Se source-ea, no se ejecuta directo.
- `scripts/verificar-kit.sh` — suite mínima de verificación propia del kit (JSON/TOML válidos, voseo, ShellCheck, referencias de riesgos, versión, estructura de `adapters/`). Córrelo antes de empaquetar cualquier versión nueva.

## Nota sobre la carpeta de este kit
Los scripts de `nuevo-proyecto.sh`, `actualizar-proyecto.sh` y `elegir-modelo.sh` se invocan siempre por ruta relativa o absoluta hacia esta carpeta — **no la borres ni la muevas después de instalar** (ver `RIESGOS.md` R-012). `instalar-global.sh` copia el núcleo a `~/.config/opencode/` y `~/.codex/`, pero los scripts en sí siguen viviendo y ejecutándose desde donde extrajiste el `.zip`.

## Notas
- `npx autoskills` solo detecta stack vía `package.json`, Gradle o config — en vanilla JS + Apps Script no encontrará nada, y ahí Cronos investiga manualmente.
- Playwright MCP viene deshabilitado por defecto en los 3 adaptadores (`enabled: false` en OpenCode/Codex CLI; ausente del todo en el `mcp.template.json` de VS Code, ver `adapters/vscode/README.md`). Cronos lo activa en `STACK.md` si el proyecto lo necesita.
- Superpowers y las skills de la agencia se activan solas cuando la plataforma detecta que aplican — no hay que invocarlas a mano.
- Si ya tenías un `~/.config/opencode/opencode.json` o `~/.codex/config.toml` antes de correr `instalar-global.sh`, el script no los sobrescribe — te dice qué agregar a mano para no perder tu configuración previa.
- **Este kit reemplaza a "Agencia Los Titanes" (10 subagentes + orquestador).** Si vienes de una instalación anterior, ver `CHANGELOG.md` [3.0.0] y `adr/ADR-007-consolidacion-agente-unico.md` para el detalle completo del cambio de arquitectura. El historial completo de versiones 1.0.0 a 2.0.1 se conserva sin editar al final de `CHANGELOG.md`.
- **Desde v4.0.0 el kit dejó de ser "solo OpenCode".** Si vienes de una instalación v3.x, ver `CHANGELOG.md` [4.0.0] y `adr/ADR-011-multiplataforma-opencode-codex-vscode.md` para el detalle completo — tu proyecto sigue funcionando igual en OpenCode sin tocar nada; sumar Codex CLI o VS Code es opt-in, corriendo `scripts/adoptar-proyecto.sh --solo codex` (o `vscode`) en un proyecto ya existente.
- **Desde v4.2.0 Cronos puede delegar unidades temporales acotadas.** OpenCode usa `subagent_depth: 1` y
  `agent.cronos.permission.task: allow`; el límite operativo es de tres subagentes simultáneos. No
  se restauran los diez Titanes permanentes: Cronos conserva la autoridad, los checkpoints, la
  revisión final y la responsabilidad. Ver `adr/ADR-013-subagentes-temporales-controlados.md`.
