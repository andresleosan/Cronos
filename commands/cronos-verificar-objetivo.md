---
description: Trabaja hacia un objetivo puntual y no lo marca como listo sin evidencia verificable
---

Objetivo para esta sesión: $ARGUMENTS

Trabaja hacia ese objetivo dentro del alcance ya definido en `STACK.md` y `tasks.md` — no lo
expandas ni lo reinterpretes. Regla no negociable, igual que ya exige el paso de QA del
`self-critique-loop` ("Nada de humo", Principio 8 de `AGENCY.md`): **no reportes el objetivo como
cumplido sin evidencia verificable** — corre el comando de verificación que corresponda (tests,
build, linter, lo que aplique al objetivo) y muestra el resultado real, no una suposición de que
"probablemente ya funciona".

Si en el camino llegas a un punto que las reglas de oro reservan para el operador (desplegar, migración
destructiva, hallazgo de seguridad crítico), para ahí — el objetivo queda "bloqueado", no
"cumplido", y me explicas por qué.

Si después de dos vueltas del `self-critique-loop` no logras progreso real (mismo resultado en dos
intentos seguidos, o no hay forma de verificar sin datos/permisos que no tienes), dilo en vez de
seguir intentando lo mismo — es preferible que me avises a que sigas iterando sin rumbo.

Al cerrar, dime explícitamente uno de estos tres estados y por qué: **cumplido** (con la
evidencia), **bloqueado** (con el motivo puntual), o **necesita más alcance** (si te das cuenta de
que el objetivo tal como está escrito no alcanza para completarse).
