# STACK.md — Formato de referencia (Cronos debe seguir esta estructura)

## Resumen
Una línea: qué se construye y con qué stack general.

## Nivel del proyecto
1 (simple) / 2 (medio) / 3 (empresarial) — ver criterios en `AGENCY.md`.
- ¿Workflow completo de Superpowers y ciclo de autocrítica completo activados?: sí/no — por qué

## Entorno
- Plataforma de orquestación usada en este proyecto y su versión (`opencode --version`, `codex --version`, o versión de la extensión de GitHub Copilot en VS Code):
- ¿Coincide con la versión contra la que se verificó el core (ver sección "Versión y compatibilidad" en `AGENCY.md`)?: sí/no — si no, qué se comprobó antes de seguir
- Superpowers instalado (si el nivel lo activa): vX.X.X — mismo dato que ya pide `README.md` al instalar

## Frontend
- Tecnología:
- Por qué:

## Identidad visual (`design-benchmark`, si el proyecto tiene frontend visible)
- Referencias reales consultadas (2-3):
- Design DNA — paleta:
- Design DNA — tipografía:
- Design DNA — tono:
- Qué default genérico se evita explícitamente:

## Backend
- Tecnología:
- Por qué:

## Base de datos
- Motor:
- Por qué:

## Hosting / Despliegue
- Servicio:
- CI/CD:
- Por qué:

## Testing (`browser-qa-e2e`, si el proyecto tiene UI web y es Nivel 2/3)
- Herramientas:
- ¿Playwright MCP habilitado?: sí/no — por qué
- Ubicación de la suite E2E (si está habilitado): `qa/tests/`
- Última corrida — fecha y resultado (reporte en `qa/reports/`, no versionado):

## Integraciones externas
- Lista de APIs/servicios de terceros, si aplica (si no hay, decir "ninguna")

## Costo (`cost-intelligence`, si hay algún servicio de pago)
- Servicios de pago y estimación mensual aproximada:
- ¿Límite de gasto o alerta de facturación configurada en cada uno?: sí/no

## Gestión de secretos
- ¿`.gitignore` instalado y completado para este stack (a partir de `gitignore.template`)?: sí/no
- ¿Existe `.env.example` con las variables necesarias documentadas, sin valores reales?: sí/no
- Mecanismo de secretos en producción (variables de entorno del hosting, gestor de secretos, etc.):

## Modelo recomendado
- Modelo activo al momento de escribir esto, y para qué fase se recomendó (ver `MODELOS.md`):
- ¿Se documentó un alterno ante caída del proveedor principal?: sí/no

## Convenciones de código
- Estilo:
- Estructura de carpetas:
- Nomenclatura:
