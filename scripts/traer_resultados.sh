#!/usr/bin/env bash
# 💻 EJECUTAR EN TU COMPUTADORA, despues de correr ejecutar.sh dentro del contenedor
# Trae los resultados REALES del contenedor a resultados/real/
set -e
mkdir -p resultados/real
docker cp hadoop:/tmp/bbp_work/bbp_1_100/pi.txt           resultados/real/pi_1_100.txt
docker cp hadoop:/tmp/bbp_work/bbp_1_100/pi_1_100.hex     resultados/real/pi_1_100.hex
docker cp hadoop:/tmp/bbp_work/bbp_1001_20/pi_1001_20.hex resultados/real/pi_1001_20.hex
for f in log_bbp_1_100 log_bbp_1001_20 log_distbbp_100 log_distbbp_1000; do
  docker cp hadoop:/tmp/bbp_work/$f.txt resultados/real/$f.txt
done
echo "OK: resultados copiados a resultados/real/"
