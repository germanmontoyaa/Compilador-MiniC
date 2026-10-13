# miniC — Compilador de un lenguaje tipo C a MIPS

## Descripción

**miniC** es un compilador desarrollado en C como proyecto académico. Permite escribir programas en un lenguaje simplificado inspirado en C, analizar su sintaxis y generar código ensamblador MIPS.

El proyecto implementa las principales fases de un compilador: análisis léxico, análisis sintáctico, comprobaciones semánticas, gestión de símbolos y generación de código.

## Características

- **Análisis léxico:** reconocimiento de palabras reservadas, identificadores, números, operadores y comentarios mediante Flex.
- **Análisis sintáctico:** validación de la estructura de los programas mediante Bison.
- **Análisis semántico:** gestión de variables y constantes, detección de declaraciones duplicadas y uso de identificadores no declarados.
- **Tabla de símbolos:** almacenamiento de información sobre los identificadores del programa.
- **Generación de código:** representación de operaciones intermedias y generación de instrucciones ensamblador MIPS.
- **Control de flujo:** soporte para condicionales y bucles.
- **Entrada y salida:** operaciones para leer datos y mostrar resultados.
- **Ejemplos de prueba:** programas fuente y ejemplos de código ensamblador.

## Tecnologías utilizadas

- **C:** implementación del compilador.
- **Flex:** generación del analizador léxico.
- **Bison:** generación del analizador sintáctico.
- **GCC:** compilación del código fuente.
- **Make:** automatización del proceso de compilación.
- **MIPS:** arquitectura de destino del código generado.

## Estructura del proyecto

```text
miniC/
├── main.c
├── miniC.l
├── miniC.y
├── listaSimbolos.c
├── listaSimbolos.h
├── listaCodigo.c
├── listaCodigo.h
├── makefile
└── ficheros_de_prueba/
    ├── fibonacci.mc
    ├── dowhile.mc
    ├── matriz.mc
    ├── prueba.mc
    └── archivos .s de ejemplo
```

### Función de los principales archivos

| Archivo | Descripción |
|---|---|
| `main.c` | Punto de entrada del programa. Gestiona la entrada y ejecuta el análisis del código fuente. |
| `miniC.l` | Contiene las reglas del análisis léxico implementadas con Flex. |
| `miniC.y` | Define la gramática del lenguaje, las comprobaciones semánticas y la generación de código. |
| `listaSimbolos.c` | Implementa las operaciones de gestión de la tabla de símbolos. |
| `listaSimbolos.h` | Declara las estructuras y funciones relacionadas con los símbolos. |
| `listaCodigo.c` | Implementa la lista de operaciones de código generadas. |
| `listaCodigo.h` | Declara las estructuras y funciones relacionadas con el código. |
| `makefile` | Automatiza la generación de archivos y la compilación del proyecto. |
| `ficheros_de_prueba/` | Contiene programas de ejemplo y archivos de salida para realizar pruebas. |

## Instalación de dependencias

En sistemas Linux basados en Debian o Ubuntu, instala las herramientas necesarias:

```bash
sudo apt update
sudo apt install build-essential make flex bison libfl-dev
```

## Compilación

Clona el repositorio y accede al directorio del proyecto:

```bash
git clone <URL_DEL_REPOSITORIO>
cd miniC
```

Compila el proyecto mediante Make:

```bash
make
```

Este comando utiliza las reglas del `makefile` para generar los archivos necesarios y compilar el ejecutable `miniC`.

Para eliminar el ejecutable y los archivos generados, utiliza:

```bash
make limpia
```

## Uso

Para analizar un programa fuente, ejecuta el compilador pasando como argumento el archivo `.mc`:

```bash
./miniC ficheros_de_prueba/fibonacci.mc
```

Si el programa es válido, el compilador muestra información sobre los símbolos y las operaciones o el código generado.

Los archivos ensambladores `.s` incluidos en el directorio de pruebas pueden abrirse con un simulador compatible con MIPS, como MARS o QtSPIM, para examinar o ejecutar el código correspondiente.

## Sintaxis del lenguaje

miniC implementa un subconjunto de C con una sintaxis simplificada.

### Ejemplo de programa

```c
fibonacci() {
    var int n, limite, a, b, c;

    print("Introduce un número: ");
    read(limite);

    a = 0;
    b = 1;

    for (n = 0; n < limite; n = n + 1) {
        c = a + b;
        a = b;
        b = c;
    }

    print(a, "\n");
}
```

### Elementos del lenguaje

- **Tipos de datos:** `int`.
- **Declaración de variables:** `var int x, y;`.
- **Declaración de constantes:** `const int limite = 10;`.
- **Asignaciones:** `x = expresion;`.
- **Entrada de datos:** `read(x);`.
- **Salida de datos:** `print(x);` o `print("texto");`.
- **Condicionales:** `if` y `else`.
- **Bucles:** `while`, `do ... while` y `for`.
- **Operaciones aritméticas:** suma, resta, multiplicación, división y menos unario.
- **Operadores relacionales:** `<`, `>`, `<=`, `>=`, `==` y `!=`.
- **Comentarios:** `//` y `/* ... */`.

La sintaxis exacta depende de las reglas implementadas en `miniC.y`. El lenguaje no admite necesariamente todas las características del C estándar.

## Ejemplos incluidos

El directorio `ficheros_de_prueba/` contiene programas que permiten comprobar diferentes funcionalidades del compilador.

| Archivo | Descripción |
|---|---|
| `fibonacci.mc` | Ejemplo de cálculo de la sucesión de Fibonacci. |
| `dowhile.mc` | Ejemplo de utilización del bucle `do ... while`. |
| `matriz.mc` | Programa de prueba relacionado con operaciones con matrices. |
| `prueba.mc` | Programa adicional para probar el compilador. |
| Archivos `.s` | Ejemplos de código ensamblador MIPS. |

## Detección de errores

El compilador contempla diferentes errores durante el análisis del programa:

- Símbolos no reconocidos.
- Errores sintácticos, con información sobre la línea.
- Identificadores demasiado largos.
- Valores enteros fuera del rango admitido.
- Declaraciones duplicadas de variables o constantes.
- Uso de identificadores no declarados.
- Asignaciones a constantes.

## Objetivos del proyecto

El objetivo principal es comprender el funcionamiento interno de un compilador y la interacción entre sus distintas fases:

1. Transformar el código fuente en una secuencia de tokens.
2. Comprobar que el programa cumple la gramática definida.
3. Gestionar los símbolos y realizar comprobaciones semánticas.
4. Representar las operaciones del programa.
5. Generar código ensamblador para la arquitectura MIPS.

## Limitaciones

miniC es un proyecto educativo y no pretende ser un compilador completo del lenguaje C. Su funcionalidad está limitada a las construcciones definidas en su gramática y a las características implementadas en el código fuente.

## Autoría

Proyecto académico de compiladores.

- **Lenguaje de implementación:** C.
- **Herramientas principales:** Flex, Bison y GCC.
