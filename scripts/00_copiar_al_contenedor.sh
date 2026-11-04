#!/usr/bin/env bash
# 💻 EJECUTAR EN TU COMPUTADORA (no dentro del contenedor)
# Copia datos/ y scripts/ al contenedor "hadoop" en /tmp/bbp
set -e
docker start hadoop >/dev/null 2>&1 || true      # por si estaba detenido
docker exec hadoop rm -rf /tmp/bbp
docker exec hadoop mkdir -p /tmp/bbp
docker cp datos   hadoop:/tmp/bbp/datos
docker cp scripts hadoop:/tmp/bbp/scripts
docker exec -u root hadoop chmod -R a+rwX /tmp/bbp
echo "OK: archivos copiados a /tmp/bbp dentro del contenedor"
