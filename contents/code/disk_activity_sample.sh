#!/bin/sh
# SPDX-FileCopyrightText: 2026 Mike.Sierra.Nevada
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Print kernel read/write sector counters for explicitly named block devices.
# Only POSIX shell built-ins are used inside the sampling loop so the helper is
# portable across CPU architectures and inexpensive enough for panel polling.

diskleds_sys_class_block=${DISKLEDS_SYS_CLASS_BLOCK:-/sys/class/block}

for diskleds_name do
    case "$diskleds_name" in
        ""|*[!A-Za-z0-9_-]*) continue ;;
    esac

    diskleds_stat="$diskleds_sys_class_block/$diskleds_name/stat"
    [ -r "$diskleds_stat" ] || continue

    # Linux block statistics fields 3 and 7 are sectors read and written.
    # The final variable intentionally consumes every remaining field.
    IFS=' ' read -r diskleds_reads diskleds_reads_merged diskleds_read_sectors \
        diskleds_read_ms diskleds_writes diskleds_writes_merged \
        diskleds_write_sectors diskleds_rest < "$diskleds_stat" || continue

    case "$diskleds_read_sectors" in
        ""|*[!0-9]*) continue ;;
    esac
    case "$diskleds_write_sectors" in
        ""|*[!0-9]*) continue ;;
    esac

    printf '%s %s %s\n' \
        "$diskleds_name" "$diskleds_read_sectors" "$diskleds_write_sectors"
done
