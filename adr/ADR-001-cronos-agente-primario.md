# ADR-001: Cronos como agente primario, no como plantilla de Titán

**Estado:** aceptada (retroactiva — decisión ya tomada en v1.0.0, formalizada como ADR en v2.0.0)
**Fecha original:** v1.0.0 (finales de junio de 2026)

## Contexto
Los 10 Titanes tienen cada uno su `titanes/<nombre>.template.md` y su entrada `"mode": "subagent"` en `opencode.template.json`. Cronos, el orquestador, no tiene plantilla propia — vive embebido en `MASTER_PROMPT.md`, con `"mode": "primary"`.

## Decisión
Cronos se define directamente en `MASTER_PROMPT.md` en vez de en una plantilla separada dentro de `titanes/`.

## Alternativas consideradas
- **Darle a Cronos su propia plantilla** (`titanes/cronos.template.md`), simétrica a los otros 10. Se descartó porque el rol de Cronos —orquestar, no ejecutar tareas de dominio— no encaja en la misma estructura de "Rol / Lo que haces / Lo que NO haces / Checklist" pensada para Titanes que sí tocan código o infraestructura directamente.

## Consecuencias
- Cronos queda fuera de la disciplina de "resumen de reglas de oro embebido en cada plantilla" que sí aplicaba a los otros 10 (mitigado parcialmente porque `MASTER_PROMPT.md` sí las referencia, pero no con el mismo mecanismo de redundancia).
- La asimetría es real y visible (`ls titanes/` no incluía `cronos`), lo cual fue correcto documentar en vez de ocultar — el propio `AGENCY.md` v2.0 lo aclaraba en la tabla de componentes.

**Nota de continuidad (v3.0.0):** esta decisión queda parcialmente absorbida por `ADR-007-consolidacion-agente-unico.md` — al eliminarse las 10 plantillas de Titanes, la pregunta que originó este ADR ("¿Cronos necesita una plantilla propia como los demás?") deja de tener sentido, porque ya no hay "los demás" con quien comparar. Se conserva este ADR como registro histórico de por qué Cronos siempre se trató distinto, que es precisamente el antecedente que hizo natural la consolidación de v3.0.0.
