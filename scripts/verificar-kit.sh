#!/usr/bin/env bash
# verificar-kit.sh — Suite mínima de verificación propia del kit.
# No reemplaza la verificación empírica contra una sesión real de OpenCode/Codex CLI/VS Code (eso
# sigue siendo manual, ver README.md, "Verificación recomendada") — cubre lo que SÍ se puede
# comprobar sin esa sesión.
#
# Uso: ./scripts/verificar-kit.sh   (desde la raíz del kit)
# 7 chequeos: JSON/TOML válidos, sin voseo, ShellCheck (incluida scripts/_lib-cronos.sh), guía sin
# .zip fijo, referencias R-XXX válidas, menciones de versión en prosa alineadas con VERSION, y
# estructura de adapters/ completa (desde v4.0.0, ver adr/ADR-011).
# Código de salida: 0 si todo pasa, 1 si algo falla — pensado para poder engancharse
# a CI el día que este repo tenga uno (Riesgo R-004 de RIESGOS.md).
set -u
RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$RAIZ" || exit 1
FALLO=0

echo "=== 1/7 — Configuración de cada adaptador es JSON/TOML válido ==="
if command -v jq >/dev/null 2>&1; then
  JSON_OK=1
  for f in adapters/opencode/opencode.template.json adapters/vscode/mcp.template.json; do
    if [ -f "$f" ] && ! jq empty "$f" 2>/dev/null; then
      echo "FALLO: $f no es JSON válido."
      FALLO=1; JSON_OK=0
    fi
  done
  [ "$JSON_OK" = "1" ] && echo "OK (JSON)"
else
  echo "AVISO: 'jq' no está instalado, se omite la validación de JSON (no cuenta como fallo)."
fi
if command -v python3 >/dev/null 2>&1 && python3 -c "import tomllib" >/dev/null 2>&1; then
  if [ -f adapters/codex/config.toml.template ]; then
    if python3 -c "import tomllib; tomllib.load(open('adapters/codex/config.toml.template','rb'))" 2>/dev/null; then
      echo "OK (TOML)"
    else
      echo "FALLO: adapters/codex/config.toml.template no es TOML válido."
      FALLO=1
    fi
  fi
else
  echo "AVISO: python3 con tomllib (3.11+) no está disponible, se omite la validación de TOML (no cuenta como fallo)."
fi

echo ""
echo "=== 2/7 — Sin restos de voseo en el kit ==="
# Bug encontrado en auditoría externa (2026-07-18, v3.3.2): bajo locale C/POSIX (la que
# trae este contenedor por defecto), grep trata cada vocal acentuada como una secuencia
# de bytes no-palabra, así que \b ve un límite de palabra ENTRE la vocal acentuada y la
# letra que sigue. Efecto: "pedí\b" matcheaba dentro de "pedía" (imperfecto de "pedir",
# no voseo) porque \b encontraba un límite falso entre "í" y "a". Fix: forzar una locale
# UTF-8 real para este chequeo, donde las vocales acentuadas sí cuentan como caracteres
# de palabra y \b se comporta como se espera. Con fallback si el entorno no tiene ninguna
# instalada (en ese caso se avisa, no se hace fallar el chequeo por un problema de entorno).
#
# Segundo bug, misma auditoría: el chequeo corría sin -i, así que el voseo al inicio de
# una oración o de un ítem de lista ("Anotá...", "Definí...", "Revisá...") nunca se
# detectaba, sin importar la locale — la mayúscula inicial no matcheaba contra la lista
# en minúscula. Fix: grep ahora corre con -i (ver más abajo). Además, la lista de formas
# se amplió con ~13 verbos reales encontrados en el kit que faltaban en la lista original
# (esperá, registrá, terminá, generá, aplicá, anotá, definí, correlo, confirmame,
# confirmalo, preguntame, entre otros) — todos corregidos a tuteo en esta misma versión.
#
# Limitación que sigue abierta y que este fix NO resuelve: la lista de formas es fija y
# manual. Cualquier verbo/persona que alguien escriba en voseo y que no esté ya en esta
# lista simplemente no se detecta. Esto no es un chequeo exhaustivo de voseo — es una
# lista de patrones conocidos. Ver nota en CHANGELOG.md v3.3.3 antes de asumir "0 voseo"
# como garantía absoluta.
LOCALE_UTF8=""
for candidata in C.UTF-8 C.utf8 en_US.UTF-8 en_US.utf8; do
  if locale -a 2>/dev/null | grep -qix "$candidata"; then
    LOCALE_UTF8="$candidata"
    break
  fi
done
PATRON='\b(tenés|podés|vení|andá|hacé[^r]|decí\b|mostrá|fijate|escribí\b|pegale|pegá\b|armá\b|usá\b|cambiá\b|revisá\b|confirmá\b|corré\b|segui[^r]|seguí\b|seguís\b|sabés\b|trabajá\b|lográs|decilo|decime|parás|evaluás|dejalo|instalala|tené\b|pedí\b|leé\b|creé\b|actualizá\b|verificá\b|asegurá\b|chequeá\b|probá\b|corregí\b|movete\b|acordate\b|esperá\b|registrá\b|terminá\b|generá\b|aplicá\b|anotá\b|definí\b|correlo\b|confirmame\b|confirmalo\b|preguntame\b)\b'
if [ -z "$LOCALE_UTF8" ]; then
  echo "AVISO: no se encontró ninguna locale UTF-8 instalada (probé C.UTF-8/en_US.UTF-8)."
  echo "       Este chequeo puede dar falsos positivos con palabras como 'pedía' bajo"
  echo "       locale C/POSIX. Instala una locale UTF-8 para un resultado confiable."
fi
if LC_ALL="$LOCALE_UTF8" grep -rliE "$PATRON" --include="*.md" --include="*.sh" --include="*.json" \
     --exclude-dir=".git" --exclude=CHANGELOG.md --exclude=verificar-kit.sh . 2>/dev/null | grep -q .; then
  echo "FALLO: hay restos de voseo fuera de CHANGELOG.md (que se deja como registro histórico):"
  LC_ALL="$LOCALE_UTF8" grep -rliE "$PATRON" --include="*.md" --include="*.sh" --include="*.json" \
     --exclude-dir=".git" --exclude=CHANGELOG.md --exclude=verificar-kit.sh .
  FALLO=1
else
  echo "OK"
fi

echo ""
echo "=== 3/7 — ShellCheck sobre los scripts, incluida scripts/_lib-cronos.sh (si está disponible) ==="
if command -v shellcheck >/dev/null 2>&1; then
  # -x sigue el archivo source-eado (scripts/_lib-cronos.sh) en vez de solo avisar que no lo revisó
  # (SC1091) — -P scripts le da la carpeta donde buscarlo. Ver adr/ADR-011: la librería compartida
  # es nueva en v4.0.0, antes no hacía falta ninguna de las dos banderas.
  if shellcheck -x -P scripts scripts/*.sh; then
    echo "OK"
  else
    echo "FALLO: ShellCheck encontró problemas (ver arriba)."
    FALLO=1
  fi
else
  echo "AVISO: ShellCheck no está instalado, se omite esta verificación (no cuenta como fallo)."
  echo "       Instálalo (apt install shellcheck / brew install shellcheck) para esta capa extra."
fi

echo ""
echo "=== 4/7 — GUIA-PARA-PRINCIPIANTES.md no referencia un .zip de versión fija ==="
if [ -f GUIA-PARA-PRINCIPIANTES.md ]; then
  if grep -qE "cronos-v[0-9_]+\.zip" GUIA-PARA-PRINCIPIANTES.md; then
    echo "FALLO: la guía referencia un nombre de .zip de versión puntual."
    FALLO=1
  else
    echo "OK"
  fi
else
  echo "FALLO: GUIA-PARA-PRINCIPIANTES.md no está en la raíz del kit — debería estarlo."
  FALLO=1
fi

echo ""
echo "=== 5/7 — Toda referencia a R-XXX existe de verdad en RIESGOS.md ==="
REFERENCIAS=$(grep -rohE "R-[0-9]{3}" --include="*.md" --exclude-dir=".git" . 2>/dev/null | sort -u)
DEFINIDAS=$(grep -oE "^### R-[0-9]{3}" RIESGOS.md 2>/dev/null | grep -oE "R-[0-9]{3}" | sort -u)
FALTANTES=$(comm -23 <(echo "$REFERENCIAS") <(echo "$DEFINIDAS"))
if [ -n "$FALTANTES" ]; then
  echo "FALLO: se referencian riesgos que no existen como entrada '### R-XXX' en RIESGOS.md:"
  echo "$FALTANTES"
  FALLO=1
else
  echo "OK"
fi

echo ""
echo "=== 6/7 — Menciones de versión en prosa coinciden con VERSION ==="
# Nace de la auditoría 10/10 (2026-07-16): AGENCY.md quedó en "3.1.0" tras el bump a
# 3.2.0 porque ningún chequeo automático lo cubría. Busca `X.Y.Z` o vX.Y.Z en los
# archivos que citan la versión activa del kit en prosa (no el historial versionado).
if [ -f VERSION ]; then
  VERSION_ACTUAL="$(tr -d '[:space:]' < VERSION)"
  ARCHIVOS_A_REVISAR="AGENCY.md GOBERNANZA.md README.md"
  DESALINEADOS=""
  for archivo in $ARCHIVOS_A_REVISAR; do
    [ -f "$archivo" ] || continue
    # Solo líneas que declaran la versión ACTUAL del kit, no menciones históricas
    # ("desde v3.0.0", "nuevo en v3.1.0", CHANGELOG-style) — se identifican por ir
    # junto a "actualmente" o "Estado real hoy".
    MENCIONES=$(grep -nE "actualmente \`[0-9]+\.[0-9]+\.[0-9]+\`|Estado real hoy \([0-9]{4}-[0-9]{2}-[0-9]{2}, v[0-9]+\.[0-9]+\.[0-9]+\)" "$archivo" 2>/dev/null)
    if [ -n "$MENCIONES" ]; then
      while IFS= read -r linea; do
        VERSION_EN_LINEA=$(echo "$linea" | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | head -1)
        if [ -n "$VERSION_EN_LINEA" ] && [ "$VERSION_EN_LINEA" != "$VERSION_ACTUAL" ]; then
          DESALINEADOS="${DESALINEADOS}${archivo}: ${linea}\n"
        fi
      done <<< "$MENCIONES"
    fi
  done
  # `agent.cronos.description` de adapters/opencode/opencode.template.json declara "Cronos
  # X.Y.Z" (patch completo). Hasta v3.3.2 este chequeo solo exigía mayor.menor, a propósito,
  # para que un bump de patch no desalineara el campo. Revertido en v3.3.3 por pedido explícito
  # del operador: quiere ver el patch exacto dentro de OpenCode, no solo mayor.menor.
  # Costo aceptado conscientemente: de ahora en más, CADA bump de versión — incluidos
  # los de patch — debe tocar también este campo, o este chequeo falla (ver CHANGELOG.md
  # v3.3.3 para el razonamiento completo de por qué se revirtió el criterio anterior).
  if [ -f adapters/opencode/opencode.template.json ]; then
    DESC_VERSION=$(grep -oE '"description": "Cronos [0-9]+\.[0-9]+\.[0-9]+' adapters/opencode/opencode.template.json | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    if [ -n "$DESC_VERSION" ] && [ "$DESC_VERSION" != "$VERSION_ACTUAL" ]; then
      DESALINEADOS="${DESALINEADOS}adapters/opencode/opencode.template.json: agent.cronos.description dice \"Cronos ${DESC_VERSION}\", VERSION es ${VERSION_ACTUAL}\n"
    fi
  fi
  if [ -n "$DESALINEADOS" ]; then
    echo "FALLO: hay menciones de versión activa desalineadas con VERSION ($VERSION_ACTUAL):"
    printf '%b' "$DESALINEADOS"
    FALLO=1
  else
    echo "OK"
  fi
else
  echo "AVISO: no se encontró VERSION, se omite esta verificación (no cuenta como fallo)."
fi

echo ""
echo "=== 7/7 — Estructura de adapters/ completa (ver adr/ADR-011) ==="
ARCHIVOS_ESPERADOS="adapters/README.md adapters/opencode/README.md adapters/opencode/opencode.template.json adapters/codex/README.md adapters/codex/config.toml.template adapters/vscode/README.md adapters/vscode/copilot-instructions.template.md adapters/vscode/mcp.template.json AGENTS.md"
FALTAN_ADAPTADORES=""
for f in $ARCHIVOS_ESPERADOS; do
  [ -f "$f" ] || FALTAN_ADAPTADORES="${FALTAN_ADAPTADORES}  $f\n"
done
if [ -n "$FALTAN_ADAPTADORES" ]; then
  echo "FALLO: faltan estos archivos esperados de la capa de adaptadores:"
  printf '%b' "$FALTAN_ADAPTADORES"
  FALLO=1
else
  echo "OK"
fi

echo ""
if [ "$FALLO" = "1" ]; then
  echo "RESULTADO: uno o más chequeos fallaron. Revisa arriba antes de empaquetar una versión nueva."
  exit 1
fi
echo "RESULTADO: todos los chequeos disponibles en este entorno pasaron."
exit 0
