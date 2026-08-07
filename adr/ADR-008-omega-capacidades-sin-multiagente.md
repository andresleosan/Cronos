# ADR-008: Cronos Omega — capacidades nuevas como skills/fases del agente único, sin reabrir el diseño multiagente

**Estado:** aceptada (nueva en v3.1.0)
**Fecha:** 2026-07-15

## Contexto
Se recibió una propuesta externa ("Master Task — Cronos Omega V5 Ultimate") pidiendo rediseñar Cronos con un rol de "Arquitecto Principal Multiagente", una tubería extensa de capas "Intelligence" (Producto, Negocio, Competencia, Diseño, Ingeniería, Evolución, Conocimiento) y un "Titan Council" que convoca explícitamente a Atlas, Hefesto, Prometeo, QA, Arquitectura y Producto por nombre.

Eso entra en conflicto directo con ADR-007 (2026-07-14, un día antes): la consolidación deliberada de 10 subagentes + orquestador a un único agente. `ROADMAP.md` ya dejaba escrito, en su sección "Descartado / fuera de alcance", que volver a una arquitectura multiagente "no es un experimento reversible sin nueva decisión deliberada". La propuesta externa, tal como estaba escrita, hubiera revertido ADR-007 sin que esa decisión deliberada nueva existiera.

Auditoría del pedido (ver `docs/PROPUESTA-OMEGA.md`) encontró que gran parte de lo pedido ya existe con otro nombre (Titan Council ≈ `GOBERNANZA.md`; CTO Challenge Mode ≈ sección "Alternativas consideradas" de cada ADR; Feature Prioritization ≈ `product-strategy`/`mvp-roadmap-planning`; Repository Intelligence ≈ Modo Auditoría; Visionary Mode ≈ `ROADMAP.md`), y que solo 3 capacidades representan un hueco real: benchmark de diseño, memoria entre proyectos, y seguimiento de costo.

El operador confirmó explícitamente mantener la arquitectura de agente único.

## Decisión
1. Ninguna entrada nueva `agent.<nombre>` se agrega a `opencode.json` — Cronos sigue siendo el único agente, `mode: primary`.
2. Los 3 huecos reales se incorporan como skills nuevas en `skills-custom/`: `design-benchmark`, `cost-intelligence`, `capability-gap-analysis`. `SKILLS.md` pasa de 14 a 17 skills documentadas.
3. Se agrega `LECCIONES.md` (nuevo componente global, `LECCIONES.example.md` como plantilla) como memoria evolutiva entre proyectos — hueco real que ningún componente anterior cubría.
4. El "Titan Council" del pedido externo se resuelve extendiendo `GOBERNANZA.md`: cada ADR de impacto real debe incluir, de ahora en más, las "alternativas consideradas" ya exigidas de facto desde ADR-001 — se formaliza como práctica esperada, no como un mecanismo nuevo.
5. `MASTER_PROMPT.md` gana el paso A2.2 (benchmark de diseño, antes de construir frontend) y el paso 7.5 (cierre de proyecto Nivel 2/3: `capability-gap-analysis` + `LECCIONES.md`).

## Alternativas consideradas
- **Adoptar el Master Task tal como estaba escrito** (rol multiagente, Titan Council convocando Titanes por nombre). Descartado — revertiría ADR-007 sin la decisión deliberada nueva que `ROADMAP.md` exige explícitamente para eso, y el operador no tomó esa decisión: eligió mantener agente único.
- **Ignorar el pedido por completo.** Descartado — 3 de los huecos señalados son reales y no dependían del framing multiagente del pedido original; descartar todo por el framing hubiera tirado señal útil junto con el ruido.
- **Agrupar las 3 capacidades nuevas en una sola skill "omega-intelligence".** Descartado — mismo criterio que ya exige `SKILLS.md` en su sección "Qué NO hacer": cada skill necesita un criterio de activación propio y verificable; agruparlas oculta cuándo aplica cada una y complica que Cronos señale cuál usó.
- **Titan Council como mecanismo nuevo separado** (ej. una skill que genera "opiniones" simuladas de distintos roles en el mismo turno). Descartado — es teatro: el mismo modelo generando 4 párrafos con encabezados de rol distinto no es una segunda mirada independiente, es la misma autoauditoría de siempre con más pasos. Se prefirió reconocer que `GOBERNANZA.md` (sombreros humanos) y `adr/` (alternativas descartadas por escrito) ya cubren la intención real detrás del pedido, sin fingir una independencia que no existe.

## Consecuencias
- `SKILLS.md`: 14 → 17 skills. La pregunta abierta en `ROADMAP.md` sobre si el número es correcto se responde con criterio de activación explícito por skill, no fusionando a ciegas — sigue siendo un ítem a revisar con uso real (ver `ROADMAP.md`).
- Riesgos nuevos: R-016 (Skill Forge sin curaduría puede inflar el catálogo) y R-017 (`LECCIONES.md` sin límite de tamaño) — ver `RIESGOS.md`, ambos con mitigación ya diseñada.
- `scripts/instalar-global.sh` gana un paso no destructivo: crea `LECCIONES.md` desde `LECCIONES.example.md` solo si no existe ya en `~/.config/opencode/cronos/`.
- No hay cambios a `opencode.template.json`, a la clasificación de proyectos por nivel, ni a ningún componente de gobernanza existente — todo lo nuevo se construye encima de lo que ya había, sin reemplazar nada funcional (ver `docs/PROPUESTA-OMEGA.md` para el detalle completo del diagnóstico que originó esta decisión).
- El nombre "Cronos Omega V5" del pedido original no se adopta como número de versión: por alcance real (aditivo, no rompe nada), esto es un bump menor de semver — `3.0.0` → `3.1.0`, no un salto a "5".
