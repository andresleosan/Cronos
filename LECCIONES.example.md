# LECCIONES.md — Formato de referencia (Cronos debe seguir esta estructura)

Memoria evolutiva entre proyectos. A diferencia de `RIESGOS.md`/`ROADMAP.md`/`GOBERNANZA.md` (gobierno del kit, no se cargan en sesión), `LECCIONES.md` **sí se lee y se actualiza en sesión** — es la skill `capability-gap-analysis` la que la escribe, normalmente al cerrar un proyecto Nivel 2/3 (paso 7.5 de `MASTER_PROMPT.md`).

La instancia real (`LECCIONES.md`, sin `.example`) vive en `~/.cronos/` — ruta neutral de plataforma, compartida entre OpenCode, Codex CLI y VS Code desde v4.0.0 (ver `adr/ADR-011-multiplataforma-opencode-codex-vscode.md`) — y se genera la primera vez que corre `scripts/instalar-global.sh` a partir de este archivo — **nunca se sobrescribe en reinstalaciones posteriores**, para no perder lecciones ya registradas.

## Cómo se agrega una entrada

Cada cierre de proyecto (o cada vez que un mismo problema se repite sin skill que lo cubra) agrega una entrada nueva **al final** del archivo, siguiendo este formato:

```
### AAAA-MM-DD — <nombre o descripción breve del proyecto>
Categoría: skill faltante / MCP faltante / lección de arquitectura / lección de seguridad / lección de costo / patrón / antipatrón / incidente / playbook / otra
Qué pasó: descripción concreta de la fricción o el hallazgo — no una generalización abstracta.
Qué se haría distinto: acción concreta para el próximo proyecto similar.
¿Generó una skill nueva?: sí (cuál) / no — si es "no" porque apareció una sola vez, dilo explícitamente.
```

Las 4 categorías nuevas (agregadas en v3.2.0, ver `ADR-009`) distinguen el *tipo* de conocimiento cuando no se trata de un hueco de skill/MCP:
- **patrón** — algo que funcionó bien y conviene repetir tal cual en el próximo proyecto similar.
- **antipatrón** — algo que se intentó y salió mal, para no repetirlo (distinto de "incidente": acá no hubo daño, solo mal resultado).
- **incidente** — algo que falló con impacto real (dato perdido, hallazgo de seguridad que llegó tarde, deploy roto) — más grave que un antipatrón.
- **playbook** — una secuencia de pasos concreta que conviene copiar literalmente la próxima vez (a diferencia de "patrón", que es un criterio, no una receta).

No son excluyentes de las categorías anteriores — si una lección es a la vez "skill faltante" y "patrón" (ej. una skill nueva que resuelve algo que ya funcionaba bien manualmente), usa la que mejor explique *qué hacer distinto la próxima vez*, que es el campo que realmente importa.

## Ejemplo (entrada de referencia, no una lección real — bórrala en la primera instancia real del archivo)

### 2026-07-15 — Ejemplo de formato
Categoría: skill faltante
Qué pasó: un proyecto Nivel 2 necesitó comparar 3 referencias visuales de la competencia antes de diseñar el frontend, y no había una skill que guiara ese proceso — se improvisó sin criterio consistente.
Qué se haría distinto: usar `design-benchmark` desde el inicio (skill agregada en v3.1.0 a partir de esta misma fricción).
¿Generó una skill nueva?: sí — `design-benchmark`.

## Cómo se poda (regla concreta, cierra R-017 — ver `RIESGOS.md`)

`LECCIONES.md` se particiona por año cuando pasa **cualquiera** de estos dos umbrales, lo que ocurra primero:
- supera **30 entradas** activas (no cuentan las ya podadas), o
- pasaron **12 meses** desde la fecha de la primera entrada vigente.

Al particionar: las entradas del año que se cierra se mueven a `LECCIONES-AAAA.md` (mismo formato, sin `.example`), y `LECCIONES.md` queda con las entradas del año en curso más una línea al principio: `Años anteriores: ver LECCIONES-AAAA.md, LECCIONES-AAAA.md...`. Antes de mover una entrada, revisa si ya se incorporó como skill (`¿Generó una skill nueva?: sí`) — esas se pueden borrar en vez de archivar, porque la skill ya es la memoria persistente.

## Qué NO hacer con este archivo

- No lo uses como bitácora de decisiones normales del proyecto — eso ya vive en `tasks.md`/`STACK.md`/`BRIEF.md` de cada proyecto. Acá solo van lecciones que valen la pena recordar en el *próximo* proyecto.
- No registres el mismo tipo de fricción dos veces sin verificar primero si ya hay una entrada anterior — revisa el archivo antes de escribir, para no duplicar.
- No dejes que crezca sin revisión — la regla de poda de arriba es la que dispara la partición; no hace falta esperar a que el Consejo lo note "a ojo".
