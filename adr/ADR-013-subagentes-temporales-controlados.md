# ADR-013: Subagentes temporales controlados

Fecha: 2026-08-06
Estado: aceptada

## Contexto

Cronos v4.1.0 concentraba la ejecución en un único agente y prohibía toda delegación, aunque OpenCode ya ofrecía una herramienta `task`. Algunas revisiones, investigaciones y unidades mecánicas pueden ejecutarse en paralelo sin justificar el regreso de los diez Titanes permanentes.

## Decisión

Desde v4.2.0 Cronos puede delegar hasta tres unidades acotadas a subagentes temporales cuando el runtime lo soporte, con `subagent_depth: 1`. Cronos sigue siendo el agente primario, interlocutor, responsable y autoridad final.

Cada encargo delegado debe declarar alcance, archivos permitidos, pruebas y las reglas de seguridad. Los subagentes no leen secretos, no modifican Git, no despliegan, no migran, no generan gasto, no delegan y no aprueban tareas. Cronos inspecciona sus cambios y repite las verificaciones antes de aceptar el resultado.

## Alternativas consideradas

- Restaurar los diez Titanes permanentes: descartado; reintroduce coordinación, autoridad distribuida y puntos de fallo que `ADR-007` eliminó.
- Mantener prohibida toda delegación: descartado; desperdicia una capacidad del runtime para tareas acotadas y revisiones independientes.
- Delegación temporal controlada: elegida porque conserva el agente único y sus checkpoints, limitando la superficie de riesgo.

## Consecuencias

Se gana paralelismo para investigación, implementación y revisión acotadas. Se acepta el costo de inspeccionar resultados y repetir pruebas. La delegación nunca sustituye el ciclo de autocrítica, la confirmación humana en decisiones críticas ni la responsabilidad de Cronos.
