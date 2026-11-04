# resultados/

Archivos `*_referencia.txt`: valores **esperados**, calculados de forma independiente con Python (`mpmath`) replicando el formato del código fuente de Hadoop 3.3.6. Sirven para comparar.

La carpeta `resultados/real/` se crea al ejecutar `scripts/traer_resultados.sh` y contiene la salida real obtenida en el contenedor (logs, `pi.txt`, archivos `.hex`).

> Los logs de Hadoop (líneas `INFO mapreduce.Job …`) cambian en cada ejecución (tiempos, IDs de job); lo que debe coincidir son los dígitos.
