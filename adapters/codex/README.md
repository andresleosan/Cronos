# Adaptador: Codex CLI (OpenAI)

`config.toml.template` → se copia como `.codex/config.toml` en cada proyecto. **Verificado contra
documentación pública al 2026-08-03, no contra una sesión real con credenciales** — ver
`adr/ADR-011-multiplataforma-opencode-codex-vscode.md`, Contexto, y el encabezado del propio
template.

## Qué resuelve
- **Permisos/sandbox:** `approval_policy` (cuándo pide confirmación) + `sandbox_mode` (qué puede
  tocar técnicamente) — son dos controles separados, no lo confundas (ver comentarios del template).
- **Modelo:** `model` / `model_provider`, con `[model_providers.*]` para agregar cualquier
  proveedor compatible más allá de OpenAI — ver `MODELOS.md`, Paso 1, sección Codex CLI.
- **MCP:** bloque `[mcp_servers.<nombre>]` (Playwright de ejemplo, comentado por defecto).
- **Instrucciones:** Codex lee `AGENTS.md` de forma automática — global (`~/.codex/AGENTS.md`,
  instalado por `scripts/instalar-global.sh`) + el de la raíz del proyecto, concatenados. No hace
  falta declarar nada de esto en `config.toml`.

## Instalación global vs. por proyecto
- Global (una vez por máquina): `scripts/instalar-global.sh` → `~/.codex/` (`AGENTS.md`,
  `skills/`, `LECCIONES.md` referenciado desde `~/.cronos/`, ver `AGENCY.md`).
- Por proyecto: `scripts/nuevo-proyecto.sh` / `scripts/adoptar-proyecto.sh` copian este template
  como `.codex/config.toml`. Cambiar el modelo después: `scripts/elegir-modelo.sh` (detecta este
  archivo si existe en el proyecto).

## Diferencias honestas con el adaptador de OpenCode
- No hay equivalente exacto a `opencode debug agent cronos` para confirmar que las reglas de oro
  llegan al contexto real de una sesión — Codex tiene `/status` (muestra configuración activa) pero
  no un comando de depuración de instrucciones resueltas. Verifícalo tú mismo pidiéndole a Codex,
  en una sesión nueva, que liste las reglas de oro sin que se las repitas — mismo criterio que
  `README.md` (raíz del kit) ya exige para OpenCode.
- No hay comandos personalizados desde Markdown equivalentes a `commands/*.md` de OpenCode
  (`/cronos-continuar`, `/cronos-verificar-objetivo`) — Codex resuelve esto con **Skills**
  (formato `SKILL.md`, el mismo que ya usa `skills-custom/`), invocables con `$nombre-skill` o por
  activación automática. Si quieres el comportamiento exacto de esos dos comandos, pega su
  contenido tal cual como mensaje — están escritos para funcionar así en cualquier plataforma.
