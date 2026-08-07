#!/usr/bin/env bash
# Uso: ./adoptar-proyecto.sh [--force] [--dry-run] [--solo opencode|codex|vscode]
# Corre DESDE la carpeta del proyecto existente que quieras traer a la agencia.
# Por defecto configura las 3 plataformas soportadas - usa --solo para generar solo una.
# No requiere haber corrido scripts/instalar-global.sh antes (ver nuevo-proyecto.sh) pero se
# recomienda para tener también la capa global de OpenCode/Codex CLI.

set -e

FORCE=""
DRY_RUN=0
SOLO=""

ARGS=("$@")
i=0
while [ $i -lt ${#ARGS[@]} ]; do
  ARG="${ARGS[$i]}"
  case "$ARG" in
    --force) FORCE="--force" ;;
    --dry-run) DRY_RUN=1 ;;
    --solo) i=$((i+1)); SOLO="${ARGS[$i]:-}" ;;
  esac
  i=$((i+1))
done

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=./_lib-cronos.sh
. "$KIT_DIR/scripts/_lib-cronos.sh"
validar_plataforma "$SOLO"

OC_CRONOS="$HOME/.config/opencode/cronos"
if [ ! -f "$OC_CRONOS/MASTER_PROMPT.md" ]; then
  echo "AVISO: no encuentro una instalación global en $OC_CRONOS."
  echo "El proyecto se adopta igual (el núcleo se copia directo a .cronos/), pero para tener también"
  echo "la capa global de OpenCode/Codex CLI (defensa en profundidad), corre primero:"
  echo "  ./scripts/instalar-global.sh"
  echo ""
fi

VERSION_KIT="$(cat "$KIT_DIR/VERSION" 2>/dev/null || echo "?")"
PROYECTO_DIR="$(pwd)"

echo "Adoptando el proyecto actual ($PROYECTO_DIR) a la agencia Cronos v$VERSION_KIT..."
echo ""

if [ "$DRY_RUN" = "1" ]; then
  echo "--- DRY RUN: nada de esto se escribe en disco ---"

  if [ -f opencode.json ] && [ "$FORCE" != "--force" ]; then
    echo "opencode.json ya existe - se conservaría sin tocar (usa --force para sobrescribir)."
  fi
  if [ -f .codex/config.toml ] && [ "$FORCE" != "--force" ]; then
    echo ".codex/config.toml ya existe - se conservaría sin tocar (usa --force para sobrescribir)."
  fi
  if [ -f .github/copilot-instructions.md ] && [ "$FORCE" != "--force" ]; then
    echo ".github/copilot-instructions.md ya existe - se conservaría sin tocar (usa --force para sobrescribir)."
  fi

  if [ -z "$SOLO" ]; then
    echo "Se copiaría (para lo que no exista ya): opencode.json, .codex/config.toml, .github/copilot-instructions.md, .vscode/mcp.json"
  else
    echo "Se copiaría (--solo $SOLO, para lo que no exista ya)"
  fi
  echo "AGENTS.md + .cronos/ se copiarían/sincronizarían desde $KIT_DIR"

  if [ -f .gitignore ]; then
    echo ".gitignore ya existe - se conservaría sin tocar (usa --force para sobrescribir)."
  elif [ -f "$KIT_DIR/gitignore.template" ]; then
    echo ".gitignore       -> se copiaria desde gitignore.template"
  fi

  echo ".agencia-version -> $VERSION_KIT"
  echo ""
  echo "Corre sin --dry-run para aplicar esto de verdad."
  exit 0
fi

echo "Núcleo y configuración de plataforma:"
copiar_nucleo_local "$PROYECTO_DIR" "seed" "$FORCE"
crear_gaps_detectados "$PROYECTO_DIR"
copiar_config_plataformas "$PROYECTO_DIR" "$SOLO" "seed" "$FORCE"

if [ -f .gitignore ] && [ "$FORCE" != "--force" ]; then
  echo "  .gitignore                       -> ya existe, no lo toco"
elif [ -f "$KIT_DIR/gitignore.template" ]; then
  cp "$KIT_DIR/gitignore.template" .gitignore
  echo "  .gitignore                       -> copiado"
fi

echo "$VERSION_KIT" > .agencia-version
echo ""
echo "Proyecto adoptado."
echo "Recomendación: corre '/init' primero si no lo has hecho (OpenCode y Codex CLI lo soportan"
echo "igual; en VS Code/Copilot es '/init' o '/create-instructions'), para tener contexto real del repo."
