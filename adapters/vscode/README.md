# Adaptador: VS Code + GitHub Copilot

`copilot-instructions.template.md` → `.github/copilot-instructions.md`. `mcp.template.json` →
`.vscode/mcp.json`. **Verificado contra documentación pública al 2026-08-03, no contra una sesión
real** — ver `adr/ADR-011-multiplataforma-opencode-codex-vscode.md`, Contexto.

Interpretación de "VS Code" en este adaptador: **GitHub Copilot** (Chat/Agent mode), por ser el
único asistente de IA nativo de VS Code que no exige instalar una extensión de terceros. Si usas
otra extensión (Continue, Cline, la extensión de Codex, etc.), el `AGENTS.md` de la raíz del
proyecto sigue siendo tu mejor punto de partida — la mayoría de esas extensiones también lo leen —
pero `.github/copilot-instructions.md` y `.vscode/mcp.json` específicamente son de Copilot.

## Qué resuelve
- **Instrucciones:** doble mecanismo — `AGENTS.md` (raíz, lo lee VS Code nativamente) +
  `.github/copilot-instructions.md` (lo lee además cualquier superficie de Copilot fuera de VS
  Code). Ambos apuntan a `.cronos/` para el contenido completo.
- **MCP:** `.vscode/mcp.json`, clave `"servers"` (⚠️ distinta de `"mcpServers"`, que usan Claude
  Desktop/Cursor — si copias una config de otro lado, ese es el error más común). Para agregar
  Playwright cuando el proyecto lo necesite (ver skill `browser-qa-e2e`):
  ```json
  { "servers": { "playwright": { "command": "npx", "args": ["@playwright/mcp@latest"] } } }
  ```
  El estado habilitado/deshabilitado de un servidor MCP en VS Code se guarda aparte del archivo
  (comando `MCP: List Servers`), a diferencia de OpenCode/Codex CLI que sí lo declaran como campo
  en el propio JSON/TOML — por eso `mcp.template.json` arranca vacío en vez de con Playwright
  presente-pero-apagado.
- **Modelo:** sin archivo de proyecto — se elige en vivo desde el selector de modelos de la vista
  de Chat de Copilot. Incluye los modelos del plan de Copilot más cualquiera agregado vía BYOK
  (Bring Your Own Key: Anthropic, Gemini, OpenAI, OpenRouter, Azure, Ollama/Foundry Local — ver
  `MODELOS.md`, Paso 1, sección VS Code). Esto no es una restricción: es, de las 3 plataformas, la
  que menos fricción tiene para probar un modelo nuevo, porque no requiere editar ningún archivo.
- **Permisos:** VS Code pide confirmación por herramienta/comando dentro del chat (no hay un
  archivo `permission.bash` equivalente) — Agent mode es requisito para que las herramientas MCP
  sean visibles.

## Instalación global vs. por proyecto
**No hay instalación global para este adaptador.** GitHub Copilot no tiene, a la fecha de esta
verificación, un archivo de instrucciones de usuario que se pueda instalar por script y se fusione
de forma confiable con cada workspace, a diferencia de OpenCode y Codex CLI. Por eso `AGENTS.md` +
`.cronos/` (copiados por proyecto, ver `scripts/nuevo-proyecto.sh`) son, para esta plataforma, la
única fuente — no un respaldo. Si en el futuro Copilot suma un mecanismo global equivalente,
extender `scripts/instalar-global.sh` es el cambio correspondiente (déjalo anotado en `ROADMAP.md`
si lo detectas antes de la próxima revisión del kit).

## Diferencias honestas con el adaptador de OpenCode
- Sin equivalente a `opencode debug agent cronos`. Verifica tú mismo, en un chat nuevo, que
  Copilot puede listar las reglas de oro sin que se las repitas.
- Sin comandos personalizados con `$ARGUMENTS` como `commands/*.md` de OpenCode — el análogo más
  cercano es un archivo de *prompt* propio (`.github/prompts/*.prompts.md`), que no viene incluido
  en este adaptador por no estar verificado; el reemplazo simple es pegar el contenido de
  `commands/cronos-continuar.md` / `commands/cronos-verificar-objetivo.md` tal cual como mensaje.
