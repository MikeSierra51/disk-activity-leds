# Disk Activity LEDs

[Français](README.fr.md) · [Español](README.es.md)

**A drive activity indicator, not another system monitor.**

Disk Activity LEDs brings physical storage activity lights back to the KDE
Plasma panel for computers that no longer provide them. Each selected disk,
partition, or USB volume has a compact LED:

- gray: idle;
- green: reading;
- red: writing;
- orange: reading and writing at the same time.

During a large copy from one drive to another, the LEDs show at a glance which
volumes are still active. There is no graph or dashboard to keep open. Hovering
over an LED reveals the system identity, mount point, capacity, current state,
and live read/write rates when more detail is useful.

## Features

- one LED per selected block device or real partition;
- automatic discovery of SATA, NVMe, MMC, and USB storage;
- hot-plug refresh every ten seconds;
- optional labels of up to five characters;
- removable-volume settings remembered by filesystem UUID when available;
- four-second activity hold so short cached bursts remain visible;
- automatic widget width based on the visible LEDs and labels;
- direct Linux kernel counters instead of disk-content access;
- no administrator privileges and no background daemon;
- English, French, and Spanish interface, metadata, and documentation.

Every detected volume can be enabled or disabled in the widget settings.
Existing choices always take precedence over the initial defaults.

## Requirements

- Linux with `/sys/class/block` and `/proc/self/mountinfo`;
- KDE Plasma 5.27;
- Python 3 for slow hardware and hot-plug discovery;
- a POSIX `/bin/sh` for the lightweight live counter sampler.
- GNU gettext when building the distributable package from source.

The current release line is for Plasma 5. A Plasma 6 port is planned and is
tracked in [`docs/PORTING_PLASMA6.md`](docs/PORTING_PLASMA6.md).

## Install

Build the distributable package:

```sh
./scripts/build-package.sh
```

Install the generated file:

```sh
kpackagetool5 --type Plasma/Applet --install \
  releases/candidates/disk-activity-leds-1.3.0-plasma5.plasmoid
```

For an update, replace `--install` with `--upgrade`. To remove the widget:

```sh
kpackagetool5 --type Plasma/Applet --remove org.mike.diskactivityleds
```

The package can also be installed from Plasma's graphical widget installer by
choosing **Install Widget From Local File…**.

## Configure

Open **Configure Disk Activity LEDs…** from the widget context menu. Select the
volumes to show and optionally enter a label of no more than five characters.
An empty label uses the kernel device name, such as `sda2` or `nvme0n1p3`.

The widget itself requests exactly the width required by its visible LEDs. A
dedicated content-sized panel can optionally be created with the example Plasma
scripts in [`extras/panel`](extras/panel). Those scripts are not included in the
Store package and should be reviewed and adapted to the user's screen first.

## How it works

The discovery helper identifies physical disks and their real partitions from
Linux sysfs, correlates mount points through `/proc/self/mountinfo`, and uses
filesystem UUIDs for stable removable-volume settings. It never opens files on
the monitored volumes.

The live sampler reads fields 3 and 7 from each selected device's
`/sys/class/block/DEVICE/stat`. These cumulative sector counters are converted
to rates by QML. Values below 1 KiB/s are treated as metadata noise. A detected
read or write remains lit for four seconds, making short cache flushes visible.

The Store package contains a portable POSIX shell sampler, not an
architecture-specific native binary. The original experimental C sampler is
retained only as source under [`extras/native`](extras/native) for benchmarking.

## Important removable-media note

An idle gray LED means that no block I/O was observed during the hold period.
It is **not** permission to unplug removable storage. Always use Plasma's
**Safely Remove** or **Unmount** action before disconnecting a USB device,
because filesystem caches may still need to be flushed.

## Development and verification

Run all local checks with:

```sh
./scripts/check.sh
```

The suite validates hardware discovery, UUID normalization, mount-path
decoding, sampler safety, large counters, JSON/XML syntax, QML, and JavaScript.

## Privacy and privileges

The widget reads local kernel metadata only. It does not send telemetry, access
file contents, write to monitored storage, or request elevated privileges.

## Author and license

Copyright 2026 **Mike.Sierra.Nevada**.

Licensed under **GPL-3.0-or-later**. See
[`LICENSES/GPL-3.0-or-later.txt`](LICENSES/GPL-3.0-or-later.txt).
