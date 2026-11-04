# bda-equipo-5-pi-bbp · Pi por la fórmula BBP en Hadoop MapReduce

**Equipo 5 · Tema: Pi por fórmula BBP · Ejemplos: `bbp` y `distbbp` · Dificultad 🟡 Media**

**Integrantes:**
- Alejandro Jiménez Reyes
- Elías Francisco Maltrana Luna
- Daniel Ruvalcaba Juárez

> Convención: 💻 = comando en **tu computadora** · 🐳 = comando **dentro del contenedor** `hadoop`.

---

## 1. ¿Qué hace?

Calcula dígitos de π **sin calcular los anteriores**. Con la fórmula de Bailey–Borwein–Plouffe (1995) se puede obtener el dígito *n* de π en base 16 sin conocer los *n−1* previos.

| Ejemplo | Qué calcula | Cuándo usarlo |
|---|---|---|
| `bbp` | Dígitos **hexadecimales** de π desde una posición dada (hasta ~10⁸). Si empieza en 1, además escribe `pi.txt` con hex y decimal. | Posiciones "bajas" |
| `distbbp` | Bits de π a partir del bit *b+1* con una fórmula tipo BBP (la de Bellard), repartida en **muchos jobs MapReduce**. Diseñado para *b* ≥ 10⁸. | Posiciones enormes, cálculo que puede tardar días y se puede **reanudar** |

**Caso real:** verificar de forma independiente un récord de π (se calcula un dígito lejano con otro método y se compara) y **repartir trabajo pesado y desigual** en un clúster. La documentación del propio código de `distbbp` usa como ejemplo el cálculo del bit número 10¹⁵ + 57 de π, que en un clúster puede tardar días.

## 2. ¿Cómo funciona?

### `bbp` (un job MapReduce)
La fórmula: π = Σₖ 16⁻ᵏ · ( 4/(8k+1) − 2/(8k+4) − 1/(8k+5) − 1/(8k+6) )

```
 parámetros (startDigit, nDigits, nMaps)
          │
   BbpInputFormat  → crea nMaps "splits": (offset, longitud)   ← no hay archivo de entrada
          │
   ┌──────┼──────┬──────┐
   MAP 1  MAP 2  MAP 3  MAP 4     cada map calcula sus dígitos hex con 4 sumas (S1,S4,S5,S6)
   │      │      │      │          emite  clave = offset   valor = bytes con los dígitos
   └──────┴──────┴──────┘
          │  shuffle: agrupa y ordena por offset
       REDUCE (1 solo)             concatena los trozos en orden
          │
   pi_<inicio>_<n>.hex  +  pi.txt (solo si startDigit = 1)
```
Punto clave: los dígitos lejanos **cuestan más** que los cercanos, así que `bbp` reparte los splits por *carga de trabajo* y no en partes iguales (por eso los maps tienen tamaños distintos).

### `distbbp` (muchos jobs MapReduce)
El cálculo se descompone en sumas de la fórmula de Bellard (hasta 14 sumas). Cada suma se parte en `nJobs` trabajos; cada trabajo se parte en `nPart` partes que se ejecutan en el **map** (`m`), en el **reduce** (`r`) o mezclados (`x`). Los resultados parciales se guardan en `localDir`; por eso, si se interrumpe, se puede **reanudar** con otro `remoteDir`. Al final el cliente suma todo módulo 1 y imprime los bits.

## 3. Requisitos
- Contenedor `hadoop` de la práctica "Hadoop Standalone en contenedor Debian" funcionando (Hadoop 3.3.6).
- Docker y Git en tu computadora.
- Nada más: **no hay datos de entrada que descargar**.

## 4. Estructura del repositorio
```
bda-equipo-5-pi-bbp/
├── README.md
├── datos/        referencias de π (hex y decimal) para comparar
├── scripts/      00_copiar_al_contenedor.sh · ejecutar.sh · traer_resultados.sh
├── resultados/   salida esperada (*_referencia.txt) y salida real en resultados/real/
├── ejercicio/    ejercicio.md · solucion.md
└── presentacion.pdf
```

## 5. Paso a paso

### Paso 1 · Clonar el repo — 💻
```bash
git clone https://github.com/<USUARIO>/bda-equipo-5-pi-bbp.git
cd bda-equipo-5-pi-bbp
```

### Paso 2 · Copiar archivos al contenedor — 💻
```bash
docker start hadoop            # si estaba detenido
bash scripts/00_copiar_al_contenedor.sh
```
Quedan en `/tmp/bbp` dentro del contenedor.

### Paso 3 · Entrar al contenedor — 💻
```bash
docker exec -it hadoop bash
```
Tu prompt cambia a `hadoop@hadoop` o `root@hadoop`.

### Paso 4 · Ejecutar todo — 🐳
```bash
bash /tmp/bbp/scripts/ejecutar.sh
```
**Tiempo:** `bbp` tarda segundos; `distbbp` con b = 100 tardó unos 5 minutos y con b = 1000 bastante más, porque lanza muchos jobs pequeños. No está trabado: es normal que el cursor se quede parpadeando.

Si prefieres ir comando por comando:

```bash
# Variables
HADOOP_HOME=${HADOOP_HOME:-$(dirname $(dirname $(readlink -f $(which hadoop))))}
JAR=$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar
WORK=/tmp/bbp_work; rm -rf $WORK; mkdir -p $WORK

# bbp: dígitos hex 1..100 con 4 maps   (bbp <startDigit> <nDigits> <nMaps> <workingDir>)
hadoop jar $JAR bbp 1 100 4 $WORK/bbp_1_100
cat $WORK/bbp_1_100/pi.txt

# bbp: dígitos 1001..1020 sin calcular los anteriores
hadoop jar $JAR bbp 1001 20 2 $WORK/bbp_1001_20
od -An -v -tx1 $WORK/bbp_1001_20/pi_1001_20.hex | tr -d ' \n'; echo

# distbbp: (distbbp <b> <nThreads> <nJobs> <type> <nPart> <remoteDir> <localDir>)
hadoop jar $JAR distbbp 100 2 2 m 2 $WORK/dist_remote_100 $WORK/dist_local_100
```

### Paso 5 · Comprobar el resultado
Compara con `resultados/` y con `datos/referencia_pi_hex.txt`. Esto es lo que obtuvimos en nuestra ejecución real:

| Comando | Resultado obtenido |
|---|---|
| `bbp 1 100 4 …` → `pi.txt` | `Pi = 0x3.243F6A8885 A308D31319 …` y `Pi = 3.1415926535 8979323846 …` (idéntico a la referencia) |
| `bbp 1001 20 2 …` | `49f1c09b075372c98099` |
| `distbbp 100 …` | `3707344A4093 E (12 hex digits)` |
| `distbbp 1000 …` | `574E69A458FF 6 (12 hex digits)` |

**Cómo interpretar `distbbp`:** usa números `double`, por lo que acumula error de redondeo. Los valores exactos son `3707344A4093 8` (b = 100) y `574E69A458FE A` (b = 1000). Los primeros 11 dígitos siempre coinciden; el 12º puede variar ±1 (en b = 1000 salió `F` en vez de `E`) y el dígito tras el espacio es solo margen de error. Por eso la comparación debe hacerse sobre los primeros 11 dígitos.

### Paso 6 · Ver los resultados dentro del contenedor — 🐳
```bash
cat /tmp/bbp_work/bbp_1_100/pi.txt
ls /tmp/bbp_work/bbp_1_100            # out  pi.txt  pi_1_100.hex
od -An -v -tx1 /tmp/bbp_work/bbp_1_100/pi_1_100.hex | head -3
```

### Paso 7 · Traer los resultados a tu computadora — 💻 (después de `exit`)
```bash
bash scripts/traer_resultados.sh      # deja todo en resultados/real/
```

## 6. Errores frecuentes
| Mensaje | Causa y solución |
|---|---|
| `Working directory … already exists. Please remove it first.` | `bbp` exige un directorio nuevo. Usa otro nombre o `rm -rf` el anterior. |
| `nDigits = … is not a multiple of 4` | En `bbp`, `nDigits` debe ser múltiplo de 4. |
| `startDigit = 0 <= 0` | Las posiciones empiezan en 1. |
| `distbbp` imprime `dir (= …) already exists` y "No computation" | Reutilizaste `remoteDir`. Cambia el nombre (así se reanuda a propósito). |
| `docker: command not found` | Estás dentro del contenedor: los comandos `docker` van en 💻. Escribe `exit`. |
| `hadoop: command not found` | Estás en tu compu o te falta el `PATH`: entra con `docker exec -it hadoop bash`. |
| `No such file or directory` al ver `/tmp/bbp_work/...` | Estás en tu computadora, no en el contenedor; esos archivos solo existen dentro. |

## 7. Mini ejercicio
Ver [`ejercicio/ejercicio.md`](ejercicio/ejercicio.md) (solución en [`ejercicio/solucion.md`](ejercicio/solucion.md)).

## 8. Subir cambios a GitHub — 💻
```bash
git add .
git commit -m "Equipo 5: bbp y distbbp"
git push origin main
```

## 9. Referencias
- Bailey, Borwein, Plouffe. *On the Rapid Computation of Various Polylogarithmic Constants* (1996).
- F. Bellard. *A new formula to compute the n'th binary digit of pi* (1997).
- Código fuente: `hadoop-mapreduce-examples` → `BaileyBorweinPlouffe.java`, `pi/DistBbp.java`, `pi/DistSum.java`, `pi/math/Bellard.java`.
