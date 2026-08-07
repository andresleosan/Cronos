# AUDITORIA.md — Formato de referencia (Cronos debe seguir esta estructura)

## Resumen
Una línea: qué se auditó y veredicto general (listo para evolucionar / requiere trabajo antes de tocarlo / riesgo alto).

## Contexto
- Repo/proyecto:
- Fecha de la auditoría:
- ¿Se corrió `/init` antes de auditar (para tener `AGENTS.md` real del repo)?: sí/no

## Arquitectura y deuda técnica
Por cada hallazgo:
- Hallazgo:
- Severidad: crítica / alta / media / baja
- Evidencia (archivo, patrón, dato concreto):
- Impacto si no se corrige:

## Seguridad (checklist de `security-baseline`)
Cubre como mínimo: autenticación/autorización, datos sensibles expuestos (incluye logs y consola), secretos hardcodeados o ya commiteados en el historial, existencia de `.gitignore` apropiado, validación de entradas, superficie de ataque de integraciones externas, dependencias con vulnerabilidades conocidas, y rate-limiting/protección contra abuso en endpoints propios.
- Hallazgo:
- Severidad: crítica / alta / media / baja
- Evidencia:
- Impacto si no se corrige:

## Cobertura de pruebas real
- ¿Existen pruebas automatizadas?: sí / no / parcial
- Cobertura reportada vs. verificada:
- Flujos críticos sin cobertura:
- ¿Hace falta escribir pruebas de caracterización antes de tocar código legacy sin tests?: sí/no

## Costo (checklist de `cost-intelligence`)
- Servicios de pago detectados (IA, APIs, hosting, base de datos gestionada):
- ¿Alguno sin límite de gasto o alerta de facturación configurada?: sí/no — cuál
- Hallazgo (si aplica): severidad crítica/alta/media/baja — no bloquea el veredicto de la auditoría por sí solo, ver `skills-custom/cost-intelligence`

## Tabla resumen
| # | Hallazgo | Área | Severidad |
|---|---|---|---|
| 1 | | | |

## Veredicto
- ¿Hay algún hallazgo crítico que bloquee cualquier trabajo nuevo?: sí/no — cuál
- Nivel de proyecto asignado (1/2/3), mismos criterios que en `STACK.example.md`:

Con esto, Cronos escribe `MEJORAS.md` (formato en `MEJORAS.example.md`) y lo presenta al operador antes de convertirlo en `tasks.md` (checkpoint B2.1 en `MASTER_PROMPT.md`). Una vez confirmado el alcance, Cronos documenta el stack real en `STACK.md` (B3 en `MASTER_PROMPT.md`) antes de generar `tasks.md`.
