#!/usr/bin/env bash
# Funciones compartidas entre nuevo-proyecto.sh, adoptar-proyecto.sh y actualizar-proyecto.sh.
# Se source-ea, no se ejecuta directo. Mantener esto en un solo lugar evita que los 3 scripts
# diverjan entre sí sobre qué se copia y desde dónde (ver RIESGOS.md, categoría "duplicidad").
# Requiere que la variable KIT_DIR ya esté definida por el script que la source-ea.

PLATAFORMAS_VALIDAS="opencode codex vscode"

validar_plataforma() {
  # $1 = valor de --solo a validar. Vacío es válido (significa "las 3").
  [ -z "$1" ] && return 0
  for P in $PLATAFORMAS_VALIDAS; do
    [ "$1" = "$P" ] && return 0
  done
  echo "Valor de --solo no reconocido: '$1' (uso: opencode|codex|vscode)"
  exit 1
}

copiar_config_una_plataforma() {
  # $1=plataforma  $2=carpeta del proyecto  $3=modo (seed|sync)  $4=--force o vacío
  # seed: no pisa un archivo que ya exista salvo --force (nuevo-proyecto.sh, adoptar-proyecto.sh)
  # sync: siempre actualiza (actualizar-proyecto.sh, tras su propio checkpoint de confirmación)
  P="$1"; DIR="$2"; MODO="$3"; FORCE="$4"
  case "$P" in
    opencode)
      DEST="$DIR/opencode.json"
      if [ "$MODO" = "seed" ] && [ -f "$DEST" ] && [ "$FORCE" != "--force" ]; then
        echo "  opencode.json                    -> ya existe, no lo toco"
      else
        cp "$KIT_DIR/adapters/opencode/opencode.template.json" "$DEST"
        [ "$MODO" = "sync" ] && echo "  opencode.json                    -> actualizado" || echo "  opencode.json                    -> copiado"
      fi
      ;;
    codex)
      mkdir -p "$DIR/.codex"
      DEST="$DIR/.codex/config.toml"
      if [ "$MODO" = "seed" ] && [ -f "$DEST" ] && [ "$FORCE" != "--force" ]; then
        echo "  .codex/config.toml               -> ya existe, no lo toco"
      else
        cp "$KIT_DIR/adapters/codex/config.toml.template" "$DEST"
        [ "$MODO" = "sync" ] && echo "  .codex/config.toml               -> actualizado" || echo "  .codex/config.toml               -> copiado"
      fi
      ;;
    vscode)
      mkdir -p "$DIR/.github" "$DIR/.vscode"
      DEST1="$DIR/.github/copilot-instructions.md"
      if [ "$MODO" = "seed" ] && [ -f "$DEST1" ] && [ "$FORCE" != "--force" ]; then
        echo "  .github/copilot-instructions.md  -> ya existe, no lo toco"
      else
        cp "$KIT_DIR/adapters/vscode/copilot-instructions.template.md" "$DEST1"
        [ "$MODO" = "sync" ] && echo "  .github/copilot-instructions.md  -> actualizado" || echo "  .github/copilot-instructions.md  -> copiado"
      fi
      DEST2="$DIR/.vscode/mcp.json"
      if [ "$MODO" = "seed" ] && [ -f "$DEST2" ] && [ "$FORCE" != "--force" ]; then
        echo "  .vscode/mcp.json                 -> ya existe, no lo toco"
      else
        cp "$KIT_DIR/adapters/vscode/mcp.template.json" "$DEST2"
        [ "$MODO" = "sync" ] && echo "  .vscode/mcp.json                 -> actualizado" || echo "  .vscode/mcp.json                 -> copiado"
      fi
      ;;
    *)
      echo "  (plataforma desconocida: $P, se omite)"
      ;;
  esac
}

copiar_config_plataformas() {
  # $1=carpeta del proyecto  $2=--solo <plataforma> o vacío (las 3)  $3=modo (seed|sync)  $4=--force o vacío
  DIR="$1"; SOLO="$2"; MODO="$3"; FORCE="$4"
  if [ -z "$SOLO" ]; then
    for P in $PLATAFORMAS_VALIDAS; do copiar_config_una_plataforma "$P" "$DIR" "$MODO" "$FORCE"; done
  else
    copiar_config_una_plataforma "$SOLO" "$DIR" "$MODO" "$FORCE"
  fi
}

crear_gaps_detectados() {
  # $1=carpeta del proyecto — estado del proyecto (como BRIEF.md/tasks.md), NUNCA se sincroniza
  # desde actualizar-proyecto.sh una vez creado. Ver adr/ADR-012 y self-critique-loop paso 6.
  DIR="$1"
  DEST="$DIR/.cronos/gaps-detectados.md"
  if [ -f "$DEST" ]; then
    return
  fi
  mkdir -p "$DIR/.cronos"
  cat > "$DEST" <<'EOF'
# Gaps detectados en este proyecto

Registro de trabajo de Cronos, no la lección final (esa vive en `~/.cronos/LECCIONES.md`, ver
`skills-custom/capability-gap-analysis/SKILL.md`). Una línea por cada vez que una tarea reveló que
faltaba una skill o criterio que ninguna skill existente cubría bien (ver `self-critique-loop`,
paso 6). Antes de agregar una entrada, revisa si ya hay una parecida acá abajo — la segunda vez que
aparece el mismo tipo de gap es la señal para activar `capability-gap-analysis` dentro de este
proyecto, sin esperar al cierre.

Formato sugerido: `- AAAA-MM-DD — tarea "…" — qué faltó, en una frase.`
EOF
}

copiar_nucleo_local() {
  # $1=carpeta del proyecto  $2=modo (seed|sync)  $3=--force o vacío
  # El contenido de .cronos/ en sí SIEMPRE se refresca (nunca se hand-edita, ver adr/ADR-011) -
  # el modo solo afecta a AGENTS.md, que sí sigue el mismo criterio que opencode.json.
  DIR="$1"; MODO="$2"; FORCE="$3"
  mkdir -p "$DIR/.cronos/skills"
  for f in AGENCY.md MASTER_PROMPT.md SKILLS.md MODELOS.md LOOPS.md; do
    cp "$KIT_DIR/$f" "$DIR/.cronos/$f"
  done
  for SKILL_DIR in "$KIT_DIR"/skills-custom/*/; do
    SKILL_NAME="$(basename "$SKILL_DIR")"
    rm -rf "${DIR:?}/.cronos/skills/$SKILL_NAME"
    cp -r "$SKILL_DIR" "$DIR/.cronos/skills/"
  done
  if [ "$MODO" = "sync" ]; then
    echo "  .cronos/                         -> núcleo actualizado (versión $(cat "$KIT_DIR/VERSION"))"
  else
    echo "  .cronos/                         -> núcleo copiado (versión $(cat "$KIT_DIR/VERSION"))"
  fi
  if [ "$MODO" = "seed" ] && [ -f "$DIR/AGENTS.md" ] && [ "$FORCE" != "--force" ]; then
    echo "  AGENTS.md                        -> ya existe, no lo toco"
  else
    cp "$KIT_DIR/AGENTS.md" "$DIR/AGENTS.md"
    [ "$MODO" = "sync" ] && echo "  AGENTS.md                        -> actualizado" || echo "  AGENTS.md                        -> copiado"
  fi
}
