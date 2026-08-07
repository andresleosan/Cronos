# ADR-012: Detección de gaps proactiva + promoción de skills — extiende `capability-gap-analysis` sin reabrir "Skill Forge"

**Estado:** aceptada (nueva en v4.1.0)
**Fecha:** 2026-08-06

## Contexto

`docs/PROPUESTA-OMEGA.md` (julio 2026) proponía "Skill Forge": un flujo de creación de skills más
amplio y automatizado. `ADR-008` lo aceptó **acotado a lo mínimo real**: la skill
`capability-gap-analysis`, que detecta gaps y **propone**, nunca instala sola. `RIESGOS.md` R-016
("Skill Forge sin curaduría puede inflar el catálogo") documentó por qué: un agente que puede
ampliar su propio catálogo de capacidades sin fricción tiende a esas capacidades mediocres,
superpuestas, o mal descriptas — y una `description` de `SKILL.md` imprecisa no solo no ayuda, activa
la skill en el contexto equivocado o nunca se activa donde sí hace falta.

El operador pidió ahora extender esto en dos ejes concretos, elegidos explícitamente entre varias
opciones con distinto nivel de riesgo:
1. Que la propuesta de skill nueva no espere al cierre del proyecto (Paso 7.5) — que se dispare
   apenas se nota el patrón repetido, dentro del mismo proyecto. **Con el mismo checkpoint de
   confirmación que ya existe, sin excepción.**
2. Que cuando una skill nacida en un proyecto demuestre que hace falta en un segundo proyecto
   distinto, Cronos lo note y pregunte si corresponde promoverla al catálogo global — no que el
   operador tenga que acordarse de revisarlo él mismo.

Ninguna de las dos reabre la pregunta que `ADR-008` ya cerró: si Cronos puede instalar una skill
**sin que nadie la confirme**. Eso sigue prohibido, en los dos ejes, sin excepción.

## Decisión

1. **`.cronos/gaps-detectados.md`** (nuevo, por proyecto, creado vacío por `nuevo-proyecto.sh`/
   `adoptar-proyecto.sh`, nunca sincronizado por `actualizar-proyecto.sh` — es estado del proyecto,
   no núcleo, mismo trato que `BRIEF.md`/`tasks.md`). Registro de trabajo: una línea cada vez que
   una tarea revela que ninguna skill/criterio existente cubría lo necesario. Existe porque "Cronos
   nota que se repite" no es confiable como mecanismo puro de memoria conversacional — un proyecto
   real cruza sesiones, y sin un registro escrito, la segunda ocurrencia de un gap no tiene con qué
   compararse contra la primera.
2. **`self-critique-loop`** gana un paso 6 liviano (solo Nivel 2/3, mismo criterio de
   proporcionalidad que ya aplica el resto del loop): antes de cerrar una tarea, un chequeo de diez
   segundos de si hizo falta resolver algo sin cobertura existente — si sí, una línea en
   `gaps-detectados.md`. No es una fase nueva pesada, es una pregunta más al final de un paso que ya
   existía.
3. **`capability-gap-analysis`** se activa apenas `gaps-detectados.md` muestra una segunda entrada
   parecida en el mismo proyecto — no hace falta esperar al cierre. La propuesta y el checkpoint de
   confirmación (**"¿la incorporamos como skill?"**) no cambian en absoluto — solo cambia CUÁNDO se
   ofrecen.
4. **Antes de proponer, un chequeo nuevo contra `~/.cronos/LECCIONES.md`**: si el mismo tipo de gap
   ya quedó registrado en un proyecto *distinto* anteriormente, la propuesta ya no es "¿la creamos
   en este proyecto?" — es directamente "¿la creamos como skill global, porque ya se repitió entre
   proyectos?". Mismo checkpoint de confirmación, distinto destino del archivo.
5. **Dos destinos posibles al confirmar, nunca automáticos:**
   - Sin evidencia cross-proyecto todavía → `.cronos/skills/<nombre>/SKILL.md` del proyecto actual
     únicamente. No toca el catálogo global ni `skills-custom/` del kit.
   - Con evidencia cross-proyecto (punto 4) → **`scripts/promover-skill.sh`** (nuevo): copia el
     `SKILL.md` a `skills-custom/` del kit fuente y a los directorios globales de OpenCode/Codex CLI
     que existan, y deja una entrada "pendiente de revisión" en `SKILLS.md` en vez de escribir sola
     una descripción de catálogo curada — esa redacción sigue siendo trabajo humano.
6. **`MASTER_PROMPT.md`** gana una instrucción, al arrancar cualquier proyecto (Paso 0/A1/B1): leer
   `~/.cronos/LECCIONES.md` antes de empezar. Necesario para que el punto 4 funcione — sin leerlo al
   arrancar, Cronos nunca tendría con qué comparar un gap nuevo contra el historial cross-proyecto.
7. **`GOBERNANZA.md`** gana una fila nueva en la matriz RACI: "Promover skill de proyecto a catálogo
   global" → Product Owner A/R (es una decisión de qué capacidades carga la agencia hacia adelante,
   no una de arquitectura pura), Arquitecto técnico C.
8. **`RIESGOS.md`** R-016 se actualiza, no se reemplaza: la mitigación central ("nunca instala sola,
   siempre confirmación explícita") sigue exactamente igual, ahora aplicada también al momento
   proactivo y a la promoción. Se agrega una entrada nueva sobre la calidad de las skills promovidas
   (ver Consecuencias).

## Alternativas consideradas

- **Dejar que Cronos cree la skill directamente en el proyecto sin esperar confirmación, y avisar
  después** (la opción más autónoma que se ofreció). Descartada por el operador explícitamente — el
  checkpoint de confirmación no es negociable en ninguno de los dos ejes, es la mitigación central
  de R-016 desde `ADR-008` y no hay motivo nuevo para debilitarla.
- **Promoción automática apenas se detecta la segunda ocurrencia cross-proyecto, sin preguntar**.
  Descartada por el operador explícitamente, mismo motivo — una skill global afecta a todo proyecto
  futuro, más superficie que una local de un solo proyecto, así que si algo merece confirmación
  explícita, es justamente esto.
- **Que las skills promovidas escriban solas su fila de catálogo en `SKILLS.md`.** Descartada —
  la calidad de una `description` de catálogo importa para que el mecanismo de auto-activación de
  cada plataforma dispare en el contexto correcto (ver `SKILLS.md`); una skill que demostró servir
  en dos proyectos reales no garantiza que su descripción esté bien escrita para ese propósito. Se
  deja como "pendiente de revisión" explícito en vez de fingir que ya pasó por curaduría real.
- **Un tracking file compartido entre proyectos (en vez de uno por proyecto)** para detectar
  repetición cross-proyecto directamente, sin pasar por `LECCIONES.md`. Descartada — `LECCIONES.md`
  ya cumple ese rol exacto desde v3.1.0 y ya vive en una ruta neutral de plataforma desde v4.0.0
  (`adr/ADR-011`); crear un segundo archivo con el mismo propósito sería la misma duplicidad que
  `RIESGOS.md` ya trata como categoría de riesgo en otros contextos.

## Consecuencias

- Nuevo archivo por proyecto: `.cronos/gaps-detectados.md` (estado del proyecto, no núcleo).
- Nuevo script: `scripts/promover-skill.sh`.
- `self-critique-loop`, `capability-gap-analysis` actualizadas; `SKILLS.md`, `MASTER_PROMPT.md`,
  `GOBERNANZA.md`, `RIESGOS.md` actualizados.
- **Riesgo nuevo, honesto:** una skill promovida por haber servido en 2 proyectos tiene evidencia de
  necesidad real, pero no evidencia de que su `SKILL.md` esté bien escrito para auto-activarse en
  el contexto correcto — nace de una sesión de trabajo bajo presión de una tarea concreta, no de una
  redacción pensada para el catálogo. Mitigación: el estado "pendiente de revisión" en `SKILLS.md`
  (punto 5) hace ese riesgo visible en vez de dejarlo mezclado silenciosamente con las 18 skills ya
  curadas — ver `RIESGOS.md`, nueva entrada.
- `VERSION`: `4.0.2` → `4.1.0` (funcionalidad nueva, aditiva, no rompe ninguna promesa de
  compatibilidad existente — mismo criterio que ya distinguió v3.1.0/v3.2.0/v3.3.0 de v3.0.0/v4.0.0
  en `CHANGELOG.md`).
