# ADR-009: "Los Titanes Enterprise V4.0" — 3 mejoras reales incorporadas, resto descartado sin reabrir ADR-007/ADR-008

**Estado:** aceptada (confirmada por el operador en v3.2.0)
**Fecha:** 2026-07-15

## Contexto

Se recibió una segunda propuesta externa ("MASTER TASK — LOS TITANES ENTERPRISE V4.0"), un día después de `ADR-008`, pidiendo evolucionar el kit de una madurez de 8.4/10 a 9.4/10 mediante: un Strategic Council de 6 consejos, un Titan Core que separa Núcleo/Capacidades/Ejecución, gobierno de modelos y de skills con registros y ciclos de vida formales, un Knowledge Graph de trazabilidad total, un PMO Empresarial, KPIs obligatorios en 10 categorías, y una capa multiplataforma (Driver/Adapter/Execution/Governance/Knowledge) para OpenCode, Claude Code, Codex CLI, Roo Code y Cursor.

Esto repite, con nombres nuevos, gran parte de lo que `ADR-008` ya evaluó y resolvió el día anterior bajo el nombre "Cronos Omega V5 Ultimate": el "Strategic Council" es el "Titan Council" ya rechazado como teatro; la capa multiplataforma revierte `ADR-007` (consolidación deliberada a OpenCode) sin la decisión nueva y deliberada que `ROADMAP.md` exige explícitamente para eso — y además nombra una plataforma (Roo Code) que cerró el 15 de mayo de 2026 (ver R-009, cerrado). El diagnóstico completo, fase por fase, vive en `docs/PROPUESTA-V4-ENTERPRISE.md`.

De 12 fases pedidas, 9 ya están cubiertas por componentes existentes o contradicen decisiones ya tomadas. 3 debilidades reales sí aparecieron, ninguna relacionada con el framing multiagente/enterprise del pedido original: `LECCIONES.md` sin taxonomía interna, R-017 sin regla de poda concreta, y ningún disparador cuantitativo de convocatoria del Consejo.

El operador confirmó `docs/PROPUESTA-V4-ENTERPRISE.md` (sección 13) sin pedir cambios al diagnóstico.

## Decisión

1. Ningún consejo nuevo se crea como mecanismo separado. `GOBERNANZA.md` mantiene su estructura de sombreros humanos + RACI.
2. No se crea `MODEL_REGISTRY.md`: contradice el diseño explícito de `MODELOS.md`, que evita a propósito un catálogo fijo de modelos porque el catálogo real cambia con frecuencia.
3. No se crea `SKILL_REGISTRY.md` con ciclo de vida de 6 estados: desproporcionado para 17 skills mantenidas por un solo operador. `capability-gap-analysis` ya cubre la parte real (propuesta → confirmación humana).
4. No se reabre `ADR-007`. Cero adaptadores nuevos, cero mención de plataformas adicionales en el kit — ninguna decisión deliberada nueva reemplaza la ya tomada de uso exclusivo de OpenCode.
5. No se crea `PMO.md` ni un Knowledge Graph como sistema nuevo — ambos asumen una escala (multi-proyecto, multi-equipo) que no existe hoy.
6. `LECCIONES.example.md` amplía el campo `Categoría` con 4 valores nuevos: patrón, antipatrón, incidente, playbook — sin crear archivos separados.
7. `RIESGOS.md`, R-017 pasa de "aceptado" a "mitigado": se agrega regla concreta de partición (por año) cuando el archivo supere un umbral de entradas a definir junto con el operador.
8. `GOBERNANZA.md` gana una sección corta de métricas mínimas (riesgos abiertos vs. cerrados, tamaño de `LECCIONES.md`, antigüedad de última revisión por riesgo) y un 4º disparador de convocatoria del Consejo si alguna cruza un umbral.
9. El nombre "V4.0" del pedido original no se adopta como número de versión: por alcance real (aditivo, no rompe nada), esto es `3.1.0` → `3.2.0`, mismo criterio que ya aplicó `ADR-008` al descartar "V5".

## Alternativas consideradas

- **Adoptar el Master Task V4.0 tal como estaba escrito.** Descartado — revertiría `ADR-007` (ya reafirmado una vez en `ADR-008`) sin la decisión deliberada nueva que `ROADMAP.md` exige, y construiría un adaptador para una plataforma (Roo Code) que ya no existe.
- **Ignorar el pedido por completo.** Descartado — 3 de las debilidades señaladas (taxonomía de `LECCIONES.md`, poda de R-017, falta de disparadores cuantitativos) son reales y no dependen del framing enterprise del pedido original.
- **Strategic Council como generación simulada de párrafos por rol en el mismo turno.** Descartado por la misma razón ya escrita en `ADR-008`: no es una segunda mirada independiente, es la misma autoauditoría de siempre con encabezados distintos.
- **Aprobar como "V4.0" reetiquetando solo lo que ya existe, sin cambios reales.** Descartado — sería, en palabras de `docs/PROPUESTA-OMEGA.md` sobre el mismo problema un día antes, "marketing interno" sin arquitectura nueva detrás del número.

## Consecuencias

- `LECCIONES.example.md`: taxonomía ampliada (patrón/antipatrón/incidente/playbook) + sección nueva "Cómo se poda" con regla concreta de partición.
- `RIESGOS.md`: R-017 pasa de "aceptado" a "mitigado".
- `GOBERNANZA.md`: nueva sección de métricas mínimas + 4º disparador cuantitativo de convocatoria.
- `adr/README.md`: se agregan las filas de ADR-008 y ADR-009 al índice ya existente — no se crea un `ADR_INDEX.md` nuevo (se evaluó y se descartó por duplicar un mecanismo que ya existía, mismo criterio que el resto de esta decisión).
- `ROADMAP.md`: el pedido "V4.0 Enterprise" se cierra con referencia a este ADR, mismo patrón que `ADR-008` cerró "Omega V5".
- Sin cambios a `opencode.template.json`, `MODELOS.md`, `SKILLS.md`, ni ningún componente de gobernanza estructural.
- `VERSION`: `3.1.0` → `3.2.0`.
- Si en el futuro llega un tercer pedido con el mismo framing (multiagente, consejo simulado, multiplataforma) bajo otro nombre, este ADR y `ADR-008` ya dejan el razonamiento escrito — no hace falta repetir el análisis completo, solo confirmar que sigue aplicando.
