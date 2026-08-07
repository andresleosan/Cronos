# Guía para usar Cronos (si nunca programaste)

Esta guía asume que estás en una computadora con **Windows**. Si tienes Mac o Linux, en general es más simple (ya traen una terminal lista y no hace falta instalar Git Bash) — al final hay una nota corta para esos casos.

No hace falta que entiendas de programación para seguir esto. Vas a copiar y pegar casi todo. Lo único que sí necesitas: paciencia la primera vez (30-45 minutos, una sola vez). OpenCode ya trae modelos de IA gratuitos incluidos, así que no necesitas pedirle nada a nadie para arrancar — más adelante, si quieres algo más potente, puedes conectar una cuenta de pago con un proveedor de IA por tu cuenta (ver el Paso 9).

## ¿Qué programa uso, de los tres?

Cronos funciona igual con tres programas distintos — **esta guía sigue el camino de OpenCode** en detalle, paso a paso, porque es el único de los tres con modelos gratuitos incluidos desde el primer minuto (no hace falta ninguna cuenta paga para probarlo). Si ya sabes que prefieres otro, al final de esta guía hay una versión más corta para **Codex CLI** y otra para **VS Code (GitHub Copilot)** — reutilizan los Pasos 1 a 4 de acá (son iguales para los tres) y después se separan. Si no tienes ninguna preferencia, sigue con OpenCode tal como continúa la guía.

## ¿Qué es esto, en una frase?

No es un programa que abres y ya está. Es un instructivo para otro programa (OpenCode) que hace que, en vez de un asistente de IA genérico, tengas **un asistente que actúa como un equipo completo de desarrollo** (Cronos): analiza qué tecnología conviene, escribe el código de principio a fin (backend, frontend, base de datos), y antes de darlo por terminado se detiene a revisar su propio trabajo con la misma exigencia que antes aplicaban varios revisores distintos — seguridad, pruebas, rendimiento. Tú le cuentas en español, con tus palabras, qué quieres construir; él decide la tecnología, escribe el código, lo revisa, lo prueba y lo publica, parando siempre a pedirte permiso antes de algo importante o riesgoso.

---

## Antes de arrancar: 5 palabras que vas a ver seguido

- **Terminal** (o "consola"): una ventana donde, en vez de hacer clic, escribes texto (un "comando") y aprietas Enter para que la computadora haga algo. Da un poco de respeto la primera vez, pero en esta guía vas a copiar y pegar casi todo.
- **Carpeta**: lo mismo que en el Explorador de Windows — acá se la llama igual, o a veces "directorio".
- **Comando**: una línea de texto que escribes en la terminal y ejecutas con Enter.
- **Script**: un archivo con varios comandos adentro, que los corre todos de una — te ahorra escribirlos a mano uno por uno.
- **Proveedor de IA**: la empresa que le da "cerebro" a Cronos. OpenCode incluye modelos gratuitos propios sin necesidad de elegir ninguno — si más adelante conectas uno de pago (por ejemplo para modelos más potentes), el costo depende de cuánto lo uses, como los datos del celular.

---

## Paso 1 — Descomprimir el archivo

1. Busca el archivo `.zip` de Cronos que te compartieron (algo como `cronos-vX_Y_Z.zip` — probablemente en tu carpeta de Descargas; el número de versión no importa, siempre es el mismo procedimiento).
2. Clic derecho sobre el archivo → **"Extraer todo..."**.
3. Elige dónde guardarlo — te recomiendo Escritorio o Documentos, para encontrarlo fácil. Clic en **"Extraer"**.
4. Va a aparecer una carpeta llamada `cronos` con varios archivos adentro. Es normal no reconocer la mayoría — no vas a tocarlos directamente.

---

## Paso 2 — Instalar dos programas de base (una sola vez)

### 2a. Node.js
1. Entra a **nodejs.org**.
2. Descarga el botón que dice **LTS** (es la versión recomendada y estable).
3. Abre el instalador descargado y haz clic en "Next" en cada pantalla, sin cambiar nada, hasta terminar.

### 2b. Git para Windows
1. Entra a **git-scm.com/download/win** (la descarga suele arrancar sola).
2. Abre el instalador y haz clic en "Next" en todas las pantallas (son bastantes, ninguna requiere que cambies algo) hasta terminar.
3. Esto te da dos cosas: la herramienta `git` (que se usa por detrás, sin que la toques) y **Git Bash**, la terminal que vamos a usar en el resto de esta guía.

---

## Paso 3 — Abrir la terminal en la carpeta correcta

1. Abre en el Explorador de Windows la carpeta `cronos` que descomprimiste en el Paso 1.
2. Clic derecho en un espacio vacío **dentro** de esa carpeta (no sobre un archivo).
3. Elige **"Git Bash Here"** (esta opción aparece después de instalar Git).
4. Se abre una ventana oscura — esa es tu terminal, y ya está ubicada en la carpeta correcta. No hace falta que navegues a ningún lado.

---

## Paso 4 — Confirmar que quedó todo instalado

En esa ventana, escribe (o copia y pega) esto y aprieta Enter:
```bash
node --version
```
Deberías ver algo como `v22.x.x` (cualquier número 22 o mayor está bien).

```bash
git --version
```
Deberías ver algo como `git version 2.x.x`.

Si en cualquiera de los dos casos te dice "command not found" o "no se reconoce como un comando", cierra la ventana de Git Bash, ábrela de nuevo (Paso 3) y prueba otra vez — a veces hace falta reabrirla después de instalar algo. Si sigue sin andar, revisa el Paso 2.

---

## Paso 5 — Instalar OpenCode (el programa con el que vas a hablar)

En la misma ventana:
```bash
npm install -g opencode-ai
```
Va a bajar y instalar el programa — puede tardar uno o dos minutos y es normal que aparezca mucho texto. Cuando termine y te devuelva el cursor, confirma que funcionó:
```bash
opencode --version
```
Deberías ver un número de versión.

---

## Paso 6 — Instalar el "núcleo" de Cronos (una sola vez, para siempre)

Sigues en la misma ventana, dentro de la carpeta `cronos`:
```bash
chmod +x scripts/*.sh
```
(Esto le da permiso de ejecución a los scripts. No cambia nada visible y no hace daño correrlo aunque no hiciera falta.)

```bash
./scripts/instalar-global.sh
```
Este es el paso importante: copia a Cronos, sus reglas y sus skills a un lugar de tu computadora donde OpenCode los va a encontrar siempre, en cualquier proyecto futuro — **esto se hace una sola vez por computadora**. Vas a ver varias líneas confirmando qué se copió, y cerca del final un aviso sobre "Superpowers" — instrucciones detalladas para instalarlo en el Paso 7 (opcional, pero recomendado).

---

## Paso 7 — Superpowers (opcional, pero recomendado)

**Qué es, en una frase:** un conjunto de buenas prácticas extra que Cronos usa en proyectos medianos o grandes — por ejemplo, probar que todo funcione de verdad antes de dar algo por terminado, u organizar el trabajo en pasos ordenados en vez de ir a los tumbos. Nada se rompe si no lo instalas: Cronos funciona igual sin esto, solo que con menos disciplina extra en proyectos grandes. Puedes hacerlo ahora (5 minutos) o saltarlo e instalarlo más adelante repitiendo estos mismos pasos — no hay apuro.

### 7a. Buscar el número de versión más reciente
1. Abre tu navegador (Chrome, Edge, el que uses) y entra a esta dirección:
   ```
   github.com/obra/superpowers/releases
   ```
2. Vas a ver una lista de versiones, ordenadas de la más nueva a la más vieja. Fíjate en la primera de la lista, arriba de todo — tiene un nombre corto que empieza con "v" seguido de números, por ejemplo `v1.4.2` (el número real que veas va a ser otro, no importa cuál sea).
3. Selecciona ese texto con el mouse y cópialo (Ctrl+C). Lo vas a pegar en el paso siguiente.

### 7b. Instalarlo
1. Vuelve a la ventana de Git Bash que ya tenías abierta (o abre una nueva: clic derecho en cualquier carpeta → "Git Bash Here", como en el Paso 3).
2. Escribe esto y aprieta Enter:
   ```bash
   opencode
   ```
   La pantalla va a cambiar — eso es OpenCode abriéndose, es lo mismo que va a pasar en el Paso 10.
3. Copia este texto tal cual:
   ```
   Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/TAG/.opencode/INSTALL.md
   ```
4. Antes de pegarlo, reemplaza la palabra `TAG` por el número que copiaste en el paso 7a. Por ejemplo, si copiaste `v1.4.2`, el texto te tiene que quedar así:
   ```
   Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/v6.2.0/.opencode/INSTALL.md
   ```
   (Con tu número real en vez de `v1.4.2` — usa el que viste en la página del Paso 7a, no copies este ejemplo literal.)
5. Pega ese texto ya corregido en la ventana y aprieta Enter. OpenCode va a leer las instrucciones de instalación por su cuenta y hacer el resto solo — puede tardar uno o dos minutos y vas a ver bastante texto pasar, es normal.
6. Cuando termine, escribe esto para confirmar que quedó bien instalado:
   ```
   Confírmame que Superpowers quedó instalado con la versión que te pasé, no apuntando a la rama "main".
   ```
   Esto importa: instalarlo con un número fijo (en vez de seguir siempre "lo último de todo") evita que el comportamiento del agente cambie de golpe sin que te enteres, si en el futuro sale una versión nueva.

Listo — ya puedes seguir al Paso 8. Si más adelante quieres actualizar Superpowers a una versión más nueva, repites estos mismos pasos (7a y 7b) con el número de versión que encuentres en ese momento.

---

## Paso 8 — Crear tu primer proyecto

Piensa un nombre corto para lo que vas a construir, sin espacios ni tildes (por ejemplo `mi-primera-app`). En la misma ventana:
```bash
./scripts/nuevo-proyecto.sh mi-primera-app
cd mi-primera-app
opencode
```
La pantalla va a cambiar a algo más parecido a una aplicación real, dentro de la misma ventana. Eso es OpenCode arrancando — es normal que se vea distinto a la terminal de antes.

---

## Paso 9 — Sobre los modelos de IA (no tienes que hacer nada todavía)

OpenCode ya viene con modelos gratuitos propios activados — no hace falta crear ninguna cuenta ni pedirle una clave a nadie para empezar. Cuando hables con Cronos por primera vez (Paso 10), él mismo va a revisar qué hay disponible en tu computadora y te va a proponer qué modelo usar, explicándote el motivo — solo tienes que confirmar o pedir un cambio. Más adelante, mientras trabaja, te va a avisar si conviene un modelo distinto según en qué esté trabajando (por ejemplo, algo más exigente cuando revisa seguridad) — siempre preguntando antes, nunca por su cuenta.

Si más adelante quieres modelos más potentes, puedes conectar tu propia cuenta de pago con un proveedor de IA (por ejemplo Anthropic, OpenAI o Google) con el comando `/connect` dentro de OpenCode, usando la clave de acceso (API key) de esa cuenta. No es necesario para arrancar — los modelos gratuitos ya incluidos alcanzan para probar el kit de punta a punta.

---

## Paso 10 — Empezar a hablar con Cronos

Escribe exactamente esto y aprieta Enter:
```
Eres Cronos, este es un proyecto nuevo, empieza el descubrimiento.
```

### Qué esperar de la conversación (para que no te agarre de sorpresa)
1. **Primero te va a hacer 4-5 preguntas** sobre tu idea: qué es, para quién, qué necesita tener sí o sí, y si hay alguna restricción (presupuesto, plazo, algo puntual). Contesta como si le explicaras la idea a una persona — no hace falta ningún término técnico.
2. **Después va a "pensar" un rato** (puede tardar) y te va a mostrar qué tecnología eligió y qué tan grande es el proyecto. **Acá se va a detener y pedirte que confirmes** — es a propósito: es tu momento de decir "sí, dale" o "no, cambiemos esto". No sigue solo sin tu aprobación.
3. **Después te va a proponer qué modelo de IA usar** (revisando primero qué hay disponible en tu computadora, como se explicó en el Paso 9) — otra vez, te lo muestra con el motivo y espera que confirmes antes de escribir nada.
4. **Una vez que confirmas todo, arranca a trabajar de verdad.** Vas a notar que, después de escribir código, se detiene a revisar su propio trabajo antes de seguir — eso es el "ciclo de autocrítica": se pone el sombrero de auditor de seguridad, después el de pruebas, y solo sigue si todo pasa limpio. Te va a volver a pedir tu confirmación antes de cualquier cosa riesgosa (borrar algo, publicar en internet, etc.). Esa pausa es una regla que Cronos nunca se salta.
5. **Puede ofrecerte cosas opcionales**, según el proyecto — por ejemplo, que siga trabajando solo cuando la ventana queda un rato sin actividad ("ejecución continua"), o si tu proyecto tiene pantallas/interfaz visual, una skill extra para el diseño. Las dos son opcionales: puedes decir que sí o que no, y si dices que no, todo sigue funcionando exactamente igual que antes — no se rompe nada por saltarlas.

---

## Para la próxima vez

Ya no hace falta repetir los Pasos 1 a 7 — eso fue una sola vez. De ahí en adelante, para seguir trabajando en un proyecto:
1. Abre Git Bash dentro de la carpeta de ese proyecto (clic derecho → "Git Bash Here", igual que el Paso 3).
2. Escribe `opencode` y Enter — retoma donde quedó.

Para arrancar un proyecto **nuevo**, repites solo el Paso 8 (con otro nombre) desde la carpeta `cronos`.

---

## Si algo sale mal

| Problema | Qué probar |
|---|---|
| "command not found" / "no se reconoce como un comando" | El programa correspondiente no quedó instalado, o falta reabrir Git Bash después de instalarlo. Repite el Paso 2 o 5. |
| "Permission denied" al correr un script | Vuelve a correr `chmod +x scripts/*.sh` (Paso 6) dentro de esa carpeta. |
| La ventana se cierra sola o queda trabada | Ciérrala, ábrela de nuevo (Paso 3), y prueba otra vez. |
| Cualquier otro mensaje de error | Copia el mensaje completo (selecciónalo con el mouse y Ctrl+C) y búscalo en la documentación de OpenCode (opencode.ai/docs) o pégalo en un buscador — mejor confirmar que adivinar. |

---

## Nota para Mac o Linux

Los pasos son casi iguales, con estas diferencias:
- No hace falta instalar Git Bash: la Terminal que ya viene en tu sistema (búscala como "Terminal") sirve igual.
- Git ya suele venir instalado; confírmalo con `git --version` — si falta, Mac te va a ofrecer instalarlo solo.
- Node.js se instala igual, descargando la versión LTS desde nodejs.org.
- En vez de clic derecho → "Git Bash Here", abres la Terminal y usas el comando `cd` seguido de la ruta de la carpeta (por ejemplo `cd ~/Desktop/cronos`) para ubicarte ahí.
- El resto de los comandos (`node --version`, `npm install -g opencode-ai`, `./scripts/instalar-global.sh`, etc.) son idénticos.

---

## Si prefieres Codex CLI en vez de OpenCode

Haz los Pasos 1 a 4 de arriba tal cual (descomprimir, instalar Node.js y Git, abrir la terminal, confirmar que quedaron instalados) — son idénticos. De ahí en adelante:

**Paso 5 (Codex en vez de OpenCode):**
```bash
npm install -g @openai/codex
```
Confirma con `codex --version`.

**Paso 6 (núcleo de Cronos):**
```bash
chmod +x scripts/*.sh
./scripts/instalar-global.sh --solo codex
```
(`--solo codex` porque no vas a usar OpenCode — si más adelante quieres probar los dos, corre `./scripts/instalar-global.sh` sin esa parte y te instala ambos.)

**Paso 7 (Superpowers):** no está disponible para Codex CLI todavía — sáltalo, Cronos funciona igual sin él.

**Paso 8 (primer proyecto):**
```bash
./scripts/nuevo-proyecto.sh mi-primera-app --solo codex
cd mi-primera-app
codex
```

**Paso 9 (modelos):** igual que con OpenCode — Codex te va a preguntar qué modelo usar, mostrándote las opciones con `/model` dentro de la conversación, y esperando que confirmes.

**Paso 10:** escribe exactamente lo mismo: `Eres Cronos, este es un proyecto nuevo, empieza el descubrimiento.` El resto de la conversación (preguntas, checkpoint de confirmación, ciclo de autocrítica) es igual que lo descrito arriba para OpenCode.

## Si prefieres VS Code (GitHub Copilot) en vez de OpenCode

Haz los Pasos 1, 2a y 4 de arriba (descomprimir, instalar Node.js, confirmar `node --version`) — Git no hace falta instalarlo aparte para este camino. En cambio de Git Bash, vas a usar VS Code directamente.

**Paso extra — instalar VS Code y Copilot (si todavía no los tienes):**
1. Descarga VS Code desde **code.visualstudio.com** e instálalo (Next en todas las pantallas).
2. Abre VS Code, ve al ícono de Extensiones (los cuadraditos, en la barra de la izquierda), busca "GitHub Copilot" e instálalo.
3. Te va a pedir iniciar sesión con una cuenta de GitHub — si no tienes una, es gratis crearla en github.com. Copilot tiene un plan gratuito limitado y planes pagos con más uso; para probar este kit alcanza con el gratuito.

**Paso 6 equivalente (núcleo de Cronos):** VS Code/Copilot no tiene instalación "para siempre" como los otros dos — cada proyecto lleva su propia copia, así que no hace falta este paso por separado; se hace junto con crear el proyecto.

**Paso 8 (primer proyecto):** abre una terminal dentro de VS Code (menú **Terminal → New Terminal**) y escribe:
```bash
chmod +x scripts/*.sh
./scripts/nuevo-proyecto.sh mi-primera-app --solo vscode
```
Después, desde el Explorador de archivos de tu sistema, abre la carpeta `mi-primera-app` con VS Code (**File → Open Folder...**).

**Paso 9 (modelos):** en la vista de Chat de Copilot (ícono de burbuja de chat en la barra izquierda), asegúrate de estar en modo **Agent** (hay un selector arriba del cuadro de texto). El modelo se elige con el ícono correspondiente en esa misma vista — prueba el que venga por defecto para arrancar, después puedes cambiarlo ahí mismo en cualquier momento.

**Paso 10:** en el cuadro de chat de Copilot, en modo Agent, escribe exactamente: `Eres Cronos, este es un proyecto nuevo, empieza el descubrimiento.` El resto de la conversación es igual que lo descrito arriba para OpenCode.

---

## Glosario completo (para volver a consultar)

- **Terminal / consola**: ventana donde escribes comandos en vez de hacer clic.
- **Comando**: una instrucción de texto que la terminal ejecuta al apretar Enter.
- **Script**: archivo con varios comandos adentro, pensado para correrlo de una sola vez.
- **Carpeta / directorio**: lo mismo, dos nombres distintos para la misma idea.
- **`cd`**: comando para "entrar" a una carpeta desde la terminal (viene de "change directory").
- **Instalar de forma global**: instalar algo una sola vez para que esté disponible en todos los proyectos futuros, no solo en uno.
- **Repositorio (repo) / Git**: sistema que guarda el historial de cambios de un proyecto. Lo usa la agencia por detrás; no necesitas entenderlo a fondo para empezar.
- **API key / clave de acceso**: una contraseña larga que te conecta con un proveedor de IA de pago. No hace falta para empezar (OpenCode incluye modelos gratuitos); si más adelante quieres conectar uno, la obtienes directamente creando una cuenta en ese proveedor — es personal, nunca se comparte.
- **Versión / tag**: el "número de edición" de un programa (por ejemplo `v1.4.2`) — sirve para instalar siempre exactamente la misma, en vez de "lo último" que puede cambiar en cualquier momento sin aviso.
- **Superpowers**: el paquete opcional del Paso 7 — le suma a Cronos buenas prácticas extra (probar antes de dar algo por terminado, trabajar en pasos ordenados) útiles en proyectos medianos o grandes.
- **Cronos**: el agente con quien hablas siempre. Analiza, programa, revisa su propio trabajo y despliega, cambiando de "sombrero" según la fase.
- **Ciclo de autocrítica**: el momento en que Cronos revisa su propio código recién escrito, primero como auditor de seguridad y después como si probara que todo funciona, antes de seguir adelante.
