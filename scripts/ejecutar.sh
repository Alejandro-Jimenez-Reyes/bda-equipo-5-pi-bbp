#!/usr/bin/env bash
# 🐳 EJECUTAR DENTRO DEL CONTENEDOR "hadoop"
# Equipo 5 - bbp y distbbp (Hadoop 3.3.6, modo standalone)
set -e

# --- Localizar Hadoop y el jar de ejemplos --------------------------------
HADOOP_HOME="${HADOOP_HOME:-$(dirname "$(dirname "$(readlink -f "$(which hadoop)")")")}"
JAR=$(ls "$HADOOP_HOME"/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar)
WORK=/tmp/bbp_work            # carpeta de trabajo (modo standalone = sistema de archivos local)
echo "HADOOP_HOME = $HADOOP_HOME"
echo "JAR         = $JAR"

# --- Limpiar corridas anteriores (bbp NO acepta un directorio que ya existe) ---
rm -rf "$WORK"; mkdir -p "$WORK"

echo; echo "=== 0. Lista de ejemplos (deben aparecer bbp y distbbp) ==="
hadoop jar "$JAR" 2>&1 | grep -E "^ *(bbp|distbbp)" || true

echo; echo "=== 1. bbp: digitos hex 1..100 de pi con 4 maps ==="
# uso: bbp <startDigit> <nDigits> <nMaps> <workingDir>
hadoop jar "$JAR" bbp 1 100 4 "$WORK/bbp_1_100" 2>&1 | tee "$WORK/log_bbp_1_100.txt"
echo "--- pi.txt ---";  cat "$WORK/bbp_1_100/pi.txt"
echo "--- bytes del archivo .hex (cada byte = 2 digitos hex) ---"
od -An -v -tx1 "$WORK/bbp_1_100/pi_1_100.hex" | head -4

echo; echo "=== 2. bbp: digitos 1001..1020 (sin calcular los 1000 anteriores) ==="
hadoop jar "$JAR" bbp 1001 20 2 "$WORK/bbp_1001_20" 2>&1 | tee "$WORK/log_bbp_1001_20.txt"
echo "--- digitos hex 1001..1020 (bytes en hex = digitos hex) ---"
od -An -v -tx1 "$WORK/bbp_1001_20/pi_1001_20.hex" | tr -d ' \n'; echo

echo; echo "=== 3. distbbp: bit 101 en adelante (b = 100 bits saltados) ==="
# uso: distbbp <b> <nThreads> <nJobs> <type> <nPart> <remoteDir> <localDir>
hadoop jar "$JAR" distbbp 100 2 2 m 2 "$WORK/dist_remote_100" "$WORK/dist_local_100" 2>&1 \
  | tee "$WORK/log_distbbp_100.txt" | tail -5

echo; echo "=== 4. distbbp: b = 1000 ==="
hadoop jar "$JAR" distbbp 1000 2 2 m 2 "$WORK/dist_remote_1000" "$WORK/dist_local_1000" 2>&1 \
  | tee "$WORK/log_distbbp_1000.txt" | tail -5

echo; echo "Listo. Todo quedo en $WORK"
