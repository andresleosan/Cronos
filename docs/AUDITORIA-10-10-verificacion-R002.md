# Verificación empírica de R-002 (capa de configuración) — 2026-07-16

Origen: `AUDITORIA-FINAL-10-10.md` (auditoría de madurez, C1). No reabre ningún ADR; es evidencia para una entrada de `RIESGOS.md` ya existente.

## Qué se probó

R-002 preguntaba, desde v1.3.0, si las reglas de oro de `AGENCY.md`/`MASTER_PROMPT.md` (declaradas como `instructions` en el `opencode.json` **global**, `~/.config/opencode/opencode.json`, según `scripts/instalar-global.sh`) sobreviven cuando cada proyecto tiene su propio `opencode.json` — copiado de `opencode.template.json`, que **no** declara `instructions` en absoluto.

## Cómo se probó

1. Se instaló el binario real: `npm install opencode-ai@1.18.3` (última versión disponible en el momento de esta prueba; el kit está verificado contra `1.17.15`, una minor detrás — sin cambios de esquema relevantes observados en `debug config`/`debug agent`).
2. Se replicó exactamente `scripts/instalar-global.sh` (pasos 2 y 5) en un `$HOME` aislado (`/home/claude/opencode-fake-home`), sin editar nada a mano:
   - Se copiaron los `.md` del núcleo (excepto `README.md` y los de gobierno: `GOBERNANZA.md`, `RIESGOS.md`, `ROADMAP.md`, `GUIA-PARA-PRINCIPIANTES.md`) a `~/.config/opencode/cronos/`.
   - Se generó `~/.config/opencode/opencode.json` con `instructions: [AGENCY.md, MASTER_PROMPT.md]`, tal como hace el script cuando el archivo global no existe todavía.
3. Se creó un proyecto nuevo (`/home/claude/proyecto-prueba`) y se copió `opencode.template.json` como su `opencode.json`, tal como indica el paso A3 de `MASTER_PROMPT.md` — sin agregar `instructions`.
4. Desde dentro del proyecto, se corrió `opencode debug config` y `opencode debug agent cronos`.

## Resultado

`opencode debug config`, corrido desde el proyecto, devuelve la configuración ya resuelta con:
```json
"instructions": [
  "/home/claude/opencode-fake-home/.config/opencode/cronos/AGENCY.md",
  "/home/claude/opencode-fake-home/.config/opencode/cronos/MASTER_PROMPT.md"
],
```
pese a que el `opencode.json` del proyecto no menciona `instructions`. También se confirmó, en el mismo comando, que los 12 patrones de `permission.bash` de `opencode.template.json` (incluyendo los anti-secretos de R-001: `cat *.env*`, `cat *secret*`, `cat *credential*`, `env`, `printenv*`, `history`) llegan intactos a la configuración resuelta del agente `cronos` vía `opencode debug agent cronos`.

**Conclusión de esta capa:** la configuración global y la de proyecto se fusionan; el `opencode.json` de proyecto no reemplaza ni descarta el `instructions` global. La ausencia de `instructions` en `opencode.template.json` es un diseño correcto (evita duplicar la ruta absoluta en cada proyecto), no un bug.

## Qué queda sin probar (y por qué no se puede hacer acá)

Esto confirma que OpenCode **le dice** al modelo que lea esos archivos. No confirma que el modelo los lea de verdad y los seiga — eso depende de la sesión real, con credenciales de un proveedor de modelo, algo que este entorno de auditoría no tiene y que no debe simularse (fabricar una respuesta de "Cronos" sin una sesión real de OpenCode sería exactamente el tipo de humo que el Principio 8 de `AGENCY.md` prohíbe).

### Paso pendiente, para correr en tu máquina (2 minutos, ver README.md § "Verificación recomendada")

1. `opencode debug agent cronos` en un proyecto real, para confirmar en tu propia instalación (con tu versión exacta de OpenCode) que los patrones de `permission.bash` piden confirmación de verdad al ejecutarlos — no solo que aparecen en la config resuelta.
2. En una sesión **nueva** de OpenCode (proyecto real, con tu modelo configurado), pedile a Cronos que liste las reglas de oro de `AGENCY.md` sin que se las repitas. Anota el resultado textual.

Con el resultado del punto 2, la entrada de R-002 en `RIESGOS.md` puede pasar de "abierto (capa de contenido)" a "cerrado" — pega la respuesta real (o un resumen fiel) como evidencia en esa entrada, con fecha y versión de OpenCode usada.
