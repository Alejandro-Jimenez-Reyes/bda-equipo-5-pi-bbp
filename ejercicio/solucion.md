# Solución · Equipo 5

## Parte A
```bash
hadoop jar $JAR bbp 101 20 2 /tmp/ej_bbp
od -An -v -tx1 /tmp/ej_bbp/pi_101_20.hex | tr -d ' \n'; echo
```
Resultado esperado: **`29B7C97C50DD3F84D5B5`** (dígitos hex 101–120 de π).
Nota: `nDigits = 20` es múltiplo de 4 y `startDigit = 101 ≥ 1`, por eso es válido.

## Parte B
```bash
hadoop jar $JAR distbbp 100 2 2 m 2 /tmp/ej_remote /tmp/ej_local
```
Línea final esperada: **`3707344A4093 E (12 hex digits)`**.
Con b = 100 se saltan 100 bits = 100/4 = **25 dígitos hex**, así que empieza en el dígito **26**:
π = 3.243F6A8885A308D313198A2E0 | **3707344A4093**… (los 25 primeros dígitos están a la izquierda de la barra).

## Respuestas
a) `pi.txt` (conversión a decimal) solo se escribe cuando `startDigit = 1`, porque para convertir a decimal hacen falta **todos** los dígitos desde el principio.
b) `IllegalArgumentException: nDigits = 10 is not a multiple of 4`: cada llamada a la fórmula BBP devuelve 4 dígitos hex (16 bits = 2 bytes), así que el cálculo se hace en bloques de 4.
c) Calcular un dígito lejano cuesta más (las sumas tienen más términos), por lo que `bbp` reparte los splits por **carga de trabajo** equilibrada, no por cantidad de dígitos.
d) Falla con `Working directory … already exists. Please remove it first.` Hay que borrar el directorio o usar otro.
