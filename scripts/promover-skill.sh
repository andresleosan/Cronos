#!/usr/bin/env bash
# Uso: ./promover-skill.sh /ruta/a/la/skill-local [--force]
# Promueve una skill de un proyecto (típicamente .cronos/skills/<nombre>/) al catálogo global: la
# copia a skills-custom/ del kit fuente y a los directorios globales de OpenCode/Codex CLI que ya
# existan, y deja una fila "pendiente de revisión" en SKILLS.md. Ver adr/ADR-012 y
# skills-custom/capability-gap-analysis/SKILL.md, "Promoción a skill global".
#
# Este script NO pregunta si corresponde promover — esa confirmación ya tiene que haber pasado
# antes, en la conversación con el operador (ver capability-gap-analysis). Correrlo es, en sí
# mismo, la acción que ya se confirmó, no un segundo checkpoint.

set -e

FORCE=""
ORIGEN=""
for ARG in "$@"; do
  case "$ARG" in
    --force) FORCE="--force" ;;
    *) ORIGEN="$ARG" ;;
  esac
done

if [ -z "$ORIGEN" ]; then
  echo "Uso: ./promover-skill.sh /ruta/a/la/skill-local [--force]"
  echo "Ejemplo: ./promover-skill.sh /f/Proyectos/mi-app/.cronos/skills/rate-limiting-criteria"
  exit 1
fi

ORIGEN="${ORIGEN%/}"

if [ ! -f "$ORIGEN/SKILL.md" ]; then
  echo "No encuentro $ORIGEN/SKILL.md — dame la ruta a la CARPETA de la skill, no al archivo."
  exit 1
fi

# Resuelve a ruta absoluta ANTES de calcular de qué proyecto viene — si ORIGEN llega como ruta
# relativa (lo más común, ej. ".cronos/skills/nombre" corrido desde dentro del proyecto), calcular
# el proyecto de origen con dirname sobre una ruta relativa da "." en vez del nombre real.
ORIGEN="$(cd "$ORIGEN" && pwd)"

NOMBRE="$(basename "$ORIGEN")"
KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROYECTO_ORIGEN="$(basename "$(dirname "$(dirname "$(dirname "$ORIGEN")")")" 2>/dev/null)"
[ -z "$PROYECTO_ORIGEN" ] && PROYECTO_ORIGEN="desconocido"

# Validación mínima del frontmatter — no reemplaza una lectura humana del contenido, solo confirma
# que el archivo tiene la forma esperada antes de copiarlo a todos lados.
if ! head -n 1 "$ORIGEN/SKILL.md" | grep -q '^---$'; then
  echo "AVISO: $ORIGEN/SKILL.md no empieza con el frontmatter '---' esperado — revísalo a mano antes de seguir."
fi
if ! grep -q '^name:' "$ORIGEN/SKILL.md"; then
  echo "FALLO: $ORIGEN/SKILL.md no tiene un campo 'name:' en el frontmatter. No lo promuevo así."
  exit 1
fi
if ! grep -q '^description:' "$ORIGEN/SKILL.md"; then
  echo "FALLO: $ORIGEN/SKILL.md no tiene un campo 'description:' en el frontmatter."
  echo "Sin eso, ninguna plataforma la va a activar sola. No lo promuevo así."
  exit 1
fi

echo "Promoviendo '$NOMBRE' (desde el proyecto '$PROYECTO_ORIGEN') a skill global."
echo ""

promover_a() {
  DEST="$1"
  ETIQUETA="$2"
  if [ -d "$DEST/$NOMBRE" ] && [ "$FORCE" != "--force" ]; then
    read -r -p "Ya existe una skill '$NOMBRE' en $ETIQUETA. ¿Sobrescribirla? (s/N): " CONFIRMA
    case "$CONFIRMA" in
      s|S|si|Si|SI|sí|Sí) ;;
      *) echo "  $ETIQUETA -> omitido"; return ;;
    esac
  fi
  mkdir -p "$DEST"
  rm -rf "${DEST:?}/${NOMBRE:?}"
  cp -r "$ORIGEN" "$DEST/"
  echo "  $ETIQUETA -> copiada a $DEST/$NOMBRE"
}

# Kit fuente (permanente — sobrevive a reinstalaciones y llega a proyectos futuros vía instalar-global.sh)
promover_a "$KIT_DIR/skills-custom" "kit fuente (skills-custom/)"

# Globales, solo si ya existen (si no, es que instalar-global.sh no corrió todavía para esa plataforma)
[ -d "$HOME/.config/opencode/skills" ] && promover_a "$HOME/.config/opencode/skills" "OpenCode global"
[ -d "$HOME/.codex/skills" ] && promover_a "$HOME/.codex/skills" "Codex CLI global"

# Fila pendiente de revisión en SKILLS.md del kit fuente
MARCADOR="<!-- scripts/promover-skill.sh agrega filas nuevas debajo de esta línea, no la borres -->"
SKILLS_MD="$KIT_DIR/SKILLS.md"
if [ -f "$SKILLS_MD" ] && grep -qF "$MARCADOR" "$SKILLS_MD"; then
  if grep -qF "**\`$NOMBRE\`**" "$SKILLS_MD"; then
    echo "  SKILLS.md -> ya tenía una fila para '$NOMBRE', no duplico"
  else
    FILA="| **\`$NOMBRE\`** | $PROYECTO_ORIGEN | $(date +%Y-%m-%d) |"
    ESCAPADA="$(printf '%s\n' "$FILA" | sed 's/[&/\]/\\&/g')"
    sed -i "s#$MARCADOR#$MARCADOR\n$ESCAPADA#" "$SKILLS_MD"
    echo "  SKILLS.md -> fila agregada en 'Skills promovidas, pendientes de revisión curada'"
  fi
else
  echo "  AVISO: no encontré el marcador esperado en SKILLS.md — agrega la fila a mano:"
  echo "    | **\`$NOMBRE\`** | $PROYECTO_ORIGEN | $(date +%Y-%m-%d) |"
fi

echo ""
echo "Listo. Antes de dar esto por terminado:"
echo "  1. Revisa $KIT_DIR/skills-custom/$NOMBRE/SKILL.md — ¿la description activa la skill en el"
echo "     contexto correcto? (ver capability-gap-analysis, 'Promoción a skill global', paso 1)"
echo "  2. Corre scripts/verificar-kit.sh antes de dar por buena esta versión del kit."
echo "  3. Cuando la description quede curada, mueve la fila de SKILLS.md a la tabla que corresponda."
