# ADR-007: Consolidación a un único agente (Cronos) y eliminación de adapters multiplataforma

**Estado:** aceptada (nueva en v3.0.0)
**Fecha:** 2026-07-14

## Contexto
Desde v1.0.0 hasta v2.0.1, la agencia coordinaba 10 subagentes especializados (`titanes/*.template.md`, cada uno con su propia entrada `agent.<nombre>` en `opencode.json`) más un orquestador, Cronos, que no programaba — solo delegaba (ver ADR-001). Sobre esa base, v2.0.0 había sumado una capa de adaptadores multiplataforma (ADR-005, ADR-006) para no depender de una sola plataforma de orquestación.

Pedido explícito de simplificación: reducir la agencia a un único agente que orqueste todo él mismo, manteniendo la calidad mediante autocrítica en vez de mediante agentes separados, con uso exclusivo de OpenCode.

## Decisión
1. **Un único agente, Cronos**, con `mode: primary`, absorbe las 10 especialidades como fases de un mismo ciclo de trabajo (arquitectura, backend, frontend, datos, integraciones, rendimiento) y dos fases de autocrítica obligatorias (seguridad, QA) que reemplazan el veto que antes ejercían agentes separados (Crío, Temis).
2. Se elimina `titanes/*.template.md` (las 10 plantillas) y el mecanismo de composición asociado (`fragments/`, `scripts/generar-plantillas.py`), porque ya no hay múltiples archivos que mantener sincronizados — ver nota de continuidad en ADR-003.
3. Se elimina `adapters/` por completo (Claude Code, Codex CLI, Roo Code-EOL, y el propio adaptador de OpenCode como concepto separado). OpenCode vuelve a ser la única plataforma soportada, de forma explícita — revierte ADR-005 y ADR-006, vuelve al espíritu original de ADR-004.
4. El catálogo de skills (`skills-custom/`) se expande de 7 a 14: se agregan `self-critique-loop`, `security-baseline`, `backend-patterns`, `database-design`, `performance-baseline`, `deploy-checklist` y `external-integrations` — cada una concentra la disciplina que antes vivía embebida en la plantilla de un Titán específico. Ver `SKILLS.md` para el catálogo completo.
5. `MODELOS.md` cambia su criterio de asignación de "por Titán" a "por fase del trabajo dentro de una misma sesión de Cronos" — ver nota de continuidad en ADR-002.
6. La agencia se renombra de "Agencia Los Titanes" a **"Cronos"** — el mismo nombre del único agente que queda, ya sin necesidad de distinguir entre "el kit" y "el agente".

## Alternativas consideradas
- **Mantener los 10 subagentes y solo simplificar la documentación.** Descartado — no resuelve el pedido explícito de un único agente orquestador; además, no hay confirmación empírica de que las reglas de oro lleguen de forma confiable a un subagente invocado vía `task` (`RIESGOS.md` R-002, abierto desde v1.3.0), así que la arquitectura multiagente cargaba un riesgo sin cerrar desde el principio.
- **Un único agente, pero sin ciclo de autocrítica explícito** (confiar en que un modelo suficientemente capaz revise su propio trabajo "de forma natural"). Descartado — sin un mecanismo explícito y nombrado (`self-critique-loop`), la revisión de seguridad y QA se vuelve opcional en la práctica, exactamente el tipo de "buena intención sin garantía" que ADR-003 ya identificó como insuficiente para las reglas de oro.
- **Conservar los adaptadores multiplataforma "por si acaso".** Descartado — en la práctica, solo el adaptador de OpenCode llegó a verificarse empíricamente; los demás quedaron como borradores sin uso real. Mantener esa superficie tiene costo de mantenimiento real y beneficio nulo mientras el uso siga siendo exclusivamente OpenCode.

## Consecuencias
- **Menos superficie que mantener:** un núcleo (`AGENCY.md`, `MASTER_PROMPT.md`, `SKILLS.md`, `skills-custom/`) en vez de núcleo + 10 plantillas + fragments + 4 adaptadores.
- **Menos redundancia de revisión independiente:** lo que antes era una segunda mirada de un agente distinto (Crío auditando lo que hizo Prometeo) ahora es el mismo agente cambiando de sombrero. Es una contrapartida real, no cosmética — documentada como riesgo aceptado en `RIESGOS.md` R-015, con su mitigación (recomendar un modelo distinto específicamente para la fase de auditoría en proyectos Nivel 2/3).
- **`opencode.json` se simplifica** de 10 entradas `agent.<titán>` a una sola `agent.cronos` — los patrones de `permission.bash` que antes estaban repartidos entre Tetis (`*migrate*`), Crío (patrones anti-secretos) y Jápeto (`*--prod*`) se consolidan en un único bloque, porque un único agente los necesita todos.
- **`scripts/elegir-modelos.sh` (plural, por Titán) se reemplaza por `scripts/elegir-modelo.sh`** (singular, con recordatorio de fase) — cambio de nombre deliberado para que la interfaz de línea de comandos refleje la nueva arquitectura.
- **R-005, R-008, R-009 y R-010 de `RIESGOS.md`** (todos relacionados con el diseño multiagente o multiplataforma) se cierran por dejar de aplicar — no porque se resolvieran, sino porque el problema que describían ya no existe en esta arquitectura. Se documentan como cerrados con motivo, no se borran, para no perder el registro de por qué existieron.
- **R-002** (propagación de reglas de oro a un contexto de sesión) sigue abierto, pero cambia de forma: ya no es "¿le llega `instructions` a un subagente invocado vía `task`?" sino "¿le llega `instructions` a la única sesión que existe?" — más simple de verificar, pero todavía pendiente de una sesión real de OpenCode.
