# RIESGOS.md — Registro de riesgos de Cronos

Componente global (resuelve la Mejora Importante I2 de la auditoría empresarial que dio origen a v2.0.0: antes de esa versión, los riesgos vivían dispersos en `MODELOS.md`, `LOOPS.md` y `README.md`, cada uno en su propio formato). Se revisa en cada convocatoria del Consejo Estratégico (`GOBERNANZA.md`).

**No se copia a `~/.config/opencode/` por `instalar-global.sh`** — es un documento de gobierno del kit, no una instrucción que Cronos deba tener siempre cargada en contexto.

Esquema por entrada:
```
Categoría: cuello de botella / dependencia excesiva / punto único de fallo / duplicidad /
           contexto / coordinación / escalabilidad / vendor lock-in / deriva arquitectónica
Probabilidad: baja / media / alta
Impacto: bajo / medio / alto / crítico
Mitigación: qué existe hoy o qué se planea
Estado: abierto / mitigado / aceptado / cerrado
Dueño: qué "sombrero" de GOBERNANZA.md lo sostiene
Última revisión: fecha
```

---

### R-001: Vía de exfiltración de secretos sin restringir vía el tool `bash`
Categoría: punto único de fallo (de un control) · Probabilidad: media · Impacto: crítico
Mitigación: `permission.bash` del único agente (`opencode.template.json`, movido a `adapters/opencode/opencode.template.json` en v4.0.0 sin cambios de contenido — ver `adr/ADR-011`) pide confirmación ante `cat *.env*`, `cat *secret*`, `cat *credential*`, `env`, `printenv*`, `history`. No cubre variantes con `sed`/`awk`/sustitución de proceso que no calcen con estos patrones — sigue siendo una mitigación parcial, no una garantía completa.
Estado: mitigado (no cerrado del todo — ver límite arriba)
Dueño: Oficial de seguridad
Última revisión: 2026-07-14 (v3.0.0)

### R-002: Propagación de reglas de oro al contexto de sesión sin confirmar
Categoría: contexto · Probabilidad: baja en la capa de configuración (ver evidencia) / desconocida en la capa de contenido · Impacto: crítico
Mitigación: **Verificado en la capa de configuración (2026-07-16, `opencode-ai` v1.18.3):** se instaló el binario real de OpenCode y se replicó exactamente `scripts/instalar-global.sh` en un `$HOME` aislado, más un proyecto nuevo con `opencode.json` copiado de `opencode.template.json` sin editar (ese archivo vivía en la raíz del kit en ese momento; se movió a `adapters/opencode/opencode.template.json` en v4.0.0 sin cambios de contenido, ver `adr/ADR-011` — la verificación sigue aplicando, el contenido no cambió). El `opencode.json` de proyecto no declara `instructions` — solo el global lo hace. `opencode debug config`, corrido desde el proyecto, muestra `instructions` con las rutas a `AGENCY.md`/`MASTER_PROMPT.md` ya resueltas en la configuración final: el archivo de proyecto no pisa al global, se fusionan. Esto cierra la duda de si la ausencia de `instructions` en `opencode.template.json` deja al proyecto sin reglas de oro — no lo deja.
**Pendiente, capa de contenido (la parte que de verdad requiere una sesión real):** que el contenido de esos archivos llegue al contexto del modelo de forma que Cronos pueda listar las reglas de oro sin que se las repitan — ver "Verificación recomendada" en `README.md`, paso 2. Esto sigue sin poder automatizarse ni simularse sin credenciales de modelo reales.
Estado: mitigado (capa de configuración, v3.2.0) / abierto (capa de contenido — la prueba de sesión real sigue pendiente)
Dueño: Arquitecto técnico
Última revisión: 2026-07-16 (evidencia: `opencode debug config` contra `opencode-ai` v1.18.3, ver `docs/AUDITORIA-10-10-verificacion-R002.md`)

### R-003: Gobernanza de un solo aprobador, sin backup
Categoría: punto único de fallo · Probabilidad: alta (es el modo de operación actual) · Impacto: alto
Mitigación: patrón de "sombreros" delegables en `GOBERNANZA.md`. Mitiga el riesgo de *diseño* (no hay estructura para delegar); no elimina el riesgo de *hecho* mientras una sola persona siga ocupando los cuatro sombreros.
Estado: mitigado (estructuralmente) / aceptado (en la práctica, mientras haya un solo operador)
Dueño: Product Owner
Última revisión: 2026-07-14 (v3.0.0)

### R-004: Cero automatización de verificación propia del kit
Categoría: deriva arquitectónica · Probabilidad: alta (ya ocurrió) · Impacto: medio
Mitigación: `scripts/verificar-kit.sh` cubre JSON válido, ausencia de voseo, ShellCheck, y la referencia de versión en `GUIA-PARA-PRINCIPIANTES.md`. Desde v3.0.0 ya no incluye el chequeo de consistencia de plantillas contra `fragments/` (ese mecanismo se eliminó junto con las 10 plantillas de Titanes — ver ADR-007). No cubre: instalación real en un HOME temporal (sigue siendo manual), ni CI que lo corra automáticamente en cada cambio.
Estado: mitigado (parcialmente — falta CI real)
Dueño: Arquitecto técnico
Última revisión: 2026-07-14 (v3.0.0)

### R-005: ~~Proveedor de modelo compartido entre roles con veto (Cronos/Crío)~~ — cerrado, ya no aplica
Categoría: punto único de fallo · Probabilidad: — · Impacto: —
Mitigación: no aplica.
Estado: cerrado (v3.0.0) — desaparece con la consolidación a un único agente (ADR-007): ya no hay dos roles con veto en agentes separados que pudieran compartir proveedor por accidente. El riesgo equivalente ahora es R-015 (autoauditoría sin segunda mirada independiente).
Dueño: Arquitecto técnico
Última revisión: 2026-07-14 (v3.0.0)

### R-006: Plugins de Capa 2 (loops automáticos) inmaduros
Categoría: dependencia excesiva · Probabilidad: alta · Impacto: bajo (mitigado por diseño: nunca se activa sin confirmación explícita, y las reglas de oro aplican igual con o sin loop)
Mitigación: documentada en `LOOPS.md` con issues puntuales citados; Cronos solo lo ofrece como paso opcional en Nivel 2/3.
Estado: aceptado
Dueño: Arquitecto técnico
Última revisión: 2026-07-14 (v3.0.0)

### R-007: Dependencias de mantenedor único (Superpowers, `ui-ux-pro-max`)
Categoría: dependencia excesiva · Probabilidad: baja · Impacto: alto si ocurre
Mitigación: versión fijada por tag/release (mitiga deriva). Sin plan de contingencia ante abandono — ver `ROADMAP.md`.
Estado: abierto
Dueño: Arquitecto técnico
Última revisión: 2026-07-14 (v3.0.0)

### R-008: Lock-in de orquestación a una sola plataforma — reabierto en v4.0.0 con mitigación distinta
Categoría: vendor lock-in · Probabilidad: baja · Impacto: medio si ocurre
Mitigación: hasta v3.4.0 este riesgo estaba cerrado porque el uso exclusivo de OpenCode era una decisión deliberada (ADR-007), no lock-in accidental. Esa decisión deliberada CAMBIÓ en v4.0.0 (`adr/ADR-011-multiplataforma-opencode-codex-vscode.md`): ahora hay 3 plataformas soportadas (OpenCode, Codex CLI, VS Code/Copilot) mediante adaptadores delgados sobre un núcleo agnóstico — no un regreso sin criterio al patrón de v2.0.0 (ADR-005) que este mismo riesgo ya vio fallar (solo un adaptador llegó a verificarse). Mitigación activa: cada adaptador es independiente entre sí (retirar uno no afecta a los otros dos, ver ADR-011 punto 8) y el núcleo nunca depende de mecánica específica de ninguna plataforma. Sigue habiendo lock-in residual a estas 3 nombradas específicamente — ver R-009 para el criterio de por qué se limitó a estas 3 y no a una lista abierta.
Estado: abierto (reabierto v4.0.0) — con mitigación activa, no sin abordar
Dueño: Arquitecto técnico
Última revisión: 2026-08-03 (v4.0.0)

### R-009: ~~Nombres de plataforma fijados en el tiempo (caso Roo Code)~~ — cerrado, lección reaplicada en v4.0.0 sin reabrir el riesgo
Categoría: vendor lock-in / deriva arquitectónica · Probabilidad: — · Impacto: —
Mitigación: no aplica como riesgo abierto — pero la LECCIÓN sí se aplicó activamente al escribir `adr/ADR-011` (v4.0.0): las 3 plataformas nombradas ahí (OpenCode, Codex CLI, VS Code) tienen necesidad real confirmada hoy, no una lista de "por si acaso" como la de ADR-005, que se comprometió a 4 nombres y perdió uno (Roo Code) antes de terminar de escribirse. Si alguna de las 3 sigue el mismo camino, se retira ese adaptador puntual sin afectar a los otros dos (arquitectura de adaptadores independientes, ver ADR-011 punto 8) — no hace falta reabrir este riesgo ni el ADR completo para eso.
Estado: cerrado (v3.0.0), lección reaplicada en v4.0.0
Dueño: Arquitecto técnico
Última revisión: 2026-08-03 (v4.0.0)

### R-010: ~~Bloques compartidos entre las 10 plantillas de Titanes mantenidos a mano~~ — cerrado, ya no aplica
Categoría: duplicidad / deriva arquitectónica · Probabilidad: — · Impacto: —
Mitigación: no aplica.
Estado: cerrado (v3.0.0) — desaparece de raíz con la consolidación a un único agente: ya no hay 10 plantillas que sincronizar, así que `fragments/` y `scripts/generar-plantillas.py` se eliminan del kit (ver ADR-003, nota de continuidad).
Dueño: Arquitecto técnico
Última revisión: 2026-07-14 (v3.0.0)

### R-011: `GUIA-PARA-PRINCIPIANTES.md` fuera del sistema versionado
Categoría: deriva arquitectónica · Probabilidad: — · Impacto: —
Mitigación: cerrado desde v2.0.0 — incorporada a la raíz del kit, referencia de versión puntual reemplazada por instrucción genérica, verificado por `scripts/verificar-kit.sh`.
Estado: cerrado
Dueño: Product Owner
Última revisión: 2026-07-14 (v3.0.0 — sin cambios de fondo, solo confirmación de que sigue cerrado)

### R-012: Carpeta original del kit como dependencia de ruta relativa indefinida
Categoría: punto único de fallo · Probabilidad: media · Impacto: medio
Mitigación: sin resolver todavía — ninguna documentación advierte explícitamente que la carpeta extraída del `.zip` debe persistir en disco. Candidato para `ROADMAP.md` corto plazo.
Estado: abierto
Dueño: Product Owner
Última revisión: 2026-07-14 (v3.0.0)

### R-013: Sin medición real de gasto en modelos pagos
Categoría: contexto / escalabilidad · Probabilidad: alta (nunca se midió) · Impacto: bajo mientras el uso sea de un solo operador; crece con más proyectos simultáneos
Mitigación: sin resolver — requiere telemetría, no implementada.
Estado: abierto
Dueño: Product Owner
Última revisión: 2026-07-14 (v3.0.0)

### R-014: `npx autoskills --dry-run` falla con error (no "no detectó nada") en un proyecto recién creado
Categoría: coordinación (entre Cronos y una herramienta externa) · Probabilidad: alta (ocurre siempre que se corre `autoskills` antes de que exista un manifiesto de dependencias) · Impacto: bajo (interrumpe el flujo de A2, no compromete seguridad ni datos)
Mitigación: `autoskills` detecta stack leyendo `package.json`/Gradle/config existentes — en una carpeta vacía no tiene qué leer, y falla con error en vez de devolver "sin resultados". Cerrado desde v2.0.1: `MASTER_PROMPT.md` (paso A2) scaffoldea un `package.json` mínimo antes de invocar `autoskills` cuando el stack candidato es Node.js/npm, y trata cualquier error/timeout/salida vacía igual que "no detectó nada" (sin reintentar el mismo comando).
Estado: cerrado (v2.0.1) — pendiente de verificación empírica contra una corrida real (no se pudo instalar `autoskills` en el entorno de verificación por restricciones de red).
Dueño: Arquitecto técnico
Última revisión: 2026-07-14 (v3.0.0 — sin cambios de fondo)

### R-015: Autoauditoría sin segunda mirada independiente (nuevo en v3.0.0)
Categoría: punto único de fallo (de criterio, no de control técnico) · Probabilidad: media · Impacto: alto
Mitigación: con un único agente, el mismo modelo que escribió el código es quien lo audita en el `self-critique-loop` — puede repetir el mismo punto ciego con el que lo escribió, algo que la arquitectura multiagente de v2.0.1 (Crío separado de Prometeo) mitigaba de forma estructural, aunque sin confirmación empírica de que la separación fuera efectiva en la práctica (ver R-002 histórico). Mitigación adoptada: `MODELOS.md` recomienda explícitamente usar un modelo distinto (o más fuerte en razonamiento) específicamente para la fase de seguridad del `self-critique-loop` en proyectos Nivel 2/3 — reduce la correlación entre "quién escribió" y "quién audita" sin volver a un diseño multiagente. No es una garantía equivalente a una segunda mirada humana independiente.
Estado: aceptado (trade-off consciente de la consolidación a agente único — ver ADR-007)
Dueño: Oficial de seguridad
Última revisión: 2026-07-14 (v3.0.0)

### R-016: Skill Forge sin curaduría puede inflar el catálogo (nuevo en v3.1.0, extendido en v4.1.0)
Categoría: deriva arquitectónica · Probabilidad: media · Impacto: medio
Mitigación: `capability-gap-analysis` (ver `SKILLS.md`) nunca instala una skill nueva por sí sola — siempre propone y espera confirmación explícita del operador antes de escribir un `SKILL.md` nuevo, mismo patrón de checkpoint que ya usa el resto del kit (A2.1, B2.1). Extendido en v4.1.0 (`adr/ADR-012`) a dos ejes nuevos, con la misma mitigación central intacta: la detección ahora puede dispararse dentro de un proyecto, no solo al cerrarlo (vía `.cronos/gaps-detectados.md`, ver `self-critique-loop` paso 6) — sigue proponiendo, nunca instalando sola; y la promoción de una skill local a global (`scripts/promover-skill.sh`) requiere su propio checkpoint de confirmación explícita, separado del de creación local. `ROADMAP.md` mantiene el ítem de revisar si el número total de skills conviene fusionarse, con datos reales de uso.
Estado: aceptado
Dueño: Arquitecto técnico
Última revisión: 2026-08-06 (v4.1.0)

### R-022: Skills promovidas por uso repetido pueden tener una `description` mal curada (nuevo en v4.1.0)
Categoría: deriva arquitectónica · Probabilidad: media · Impacto: bajo
Mitigación: una skill que demostró servir en 2+ proyectos (`adr/ADR-012`) tiene evidencia de necesidad real, pero nace escrita a mitad de una tarea concreta, no con la misma pausa que tuvieron las 18 skills curadas del catálogo original — su `description` puede no estar lo bastante precisa para que la plataforma la active en el contexto correcto y no en otros. Mitigación: `scripts/promover-skill.sh` nunca la mezcla silenciosamente con las skills ya curadas — la deja en una sección aparte de `SKILLS.md` ("pendientes de revisión curada") hasta que alguien la revise a propósito. `capability-gap-analysis` además pide releer la `description` antes de promover, no solo copiar el archivo tal cual.
Estado: abierto
Dueño: Arquitecto técnico
Última revisión: 2026-08-06 (v4.1.0)

### R-017: `LECCIONES.md` sin límite de tamaño (nuevo en v3.1.0)
Categoría: escalabilidad · Probabilidad: media (crece con cada proyecto Nivel 2/3 cerrado) · Impacto: bajo
Mitigación: regla concreta de partición desde v3.2.0 (`ADR-009`) — particiona por año al superar 30 entradas activas o 12 meses desde la primera entrada vigente, lo que ocurra primero; entradas ya incorporadas como skill se borran en vez de archivarse. Documentado en `LECCIONES.example.md`, sección "Cómo se poda". Ya no depende de que el Consejo lo note "a ojo" en cada convocatoria.
Estado: mitigado
Dueño: Arquitecto técnico
Última revisión: 2026-07-15 (v3.2.0)

### R-018: `browser-qa-e2e` (Playwright MCP) habilitado sin proporcionalidad al nivel del proyecto (nuevo en v3.3.0)
Categoría: deriva arquitectónica · Probabilidad: media · Impacto: bajo
Mitigación: la skill solo se ofrece en Nivel 2/3 con UI web — mismo criterio de proporcionalidad que ya aplica a Superpowers y a la Capa 2 de `LOOPS.md`; en Nivel 1 o en proyectos sin UI web sería fricción innecesaria y no se activa. `deploy-checklist` (condición 5) solo la exige cuando aplica.
Estado: mitigado por diseño — pendiente de verificación empírica en un proyecto real (ver `ROADMAP.md`, criterio de cierre de v3.3.0)
Dueño: Arquitecto técnico
Última revisión: 2026-07-16 (v3.3.0)

### R-019: Adaptadores de Codex CLI y VS Code verificados solo por documentación, no por sesión real (nuevo en v4.0.0)
Categoría: verificación incompleta · Probabilidad: media · Impacto: medio
Mitigación: a diferencia del adaptador de OpenCode (verificado con `opencode debug agent cronos` contra una sesión real, ver `docs/AUDITORIA-10-10-verificacion-R002.md`), los adaptadores de Codex CLI y VS Code (`adr/ADR-011`) se verificaron contra documentación pública vigente al 2026-08-03 — mismo criterio que ya usaba `LOOPS.md` desde v1.5.0 para el ecosistema de plugins de OpenCode, pero es la primera vez que ese criterio se aplica a mecánica de la que depende directamente la propagación de las reglas de oro (R-002), no solo a un plugin opcional de continuación. Mitigación activa: ambos README de adaptador (`adapters/codex/README.md`, `adapters/vscode/README.md`) marcan explícitamente qué no está verificado y piden confirmación manual en la primera sesión real de cada uno.
Estado: abierto — pendiente correr el equivalente de la auditoría R-002 contra sesiones reales de las dos plataformas nuevas (ver `ROADMAP.md`)
Dueño: Arquitecto técnico
Última revisión: 2026-08-03 (v4.0.0)

### R-020: Deriva entre `.cronos/` local y el núcleo del kit si no se corre `actualizar-proyecto.sh` (nuevo en v4.0.0)
Categoría: duplicidad / deriva arquitectónica · Probabilidad: media · Impacto: bajo
Mitigación: desde v4.0.0 (`adr/ADR-011`), cada proyecto tiene una copia local del núcleo en `.cronos/` — necesaria para que VS Code funcione de forma autosuficiente (ver Principio 6 de `AGENCY.md`), pero es, por definición, una segunda copia de algo que también vive en el kit fuente (y, para OpenCode/Codex CLI, también en la instalación global). Si el kit avanza de versión y un proyecto no vuelve a correr `scripts/actualizar-proyecto.sh`, ese proyecto sigue operando con reglas viejas sin que nada lo bloquee — mismo patrón de riesgo que ya identificaron R-010 (bloques de las 10 plantillas) y R-017 (`LECCIONES.md` sin límite), aplicado ahora a un tercer lugar. Mitigación activa: `.agencia-version` por proyecto + `actualizar-proyecto.sh` detecta y muestra la diferencia antes de aplicarla — pero correrlo sigue siendo manual, nada lo dispara solo.
Estado: abierto
Dueño: Arquitecto técnico
Última revisión: 2026-08-03 (v4.0.0)

### R-021: VS Code/Copilot no tiene respaldo global — un proyecto sin adoptar queda sin ninguna regla de Cronos ahí (nuevo en v4.0.0)
Categoría: cobertura incompleta · Probabilidad: media · Impacto: medio
Mitigación: en OpenCode y Codex CLI, incluso un proyecto que nunca corrió `nuevo-proyecto.sh`/`adoptar-proyecto.sh` igual carga el núcleo desde la instalación global (`~/.config/opencode/`, `~/.codex/`) si se corrió `instalar-global.sh` antes — hay un respaldo. VS Code/Copilot no tiene ese respaldo (ver `adapters/vscode/README.md`, "Instalación global vs. por proyecto"): si el operador abre en VS Code una carpeta cualquiera que nunca pasó por uno de esos dos scripts, Cronos simplemente no está ahí, sin ningún aviso previo.
Estado: abierto — sin mitigación automática todavía, queda documentado como limitación conocida del adaptador
Dueño: Arquitecto técnico
Última revisión: 2026-08-03 (v4.0.0)

Nota: `docs/PROPUESTA-QA-BROWSER-INTELLIGENCE.md` §11 anticipa tres riesgos candidatos sin numerar todavía (QA-A self-healing, QA-B credenciales de entorno de prueba, QA-C falsos positivos de QA visual) que se dan de alta como entradas `R-XXX` reales recién cuando las fases correspondientes se implementen (v3.4.0/v3.5.0) — no antes, para que ninguna referencia a `R-XXX` en el kit quede sin la entrada real detrás (ver `scripts/verificar-kit.sh`, chequeo 5/7).
