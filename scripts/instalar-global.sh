#!/usr/bin/env bash
# Instalación global de Cronos — correr UNA sola vez por máquina.
# Instala el núcleo para las plataformas que tienen mecanismo global real (OpenCode, Codex CLI),
# más el archivo de memoria compartido entre las 3 (~/.cronos/LECCIONES.md, ver ADR-011).
# VS Code/Copilot NO tiene mecanismo global confiable — su adaptador se instala por proyecto
# (scripts/nuevo-proyecto.sh / adoptar-proyecto.sh), ver adapters/vscode/README.md.
#
# Uso: ./instalar-global.sh [--force] [--solo opencode|codex]
#   --force: no pregunta ante colisiones de nombre en skills-custom, sobrescribe directo
#            (util para instalaciones no interactivas, ej. pruebas en un HOME temporal).
#   --solo <plataforma>: instala solo esa plataforma en vez de las dos (por defecto, ambas).
set -e

FORCE=""
SOLO=""
while [ $# -gt 0 ]; do
  case "$1" in
    --force) FORCE="--force"; shift ;;
    --solo) SOLO="${2:-}"; shift 2 ;;
    *) shift ;;
  esac
done

INSTALAR_OPENCODE=1
INSTALAR_CODEX=1
case "$SOLO" in
  opencode) INSTALAR_CODEX=0 ;;
  codex) INSTALAR_OPENCODE=0 ;;
  "") : ;;
  *) echo "Valor de --solo no reconocido: '$SOLO' (uso: opencode|codex)"; exit 1 ;;
esac

echo "Verificando requisitos..."
FALTAN=""
command -v git >/dev/null 2>&1 || FALTAN="$FALTAN git"
command -v node >/dev/null 2>&1 || FALTAN="$FALTAN node"
command -v npx  >/dev/null 2>&1 || FALTAN="$FALTAN npx"
if [ -n "$FALTAN" ]; then
  echo "Faltan estas herramientas en el PATH:$FALTAN"
  echo "Instálalas antes de continuar (Node.js incluye npx) y vuelve a correr este script."
  exit 1
fi
echo "OK: git, node y npx disponibles."
[ "$INSTALAR_OPENCODE" = "1" ] && { command -v opencode >/dev/null 2>&1 && echo "OK: opencode encontrado en el PATH." || echo "AVISO: no encuentro 'opencode' en el PATH — instalo igual el nucleo, conectalo despues."; }
[ "$INSTALAR_CODEX" = "1" ] && { command -v codex >/dev/null 2>&1 && echo "OK: codex encontrado en el PATH." || echo "AVISO: no encuentro 'codex' en el PATH — instalo igual el nucleo, conectalo despues."; }
echo ""

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OC_CONFIG="$HOME/.config/opencode"
OC_SKILLS="$OC_CONFIG/skills"
OC_COMMANDS="$OC_CONFIG/commands"
OC_CRONOS="$OC_CONFIG/cronos"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CODEX_SKILLS="$CODEX_HOME/skills"
CODEX_CRONOS="$CODEX_HOME/cronos"
CRONOS_SHARED="$HOME/.cronos"

# --- Funciones reutilizadas por plataforma -----------------------------------

instalar_skills() {
  # $1 = carpeta destino de skills para esta plataforma
  DEST="$1"
  MARCADOR="$DEST/.cronos-skills"
  INSTALADAS_ANTES=""
  [ -f "$MARCADOR" ] && INSTALADAS_ANTES="$(cat "$MARCADOR")"
  : > "$MARCADOR.tmp"
  for SKILL_DIR in "$KIT_DIR"/skills-custom/*/; do
    SKILL_NAME="$(basename "$SKILL_DIR")"
    DESTINO="$DEST/$SKILL_NAME"
    COPIADA=1
    if [ -d "$DESTINO" ] && ! grep -qx "$SKILL_NAME" <<< "$INSTALADAS_ANTES"; then
      echo "  AVISO: ya existe una carpeta de skill llamada '$SKILL_NAME' en $DEST, y no la instaló esta agencia (¿autoskills, Superpowers, u otra fuente?)."
      if [ "$FORCE" = "--force" ]; then
        cp -r "$SKILL_DIR" "$DEST/"
        echo "  Sobrescrita (--force): $SKILL_NAME"
      else
        read -r -p "  ¿Sobrescribirla con la skill de la agencia? (s/N): " CONFIRMA
        case "$CONFIRMA" in
          s|S|si|Si|SI|sí|Sí) cp -r "$SKILL_DIR" "$DEST/" ; echo "  Sobrescrita: $SKILL_NAME" ;;
          *) echo "  Omitida: $SKILL_NAME (conservé la carpeta que ya estaba, no se actualizó)"; COPIADA=0 ;;
        esac
      fi
    else
      cp -r "$SKILL_DIR" "$DEST/"
    fi
    [ "$COPIADA" = "1" ] && echo "$SKILL_NAME" >> "$MARCADOR.tmp"
  done
  mv "$MARCADOR.tmp" "$MARCADOR"
  echo "Skills copiadas a $DEST"
}

instalar_nucleo() {
  # $1 = carpeta destino del nucleo (AGENCY.md, MASTER_PROMPT.md, SKILLS.md, MODELOS.md, LOOPS.md...)
  DEST="$1"
  GOBIERNO="GOBERNANZA.md RIESGOS.md ROADMAP.md GUIA-PARA-PRINCIPIANTES.md"
  for f in "$KIT_DIR"/*.md; do
    base="$(basename "$f")"
    [ "$base" = "README.md" ] && continue
    [ "$base" = "AGENTS.md" ] && continue  # AGENTS.md global se genera aparte, con rutas propias
    ES_GOBIERNO=0
    for g in $GOBIERNO; do [ "$base" = "$g" ] && ES_GOBIERNO=1; done
    [ "$ES_GOBIERNO" = "1" ] && continue
    cp "$f" "$DEST/$base"
  done
  cp "$KIT_DIR/VERSION" "$DEST/VERSION"
  cp "$KIT_DIR/gitignore.template" "$DEST/gitignore.template"
}

generar_agents_global() {
  # $1 = ruta completa del AGENTS.md a generar; $2 = prefijo relativo hacia AGENCY.md/MASTER_PROMPT.md
  DEST_FILE="$1"
  PREFIJO="$2"
  if [ -f "$DEST_FILE" ]; then
    echo "Ya existe $DEST_FILE - no lo piso. Si no viene de una instalación anterior de Cronos, agrégale a mano:"
    echo "  Lee ${PREFIJO}AGENCY.md y ${PREFIJO}MASTER_PROMPT.md antes de continuar."
    return
  fi
  cat > "$DEST_FILE" <<EOF
# Cronos

Eres **Cronos**, agente primario de desarrollo full-stack con delegación temporal controlada, y con
un ciclo de autocrítica obligatorio
antes de dar cualquier tarea por terminada. Antes de cualquier otra cosa, lee en esta instalación:
1. \`${PREFIJO}AGENCY.md\`
2. \`${PREFIJO}MASTER_PROMPT.md\`

Reglas de oro resumidas (defensa en profundidad — ante cualquier diferencia, manda \`${PREFIJO}AGENCY.md\`):
- Un hallazgo crítico de seguridad detectado por ti mismo bloquea el avance, sin excepciones.
- Ninguna tarea pasa a "aprobada" sin evidencia real de que las pruebas corrieron y pasaron.
- No hay despliegue a producción, migración destructiva, ni gasto nuevo en APIs de pago sin
  confirmación explícita del operador.
- Puedes delegar hasta tres unidades acotadas si el runtime lo permite, sin delegación anidada. Los
  subagentes no leen secretos, no modifican Git, no despliegan, no migran, no generan gasto ni
  aprueban tareas; Cronos inspecciona sus archivos y repite las pruebas.
- Hablá siempre en español, salvo nombres de archivos o variables de código.

Memoria evolutiva compartida entre plataformas: \`$CRONOS_SHARED/LECCIONES.md\` (ruta absoluta, la
misma sin importar desde cuál de las 3 plataformas soportadas estés corriendo — ver \`${PREFIJO}AGENCY.md\`).
EOF
  echo "AGENTS.md creado en $DEST_FILE"
}

# --- OpenCode -----------------------------------------------------------------
if [ "$INSTALAR_OPENCODE" = "1" ]; then
  echo "== OpenCode =="
  mkdir -p "$OC_SKILLS" "$OC_COMMANDS" "$OC_CRONOS"
  echo "Copiando skills (ver SKILLS.md para el catálogo completo)..."
  instalar_skills "$OC_SKILLS"
  instalar_nucleo "$OC_CRONOS"
  cp "$KIT_DIR/adapters/opencode/opencode.template.json" "$OC_CRONOS/opencode.template.json"
  echo "Núcleo copiado a $OC_CRONOS (versión $(cat "$KIT_DIR/VERSION"))"
  cp "$KIT_DIR"/commands/*.md "$OC_COMMANDS/"
  echo "Comandos globales copiados a $OC_COMMANDS (/cronos-continuar, /cronos-verificar-objetivo)"
  generar_agents_global "$OC_CONFIG/AGENTS.md" "cronos/"

  # Cargar AGENCY.md + MASTER_PROMPT.md en TODA sesion de OpenCode (mecanismo YA verificado,
  # ver docs/AUDITORIA-10-10-verificacion-R002.md — AGENTS.md de arriba es refuerzo, no reemplazo).
  if [ -f "$OC_CONFIG/opencode.json" ]; then
    echo "Ya existe $OC_CONFIG/opencode.json - agrega esto a mano en su array \"instructions\":"
    echo "  \"$OC_CRONOS/AGENCY.md\""
    echo "  \"$OC_CRONOS/MASTER_PROMPT.md\""
  else
    cat > "$OC_CONFIG/opencode.json" <<EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "instructions": [
    "$OC_CRONOS/AGENCY.md",
    "$OC_CRONOS/MASTER_PROMPT.md"
  ]
}
EOF
    echo "Creado $OC_CONFIG/opencode.json - el agente queda cargado en toda sesión"
  fi
  echo ""
fi

# --- Codex CLI ------------------------------------------------------------
if [ "$INSTALAR_CODEX" = "1" ]; then
  echo "== Codex CLI =="
  mkdir -p "$CODEX_SKILLS" "$CODEX_CRONOS"
  echo "Copiando skills (ver SKILLS.md para el catálogo completo)..."
  instalar_skills "$CODEX_SKILLS"
  instalar_nucleo "$CODEX_CRONOS"
  cp "$KIT_DIR/adapters/codex/config.toml.template" "$CODEX_CRONOS/config.toml.template"
  echo "Núcleo copiado a $CODEX_CRONOS (versión $(cat "$KIT_DIR/VERSION"))"
  echo "Sin comandos personalizados para Codex CLI (ver adapters/codex/README.md) - Capa 1 se usa pegando el contenido de commands/*.md como mensaje."
  # Este SI es el mecanismo PRINCIPAL para Codex CLI (no tiene un array "instructions" propio) -
  # a diferencia de OpenCode, donde el de arriba es refuerzo de algo que ya funciona sin él.
  generar_agents_global "$CODEX_HOME/AGENTS.md" "cronos/"
  echo ""
fi

# --- Memoria compartida entre las 3 plataformas (ADR-011) ------------------
mkdir -p "$CRONOS_SHARED"
if [ -f "$CRONOS_SHARED/LECCIONES.md" ]; then
  echo "LECCIONES.md ya existe en $CRONOS_SHARED - se conserva sin tocar (memoria evolutiva)."
else
  cp "$KIT_DIR/LECCIONES.example.md" "$CRONOS_SHARED/LECCIONES.md"
  echo "LECCIONES.md creado en $CRONOS_SHARED a partir de LECCIONES.example.md (primera instalación)."
fi
echo ""

if [ "$INSTALAR_OPENCODE" = "1" ]; then
  echo "Faltan dos pasos MANUALES de OpenCode (ninguno se instala por script, a propósito - ver README.md):"
  echo ""
  echo "Superpowers (solo OpenCode, ver adapters/opencode/README.md):"
  echo "1) Confirma el tag mas reciente: https://github.com/obra/superpowers/releases"
  echo "2) Abre opencode en cualquier carpeta y pégale esto UNA vez, cambiando TAG por ese tag:"
  echo ""
  echo "   Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/TAG/.opencode/INSTALL.md"
  echo ""
  echo "3) Verifica que opencode.json quedo con el plugin fijado a ese TAG (...#TAG), no a 'main'."
  echo "4) Anota la version instalada en el STACK.md de cada proyecto para poder auditar actualizaciones futuras."
  echo ""
  echo "ui-ux-pro-max (opcional, solo OpenCode, solo si el proyecto tiene frontend - ver README.md):"
  echo "1) Confirma la version mas reciente: https://github.com/nextlevelbuilder/ui-ux-pro-max-skill/releases"
  echo "2) npm install -g ui-ux-pro-max-cli@<version-confirmada>   (nunca @latest a ciegas)"
  echo "3) uipro init --ai opencode --global"
  echo "4) Anota la version instalada en el STACK.md de cada proyecto, igual que con Superpowers."
  echo ""
fi

echo "VS Code (GitHub Copilot): sin instalación global — ver adapters/vscode/README.md. Su adaptador"
echo "se genera por proyecto con scripts/nuevo-proyecto.sh / adoptar-proyecto.sh."
echo ""
echo "Instalación global lista (Cronos v$(cat "$KIT_DIR/VERSION"))."
echo "Para traer una versión más nueva del core a un proyecto ya creado: scripts/actualizar-proyecto.sh"
