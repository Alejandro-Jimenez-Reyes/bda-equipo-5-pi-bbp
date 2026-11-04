# Mini ejercicio · Equipo 5 · "Dígitos lejanos de π"

**Objetivo:** comprobar que `bbp` calcula dígitos *sin* los anteriores y que `distbbp` coincide con él.
**Requisito:** contenedor `hadoop` funcionando. 🐳 = dentro del contenedor.

## Parte A · bbp
1. 🐳 Define las variables:
   ```bash
   HADOOP_HOME=${HADOOP_HOME:-$(dirname $(dirname $(readlink -f $(which hadoop))))}
   JAR=$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar
   ```
2. 🐳 Calcula los dígitos hexadecimales **101 al 120** de π usando **2 maps**, con directorio de trabajo `/tmp/ej_bbp`.
3. 🐳 Muestra el archivo `.hex` como texto hexadecimal con `od -An -v -tx1 … | tr -d ' \n'`.
4. Compara con los dígitos 101–120 que obtendrías de `datos/referencia_pi_hex.txt` (cuenta desde el primer dígito).

## Parte B · distbbp
5. 🐳 Ejecuta `distbbp` con **b = 100**, 2 hilos, 2 jobs por suma, tipo `m`, 2 partes, `remoteDir=/tmp/ej_remote` y `localDir=/tmp/ej_local`.
6. ¿Qué dígitos hexadecimales de π obtuviste? ¿En qué posición empiezan? (Pista: cada dígito hex son 4 bits.)

## Preguntas
a) ¿Por qué `bbp` no genera `pi.txt` en la Parte A?
b) ¿Qué error da `bbp` si pides `nDigits = 10`? ¿Por qué?
c) ¿Por qué los maps de `bbp` no reciben partes del mismo tamaño?
d) ¿Qué pasa si repites el comando del paso 2 sin cambiar el directorio de trabajo?
