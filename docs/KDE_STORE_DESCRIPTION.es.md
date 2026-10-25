# Texto para KDE Store en español

## Descripción breve

Indicadores virtuales de lectura y escritura para cada disco, partición o
volumen USB seleccionado. Un indicador de actividad, no otro monitor del
sistema.

## Descripción

LEDs de actividad de discos devuelve al panel de KDE Plasma los testigos
físicos de almacenamiento que ya no incluyen muchos ordenadores modernos.

Cada disco, partición o volumen USB seleccionado dispone de su propio LED: gris
cuando está inactivo, verde durante la lectura, rojo durante la escritura y
naranja cuando ambas actividades se producen al mismo tiempo. Durante una
copia grande, la actividad del origen y del destino se reconoce de un vistazo,
sin necesidad de abrir una aplicación de supervisión.

Al pasar el puntero sobre un LED aparecen la identificación del sistema, el
punto de montaje, el estado actual y las velocidades de lectura y escritura en
tiempo real. La página de configuración permite seleccionar los volúmenes
visibles y asignarles etiquetas de hasta cinco caracteres. Los ajustes de los
volúmenes USB se recuerdan mediante el UUID cuando está disponible, y la
anchura del componente se adapta automáticamente al contenido visible.

El componente lee los contadores de dispositivos de bloques del núcleo Linux.
No examina el contenido de los archivos, no envía telemetría, no modifica el
almacenamiento supervisado y no necesita privilegios de administrador.

Un LED gris no es una señal de extracción segura. Desmonte siempre los medios
extraíbles antes de desconectarlos.
