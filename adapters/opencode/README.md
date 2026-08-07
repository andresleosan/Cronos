# Adaptador: OpenCode

`opencode.template.json` → se copia como `opencode.json` en cada proyecto. Desde v4.2.0 habilita
delegación temporal controlada, sin restaurar los Titanes permanentes; este adaptador es el único de los 3 verificado contra una
sesión real (`opencode debug agent cronos`, `opencode-ai` v1.18.3, ver
`docs/AUDITORIA-10-10-verificacion-R002.md`), no solo por documentación.

## Qué resuelve
- **Permisos/sandbox:** `permission.bash` — patrones `allow`/`ask`/`deny` sobre comandos de shell.
- **Subagentes:** `subagent_depth: 1` y `agent.cronos.permission.task: allow`. Cronos puede delegar
  hasta tres unidades acotadas, sin delegación anidada; el agente primario conserva checkpoints,
  aprobación y revisión final. Cada encargo debe repetir las reglas de seguridad y alcance de
  `AGENCY.md`.
- **Modelo:** campos `model` (raíz) y `agent.cronos.model` — ninguno de los dos viene declarado
  por defecto desde v4.0.2 (ver `CHANGELOG.md`): sin ellos, OpenCode usa el modelo que ya tengas
  seleccionado manualmente, sin forzar nada. Los agrega `scripts/elegir-modelo.sh` recién cuando
  se elige uno explícitamente (ver `MODELOS.md`, Paso 1, sección OpenCode).
- **MCP:** bloque `mcp.*` (Playwright incluido, `enabled: false` por defecto).
- **Instrucciones:** el core completo (`AGENCY.md`, `MASTER_PROMPT.md`) se carga vía `instructions`
  en el `opencode.json` **global** (`~/.config/opencode/opencode.json`, generado por
  `scripts/instalar-global.sh`) — confirmado que se fusiona con el `opencode.json` de cada
  proyecto, que no necesita declarar `instructions` propio.

## Instalación global vs. por proyecto
- Global (una vez por máquina): `scripts/instalar-global.sh` → `~/.config/opencode/`.
- Por proyecto: `scripts/nuevo-proyecto.sh` / `scripts/adoptar-proyecto.sh` copian este template
  como `opencode.json`. Cambiar el modelo después: `scripts/elegir-modelo.sh`.

## Verificación recomendada
Ver `README.md` (raíz del kit), sección "Verificación recomendada" — sigue vigente sin cambios.
