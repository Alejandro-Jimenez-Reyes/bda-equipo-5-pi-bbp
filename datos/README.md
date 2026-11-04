# datos/

`bbp` y `distbbp` **no leen archivos de entrada**: los "datos" son solo números (parámetros) que se pasan en la línea de comandos. Por eso aquí solo hay valores de **referencia** para comprobar que el resultado es correcto:

| Archivo | Contenido |
|---|---|
| `referencia_pi_hex.txt` | Primeros 100 dígitos hexadecimales de π |
| `referencia_pi_decimal.txt` | Primeros 100 decimales de π |

Fueron calculados con la librería `mpmath` de Python (independiente de Hadoop).
