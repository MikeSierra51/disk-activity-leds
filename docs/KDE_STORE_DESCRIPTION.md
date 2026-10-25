# KDE Store copy

## Short description

Virtual read and write activity lights for each selected disk, partition, or
USB volume. A drive activity indicator, not another system monitor.

## Description

Disk Activity LEDs brings physical storage activity lights back to the KDE
Plasma panel for computers that no longer provide them.

Each selected disk, partition, or USB volume has its own LED: gray for idle,
green for reading, red for writing, and orange for simultaneous activity.
During a large copy, source and destination activity can be recognized at a
glance without opening a monitoring application.

Hovering over a LED reveals the system identity, mount point, current state,
and live read/write rates. The settings page selects visible volumes and assigns
labels of up to five characters. USB settings are remembered by UUID when
available, and the widget width follows the visible content automatically.

The widget reads Linux kernel block counters. It does not inspect file contents,
send telemetry, modify monitored storage, or require administrator privileges.

An idle LED is not a safe-removal signal. Always unmount removable media before
disconnecting it.

## French short description

Témoins virtuels de lecture et d’écriture pour chaque disque, partition ou
volume USB sélectionné. Un témoin d’activité, pas un autre moniteur système.

## Spanish publication copy

The complete Spanish title, short description, and Store description are in
[`KDE_STORE_DESCRIPTION.es.md`](KDE_STORE_DESCRIPTION.es.md).
