# adapters/ — Mecánica específica de cada plataforma soportada

Ver `adr/ADR-011-multiplataforma-opencode-codex-vscode.md` para el porqué completo. Resumen: el
**núcleo** de Cronos (`AGENCY.md`, `MASTER_PROMPT.md`, `SKILLS.md`, `MODELOS.md`, `LOOPS.md`,
`skills-custom/*`, `AGENTS.md`) describe qué hace Cronos y con qué criterio, sin ninguna mención a
un runtime concreto. Cada carpeta de acá abajo traduce esas mismas reglas a la mecánica real de una
plataforma — selección de modelo, permisos/sandbox, MCP — sin copiar ni reinterpretar el criterio
de fondo.

| Adaptador | Plataforma | Archivo(s) que genera en el proyecto |
|---|---|---|
| [`opencode/`](opencode/) | [OpenCode](https://opencode.ai) | `opencode.json` |
| [`codex/`](codex/) | [Codex CLI](https://developers.openai.com/codex) (OpenAI) | `.codex/config.toml` |
| [`vscode/`](vscode/) | VS Code + GitHub Copilot | `.github/copilot-instructions.md`, `.vscode/mcp.json` |

## Qué NO hay acá

- **Los 10 Titanes permanentes de las versiones anteriores.** Desde v4.2.0 Cronos puede usar
  subagentes temporales cuando el runtime los soporte, pero siguen siendo herramientas de ejecución:
  no reciben autoridad, no leen secretos, no modifican Git, no despliegan, no migran y no aprueban.
- **Una lista abierta de plataformas.** Son exactamente 3, con necesidad real confirmada cada una
  (ver `adr/ADR-011`, sección Contexto). Agregar una cuarta requiere el mismo tipo de decisión
  deliberada — no se agrega "porque se puede".
- **Copias del núcleo.** Si encontrás contenido de criterio (cuándo usar una skill, qué es un
  hallazgo crítico) dentro de un adaptador en vez de en el núcleo, es un bug — repórtalo. Un
  adaptador solo traduce mecánica.
- **Verificación empírica contra una sesión real con credenciales de modelo**, salvo el de OpenCode
  (`docs/AUDITORIA-10-10-verificacion-R002.md`, corrido contra `opencode-ai` v1.18.3). Los de Codex
  CLI y VS Code están verificados contra documentación pública vigente al 2026-08-03 — cada `README.md`
  de adaptador dice contra qué exactamente. Confirma contra tu propia instalación antes de confiar a
  ciegas, mismo criterio que ya exige `AGENCY.md` para todo lo demás.

## Cómo se instalan

- **Instalación global** (`scripts/instalar-global.sh`): instala el núcleo + los adaptadores de
  OpenCode y Codex CLI a `~/.config/opencode/` y `~/.codex/` respectivamente — ambas plataformas
  tienen un mecanismo de instrucciones global verificado (o verificable por documentación) que se
  fusiona con lo que haya en cada proyecto. VS Code/Copilot no tiene un archivo de instrucciones
  global igual de confiable y scripteable — por eso su adaptador no se instala globalmente, solo
  por proyecto (ver `adapters/vscode/README.md`).
- **Por proyecto** (`scripts/nuevo-proyecto.sh`, `scripts/adoptar-proyecto.sh`): copia el archivo de
  configuración de la(s) plataforma(s) elegida(s) desde el `.template` correspondiente, más una
  copia local del núcleo en `.cronos/` dentro del proyecto (necesaria para que el proyecto funcione
  de forma autosuficiente en VS Code, y como defensa en profundidad para las otras dos). Por
  defecto configura las 3 — usa `--solo <plataforma>` para generar solo una.
- **Actualización** (`scripts/actualizar-proyecto.sh`): trae la versión más reciente de los
  adaptadores y de `.cronos/` a un proyecto ya creado, sin tocar lo específico del proyecto.
