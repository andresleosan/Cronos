#!/usr/bin/env bash
# Uso: ./elegir-modelo.sh [--plataforma opencode|codex]
# Corre DESDE la carpeta del proyecto. Cambia el modelo activo en la configuración de la
# plataforma detectada en este proyecto (o la indicada con --plataforma, si hay más de una) sin
# recrear el proyecto ni perder configuración existente. Ver MODELOS.md para el criterio de qué
# modelo usar en cada fase - este script no lo decide, solo aplica el cambio que tú confirmes.
# Ninguna plataforma restringe qué modelo se puede escribir acá: se acepta cualquier string.
# VS Code/Copilot no tiene archivo de modelo que editar - se elige en vivo desde su selector, y
# este script no hace nada ahí salvo avisarlo.

set -e

MODELOS_MD=""
for D in ".cronos" "$HOME/.config/opencode/cronos" "$HOME/.codex/cronos"; do
  if [ -f "$D/MODELOS.md" ]; then MODELOS_MD="$D/MODELOS.md"; break; fi
done

PLATAFORMA_FORZADA=""
if [ "$1" = "--plataforma" ]; then PLATAFORMA_FORZADA="${2:-}"; fi

DISPONIBLES=""
[ -f opencode.json ] && DISPONIBLES="$DISPONIBLES opencode"
[ -f .codex/config.toml ] && DISPONIBLES="$DISPONIBLES codex"
VSCODE_PRESENTE=0
{ [ -f .github/copilot-instructions.md ] || [ -f .vscode/mcp.json ]; } && VSCODE_PRESENTE=1

if [ -z "$DISPONIBLES" ] && [ "$VSCODE_PRESENTE" = "0" ]; then
  echo "No encuentro configuración de ninguna plataforma soportada en esta carpeta"
  echo "(opencode.json, .codex/config.toml, .github/copilot-instructions.md, .vscode/mcp.json)."
  echo "Corre esto desde la raíz de un proyecto ya creado con scripts/nuevo-proyecto.sh o scripts/adoptar-proyecto.sh."
  exit 1
fi

PLATAFORMA="$PLATAFORMA_FORZADA"
if [ -z "$PLATAFORMA" ] && [ -n "$DISPONIBLES" ]; then
  CANTIDAD=$(echo "$DISPONIBLES" | wc -w)
  if [ "$CANTIDAD" -eq 1 ]; then
    PLATAFORMA="$(echo "$DISPONIBLES" | xargs)"
  else
    echo "Este proyecto tiene configuración de más de una plataforma:$DISPONIBLES"
    read -r -p "¿Cuál quieres actualizar (opencode/codex)? " PLATAFORMA
  fi
fi

if [ -n "$MODELOS_MD" ]; then
  echo "Criterio de qué modelo conviene en cada fase: $MODELOS_MD"
else
  echo "No encuentro MODELOS.md (ni en .cronos/ ni en una instalación global) - el criterio por fase vive en ese archivo del kit."
fi
echo ""

case "$PLATAFORMA" in
  opencode)
    [ -f opencode.json ] || { echo "No hay opencode.json en este proyecto."; exit 1; }
    command -v jq >/dev/null 2>&1 || { echo "Este script necesita 'jq' instalado para OpenCode. En Debian/Ubuntu: sudo apt install jq"; exit 1; }
    ACTUAL="$(jq -r '.model // "(no declarado)"' opencode.json)"
    echo "[OpenCode] Modelo activo en este proyecto: $ACTUAL"
    echo ""
    if command -v opencode >/dev/null 2>&1; then
      echo "Modelos disponibles ahora mismo (según 'opencode models'):"
      opencode models 2>/dev/null || echo "  (no se pudo consultar - revisa que 'opencode auth list' tenga al menos un proveedor conectado)"
      echo ""
    else
      echo "No encuentro el binario 'opencode' en el PATH - no puedo listar modelos en vivo."
      echo "Instálalo o consulta manualmente qué modelos tienes disponibles."
      echo ""
    fi
    read -r -p "Modelo nuevo (string exacto tal como aparece en 'opencode models', o Enter para cancelar): " NUEVO
    if [ -z "$NUEVO" ]; then echo "Cancelado. No se modificó nada."; exit 0; fi
    cp opencode.json "opencode.json.bak-$(date +%Y%m%d-%H%M%S)"
    jq --arg m "$NUEVO" '.model = $m | if .agent.cronos then .agent.cronos.model = $m else . end' opencode.json > opencode.json.tmp
    mv opencode.json.tmp opencode.json
    echo ""
    echo "Modelo actualizado a: $NUEVO"
    echo "(se guardó un backup del archivo anterior por si hace falta revertir)"
    ;;
  codex)
    [ -f .codex/config.toml ] || { echo "No hay .codex/config.toml en este proyecto."; exit 1; }
    ACTUAL_MODEL="$(grep -E '^model[[:space:]]*=' .codex/config.toml | head -1 | sed -E 's/^model[[:space:]]*=[[:space:]]*"([^"]*)".*/\1/')"
    ACTUAL_PROVIDER="$(grep -E '^model_provider[[:space:]]*=' .codex/config.toml | head -1 | sed -E 's/^model_provider[[:space:]]*=[[:space:]]*"([^"]*)".*/\1/')"
    echo "[Codex CLI] Modelo activo en este proyecto: ${ACTUAL_MODEL:-(no declarado)} (proveedor: ${ACTUAL_PROVIDER:-(no declarado)})"
    echo ""
    echo "Codex CLI no tiene un comando de terminal para listar modelos fuera de una sesión."
    echo "Dentro de una sesión de Codex, corre \"/model\" para ver el selector con todo lo disponible"
    echo "(incluye cualquier proveedor personalizado que hayas declarado en [model_providers.*] acá abajo)."
    if grep -qE '^\[model_providers\.' .codex/config.toml; then
      echo ""
      echo "Proveedores personalizados ya declarados en este archivo:"
      grep -E '^\[model_providers\.' .codex/config.toml
    fi
    echo ""
    read -r -p "Modelo nuevo (string exacto tal como aparece en el selector \"/model\", o Enter para cancelar): " NUEVO
    if [ -z "$NUEVO" ]; then echo "Cancelado. No se modificó nada."; exit 0; fi
    read -r -p "Proveedor (model_provider - Enter para dejar '${ACTUAL_PROVIDER:-sin declarar, usa el de tu cuenta}' sin cambios): " NUEVO_PROVIDER
    NUEVO_PROVIDER="${NUEVO_PROVIDER:-$ACTUAL_PROVIDER}"
    cp .codex/config.toml ".codex/config.toml.bak-$(date +%Y%m%d-%H%M%S)"
    # Reemplazo de línea completa, no parseo TOML - valido porque model/model_provider son
    # asignaciones escalares de una sola línea sin comentario inline en este template (ver
    # adapters/codex/config.toml.template).
    # Reemplaza la línea (activa o comentada, ver adapters/codex/config.toml.template desde v4.0.2)
    # si existe; si no existe ninguna, la inserta junto al encabezado de la sección Modelo — tiene
    # que quedar ANTES de cualquier [tabla] del archivo, porque en TOML una clave suelta después de
    # un [tabla] pertenece a esa tabla, no a la raíz, y agregarla al final del archivo rompería la
    # configuración en silencio.
    if grep -qE '^#?[[:space:]]*model[[:space:]]*=' .codex/config.toml; then
      sed -i -E "s/^#?[[:space:]]*model[[:space:]]*=.*/model = \"$NUEVO\"/" .codex/config.toml
    else
      sed -i "/── Modelo ───/a model = \"$NUEVO\"" .codex/config.toml
    fi
    if [ -n "$NUEVO_PROVIDER" ]; then
      if grep -qE '^#?[[:space:]]*model_provider[[:space:]]*=' .codex/config.toml; then
        sed -i -E "s/^#?[[:space:]]*model_provider[[:space:]]*=.*/model_provider = \"$NUEVO_PROVIDER\"/" .codex/config.toml
      else
        sed -i "/── Modelo ───/a model_provider = \"$NUEVO_PROVIDER\"" .codex/config.toml
      fi
    fi
    echo ""
    echo "Modelo actualizado a: $NUEVO (proveedor: ${NUEVO_PROVIDER:-sin cambios})"
    echo "(se guardó un backup del archivo anterior por si hace falta revertir)"
    echo "Verificalo dentro de una sesión de Codex con \"/status\"."
    ;;
  "")
    echo "No pude determinar la plataforma a editar."
    ;;
  *)
    echo "Plataforma no reconocida: '$PLATAFORMA' (uso: opencode|codex)."
    exit 1
    ;;
esac

if [ "$VSCODE_PRESENTE" = "1" ]; then
  echo ""
  echo "Este proyecto también tiene configuración de VS Code (Copilot): ese modelo no se toca desde"
  echo "este script — se elige en vivo desde el selector de modelos de la vista de Chat de Copilot."
fi
