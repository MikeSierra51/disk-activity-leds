# LEDs de actividad de discos

[English](README.md) · [Français](README.fr.md)

**Un indicador de actividad, no otro monitor del sistema.**

LEDs de actividad de discos devuelve al panel de KDE Plasma los testigos
físicos de almacenamiento que ya no incluyen muchos ordenadores modernos. Cada
disco, partición o volumen USB seleccionado dispone de su propio LED compacto:

- gris: sin actividad;
- verde: lectura;
- rojo: escritura;
- naranja: lectura y escritura simultáneas.

Durante una copia grande de un disco a otro, los indicadores permiten ver de
un vistazo qué volúmenes siguen activos sin abrir un monitor ni interpretar
gráficas. Al pasar el puntero sobre un LED aparecen la identificación del
sistema, el punto de montaje, la capacidad, el estado y las velocidades de
lectura y escritura.

## Funciones principales

- un LED por dispositivo de bloques o partición real seleccionada;
- detección automática de unidades SATA, NVMe, MMC y USB;
- actualización de dispositivos conectados cada diez segundos;
- etiquetas opcionales de hasta cinco caracteres;
- conservación de los ajustes de medios extraíbles mediante el UUID, cuando
  está disponible;
- mantenimiento del color durante cuatro segundos para hacer visibles las
  ráfagas breves;
- anchura del componente adaptada automáticamente a los LED mostrados;
- lectura directa de los contadores del núcleo Linux;
- sin privilegios de administrador ni servicio permanente;
- interfaz, metadatos y documentación en inglés, francés y español.

Cada volumen detectado puede mostrarse u ocultarse en la configuración. Las
opciones guardadas siempre tienen prioridad sobre los valores iniciales.

## Requisitos

- Linux con `/sys/class/block` y `/proc/self/mountinfo`;
- KDE Plasma 5.27;
- Python 3 para la detección pausada del hardware y las conexiones;
- un intérprete POSIX `/bin/sh` para el muestreo ligero de los contadores;
- GNU gettext para construir el paquete distribuible desde el código fuente.

Esta rama está destinada a Plasma 5. El futuro traslado a Plasma 6 se describe
en [`docs/PORTING_PLASMA6.md`](docs/PORTING_PLASMA6.md).

## Instalación

Construya el paquete distribuible:

```sh
./scripts/build-package.sh
```

Instale el archivo generado:

```sh
kpackagetool5 --type Plasma/Applet --install \
  releases/candidates/disk-activity-leds-1.3.0-plasma5.plasmoid
```

Para actualizarlo, sustituya `--install` por `--upgrade`. Para desinstalarlo:

```sh
kpackagetool5 --type Plasma/Applet --remove org.mike.diskactivityleds
```

El archivo `.plasmoid` también se puede seleccionar desde la opción gráfica
**Instalar elemento gráfico desde un archivo local…**.

## Configuración

Abra **Configurar LEDs de actividad de discos…** desde el menú contextual.
Seleccione los volúmenes que desea mostrar y, si lo desea, introduzca una
etiqueta de cinco caracteres como máximo. Si se deja vacía, se conserva el
nombre del núcleo, por ejemplo `sda2` o `nvme0n1p3`.

El componente solicita automáticamente la anchura que necesita. Los ejemplos
de [`extras/panel`](extras/panel) pueden crear un panel específico flexible,
pero no forman parte del paquete de la Store y deben adaptarse primero a la
pantalla correspondiente.

## Funcionamiento

El detector identifica los discos físicos y sus particiones a partir de sysfs,
relaciona los puntos de montaje mediante `/proc/self/mountinfo` y utiliza los
UUID para recuperar los ajustes de los medios extraíbles. No abre ningún
archivo almacenado en los volúmenes.

La actividad se obtiene de los campos 3 y 7 de
`/sys/class/block/DISPOSITIVO/stat`. QML convierte estos contadores acumulados
en velocidades. Los valores inferiores a 1 KiB/s se consideran ruido de
metadatos. Una actividad detectada mantiene su color durante cuatro segundos.

El paquete público utiliza un pequeño script POSIX portátil y no contiene un
binario específico para una arquitectura. El código fuente del antiguo lector
en C se conserva en `extras/native` únicamente para comparar el rendimiento.

## Medios extraíbles

Un LED gris significa que no se ha observado ninguna entrada o salida durante
el periodo de retención. **No** significa que se pueda desconectar directamente
un medio extraíble. Utilice siempre **Desmontar** o **Extraer de forma segura**,
porque el sistema de archivos todavía podría tener que vaciar sus cachés.

## Verificación

Ejecute todas las comprobaciones locales con:

```sh
./scripts/check.sh
```

Las comprobaciones cubren la detección del hardware, los UUID, las rutas de
montaje, la seguridad del lector portátil, los contadores grandes, JSON, XML,
QML, JavaScript y los catálogos de traducción.

## Privacidad y privilegios

El componente solo lee metadatos locales del núcleo. No envía telemetría, no
lee el contenido de los archivos, no escribe en los volúmenes supervisados y
no solicita privilegios elevados.

## Autor y licencia

Copyright 2026 **Mike.Sierra.Nevada**.

Licencia **GPL-3.0-or-later**. Consulte
[`LICENSES/GPL-3.0-or-later.txt`](LICENSES/GPL-3.0-or-later.txt).
