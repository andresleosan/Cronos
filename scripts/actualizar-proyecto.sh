#!/usr/bin/env bash
# Uso: ./actualizar-proyecto.sh [--dry-run] [--solo opencode|codex|vscode]
# Corre DESDE la carpeta de un proyecto ya adoptado/creado con esta agencia (tiene .agencia-version).
# Trae mejoras del core (AGENTS.md, .cronos/, y la config de cada plataforma presente en el
# proyecto) SIN tocar BRIEF.md, STACK.md, tasks.md, código. Por defecto actualiza la config de las
# 3 plataformas si están presentes - usa --solo para limitarlo a una.

set -e

DRY_RUN=0
SOLO=""
ARGS=("$@")
i=0
while [ $i -lt ${#ARGS[@]} ]; do
  ARG="${ARGS[$i]}"
  case "$ARG" in
    --dry-run) DRY_RUN=1 ;;
    --solo) i=$((i+1)); SOLO="${ARGS[$i]:-}" ;;
  esac
  i=$((i+1))
done

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=./_lib-cronos.sh
. "$KIT_DIR/scripts/_lib-cronos.sh"
validar_plataforma "$SOLO"

if [ ! -f "$KIT_DIR/VERSION" ]; then
  echo "No encuentro VERSION en el kit fuente ($KIT_DIR)."
  exit 1
fi

if [ ! -f .agencia-version ]; then
  echo "Este proyecto no tiene .agencia-version - no parece haber sido creado con esta agencia."
  echo "Usa scripts/adoptar-proyecto.sh en cambio."
  exit 1
fi

VERSION_PROYECTO="$(cat .agencia-version)"
VERSION_KIT="$(cat "$KIT_DIR/VERSION")"
PROYECTO_DIR="$(pwd)"

echo "Proyecto en versión: $VERSION_PROYECTO"
echo "Core del kit en versión: $VERSION_KIT"

if [ "$VERSION_PROYECTO" = "$VERSION_KIT" ]; then
  echo "Ya estás en la última versión del core. Nada que actualizar."
  exit 0
fi

echo ""
echo "Cambios que se aplicarían:"

mostrar_diff() {
  # $1 = archivo del proyecto ; $2 = template del kit ; $3 = nombre a mostrar
  [ -f "$1" ] || { echo "  $3: no existe en este proyecto (se omite, no se crea acá - usa adoptar-proyecto.sh)"; return; }
  [ -f "$2" ] || return
  if diff -q "$1" "$2" > /dev/null 2>&1; then
    echo "  $3: sin cambios"
  else
    echo "  $3: hay diferencias (se sobrescribe con el template actual)"
    diff -u "$1" "$2" || true
  fi
}

CONFIGURAR="$PLATAFORMAS_VALIDAS"
[ -n "$SOLO" ] && CONFIGURAR="$SOLO"
for P in $CONFIGURAR; do
  case "$P" in
    opencode) mostrar_diff "opencode.json" "$KIT_DIR/adapters/opencode/opencode.template.json" "opencode.json" ;;
    codex) mostrar_diff ".codex/config.toml" "$KIT_DIR/adapters/codex/config.toml.template" ".codex/config.toml" ;;
    vscode)
      mostrar_diff ".github/copilot-instructions.md" "$KIT_DIR/adapters/vscode/copilot-instructions.template.md" ".github/copilot-instructions.md"
      mostrar_diff ".vscode/mcp.json" "$KIT_DIR/adapters/vscode/mcp.template.json" ".vscode/mcp.json"
      ;;
  esac
done

CAMBIOS_NUCLEO=0
if [ -d .cronos ]; then
  for f in AGENCY.md MASTER_PROMPT.md SKILLS.md MODELOS.md LOOPS.md; do
    diff -q ".cronos/$f" "$KIT_DIR/$f" > /dev/null 2>&1 || CAMBIOS_NUCLEO=$((CAMBIOS_NUCLEO+1))
  done
  [ "$CAMBIOS_NUCLEO" -gt 0 ] && echo "  .cronos/: $CAMBIOS_NUCLEO archivo(s) del núcleo con diferencias (se sincronizan)" || echo "  .cronos/: sin cambios en los archivos principales"
else
  echo "  .cronos/: no existe en este proyecto todavía (se crea)"
fi

mostrar_diff "AGENTS.md" "$KIT_DIR/AGENTS.md" "AGENTS.md"

if [ -f .gitignore ] && [ -f "$KIT_DIR/gitignore.template" ]; then
  mostrar_diff ".gitignore" "$KIT_DIR/gitignore.template" ".gitignore"
fi

if [ "$DRY_RUN" = "1" ]; then
  echo ""
  echo "--- DRY RUN: nada se escribió en disco ---"
  exit 0
fi

echo ""
read -r -p "¿Aplicar estos cambios? (s/N): " CONFIRMA
case "$CONFIRMA" in
  s|S|si|Si|SI|sí|Sí) ;;
  *) echo "Cancelado."; exit 0 ;;
esac

copiar_nucleo_local "$PROYECTO_DIR" "sync" "--force"
copiar_config_plataformas "$PROYECTO_DIR" "$SOLO" "sync" "--force"

if [ -f "$KIT_DIR/gitignore.template" ]; then
  cp "$KIT_DIR/gitignore.template" .gitignore
  echo "  .gitignore                       -> actualizado"
fi

echo "$VERSION_KIT" > .agencia-version
echo ""
echo "Proyecto actualizado a v$VERSION_KIT."
echo "Revisa $KIT_DIR/CHANGELOG.md para ver qué cambió exactamente."
