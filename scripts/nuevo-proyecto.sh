#!/usr/bin/env bash
# Uso: ./nuevo-proyecto.sh nombre-del-proyecto [--force] [--dry-run] [--solo opencode|codex|vscode]
# Por defecto configura las 3 plataformas soportadas (ver adr/ADR-011) - usa --solo para generar
# solo una. No requiere haber corrido scripts/instalar-global.sh antes (el núcleo se copia directo
# desde este kit a .cronos/ del proyecto) pero SE RECOMIENDA correrlo igual: en OpenCode y Codex CLI
# suma una capa global de las reglas de oro, además de la que ya queda en el proyecto.
# --dry-run: muestra que se crearía sin tocar el disco.

set -e

if [ -z "$1" ] || [ "${1#--}" != "$1" ]; then
  echo "Uso: ./nuevo-proyecto.sh nombre-del-proyecto [--force] [--dry-run] [--solo opencode|codex|vscode]"
  if [ -n "$1" ]; then
    echo "(Recibí '$1' como nombre de proyecto, pero empieza con '--' — seguro te faltó poner el nombre antes de las opciones.)"
  fi
  exit 1
fi

PROYECTO="$1"

# Carpeta donde se crean los proyectos nuevos: por defecto, la carpeta actual (desde donde corres
# este comando). Si prefieres una carpeta fija propia (ej. un disco de respaldo), define la variable
# de entorno CRONOS_PROYECTOS_DIR antes de correr este script, por ejemplo agregando a tu
# ~/.bashrc: export CRONOS_PROYECTOS_DIR="/f/Proyectos"
BASE_DIR="${CRONOS_PROYECTOS_DIR:-$(pwd)}"

# Ruta completa del proyecto
PROYECTO_DIR="$BASE_DIR/$PROYECTO"

FORCE=""
DRY_RUN=0
SOLO=""

ARGS=("${@:2}")
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
  echo "El proyecto se crea igual (el núcleo se copia directo a .cronos/), pero para tener también"
  echo "la capa global de OpenCode/Codex CLI (defensa en profundidad, ver AGENCY.md Principio 6),"
  echo "corre primero: ./scripts/instalar-global.sh"
  echo ""
fi

if [ "$DRY_RUN" = "1" ]; then
  echo "--- DRY RUN: nada de esto se escribe en disco ---"
  echo "Se crearía la carpeta '$PROYECTO_DIR/' con:"
  echo "  docs/  src/"

  [ -f "$PROYECTO_DIR/BRIEF.md" ] && [ "$FORCE" != "--force" ] \
    && echo "  BRIEF.md         -> ya existe, se conservaría" \
    || echo "  BRIEF.md         -> se crearía vacío"

  [ -f "$PROYECTO_DIR/tasks.md" ] && [ "$FORCE" != "--force" ] \
    && echo "  tasks.md         -> ya existe, se conservaría" \
    || echo "  tasks.md         -> se crearía"

  echo "  AGENTS.md + .cronos/ -> se copiarían desde $KIT_DIR (núcleo, versión $(cat "$KIT_DIR/VERSION" 2>/dev/null || echo "?"))"

  if [ -z "$SOLO" ]; then
    echo "  opencode.json, .codex/config.toml, .github/copilot-instructions.md, .vscode/mcp.json -> se copiarían (las 3 plataformas; usa --solo para generar solo una)"
  else
    echo "  configuración de '$SOLO' -> se copiaría (--solo)"
  fi

  [ -f "$PROYECTO_DIR/.gitignore" ] && [ "$FORCE" != "--force" ] \
    && echo "  .gitignore       -> ya existe, se conservaría" \
    || echo "  .gitignore       -> se copiaría desde gitignore.template"

  echo "  .agencia-version -> $(cat "$KIT_DIR/VERSION" 2>/dev/null || echo "sin VERSION en el kit")"

  [ ! -d "$PROYECTO_DIR/.git" ] && echo "  .git/            -> se inicializaría (git init)"

  echo ""
  echo "Corre sin --dry-run para aplicar esto de verdad."
  exit 0
fi

if [ -d "$PROYECTO_DIR" ] && [ -n "$(ls -A "$PROYECTO_DIR" 2>/dev/null)" ] && [ "$FORCE" != "--force" ]; then
  echo "La carpeta '$PROYECTO_DIR' ya existe y no está vacía."

  read -r -p "BRIEF.md, tasks.md y la configuración de plataforma podrían sobrescribirse. ¿Continuar? (s/N): " CONFIRMA

  case "$CONFIRMA" in
    s|S|si|Si|SI|sí|Sí) ;;
    *) echo "Cancelado. No se modificó nada."; exit 1 ;;
  esac
fi

mkdir -p "$PROYECTO_DIR/docs" "$PROYECTO_DIR/src"

if [ -f "$PROYECTO_DIR/BRIEF.md" ] && [ "$FORCE" != "--force" ]; then
  echo "Ya existe $PROYECTO_DIR/BRIEF.md - no lo toco."
else
  touch "$PROYECTO_DIR/BRIEF.md"
fi

if [ -f "$PROYECTO_DIR/tasks.md" ] && [ "$FORCE" != "--force" ]; then
  echo "Ya existe $PROYECTO_DIR/tasks.md - no lo toco."
else
  echo "# Tareas — $PROYECTO" > "$PROYECTO_DIR/tasks.md"
fi

echo "Núcleo y configuración de plataforma:"
copiar_nucleo_local "$PROYECTO_DIR" "seed" "$FORCE"
crear_gaps_detectados "$PROYECTO_DIR"
copiar_config_plataformas "$PROYECTO_DIR" "$SOLO" "seed" "$FORCE"

if [ -f "$KIT_DIR/gitignore.template" ]; then
  if [ -f "$PROYECTO_DIR/.gitignore" ] && [ "$FORCE" != "--force" ]; then
    echo "  .gitignore                       -> ya existe, no lo toco"
  else
    cp "$KIT_DIR/gitignore.template" "$PROYECTO_DIR/.gitignore"
    echo "  .gitignore                       -> copiado"
  fi
fi

if [ -f "$KIT_DIR/VERSION" ]; then
  cp "$KIT_DIR/VERSION" "$PROYECTO_DIR/.agencia-version"
fi

cd "$PROYECTO_DIR"

if [ ! -d .git ]; then
  git init -q
fi

echo ""
echo "Proyecto '$PROYECTO' listo."
echo "Ubicación:"
echo "  $PROYECTO_DIR"
echo ""
echo "Siguiente paso (según la plataforma que vayas a usar):"
echo "  cd \"$PROYECTO_DIR\""
[ -f "$PROYECTO_DIR/opencode.json" ] && echo "  opencode          # OpenCode"
[ -f "$PROYECTO_DIR/.codex/config.toml" ] && echo "  codex             # Codex CLI"
[ -f "$PROYECTO_DIR/.github/copilot-instructions.md" ] && echo "  code .            # VS Code — abrí Copilot Chat en modo Agent"
