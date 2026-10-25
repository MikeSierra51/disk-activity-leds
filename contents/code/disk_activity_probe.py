#!/usr/bin/python3
# SPDX-FileCopyrightText: 2026 Mike.Sierra.Nevada
# SPDX-License-Identifier: GPL-3.0-or-later
"""Return physical disks, partitions, and their KDE sensor identifiers.

The probe performs slow identity and hot-plug discovery only. Live activity is
read separately from the Linux kernel block counters, so this helper never
opens a disk device and needs no elevated privileges.
"""

import json
import os
import re
from pathlib import Path


SYS_BLOCK = Path(os.environ.get("DISKLEDS_SYS_BLOCK", "/sys/block"))
MOUNTINFO = Path(os.environ.get("DISKLEDS_MOUNTINFO", "/proc/self/mountinfo"))
UUID_DIRECTORY = Path(os.environ.get("DISKLEDS_UUID_DIRECTORY", "/dev/disk/by-uuid"))

PHYSICAL_NAME = re.compile(r"^(?:sd[a-z]+|nvme\d+n\d+|mmcblk\d+)$")


def read_text(path, default=""):
    try:
        return Path(path).read_text(encoding="utf-8", errors="replace").strip()
    except (OSError, ValueError):
        return default


def read_int(path, default=0):
    try:
        return int(read_text(path))
    except (TypeError, ValueError):
        return default


def decode_mount_path(value):
    """Decode the octal escaping used by /proc/*/mountinfo."""
    return re.sub(
        r"\\([0-7]{3})",
        lambda match: chr(int(match.group(1), 8)),
        value,
    )


def mounted_by_device_number():
    mounts = {}
    try:
        lines = MOUNTINFO.read_text(encoding="utf-8", errors="replace").splitlines()
    except OSError:
        return mounts

    for line in lines:
        fields = line.split()
        if len(fields) < 5:
            continue
        device_number = fields[2]
        mountpoint = decode_mount_path(fields[4])
        mounts.setdefault(device_number, []).append(mountpoint)
    return mounts


def device_numbers(block_path):
    numbers = set()
    own_number = read_text(block_path / "dev")
    if own_number:
        numbers.add(own_number)
    try:
        children = list(block_path.iterdir())
    except OSError:
        children = []
    for child in children:
        if child.is_dir() and (child / "partition").exists():
            child_number = read_text(child / "dev")
            if child_number:
                numbers.add(child_number)
    return numbers


def uuid_by_device_name():
    """Return filesystem UUIDs indexed by their kernel block-device name."""
    uuids = {}
    try:
        links = list(UUID_DIRECTORY.iterdir())
    except OSError:
        return uuids
    for link in links:
        try:
            device_name = link.resolve().name
        except OSError:
            continue
        # KSystemStats canonicalizes filesystem UUIDs to lowercase, including
        # the normally uppercase UUIDs used by FAT and exFAT volumes.
        uuids.setdefault(device_name, []).append(link.name.lower())
    return uuids


def disk_member_paths(block_path):
    """Whole disk or its real partitions, never virtual descendants."""
    partitions = []
    try:
        children = list(block_path.iterdir())
    except OSError:
        children = []
    for child in children:
        if child.is_dir() and (child / "partition").exists():
            partitions.append(child)
    return sorted(partitions, key=lambda item: item.name) or [block_path]


def device_transport(name, block_path):
    try:
        hardware_path = str((block_path / "device").resolve()).lower()
    except OSError:
        hardware_path = ""
    if "/usb" in hardware_path:
        return "USB"
    if name.startswith("nvme"):
        return "NVMe"
    if name.startswith("mmcblk"):
        return "MMC"
    return "SATA"


def human_capacity(byte_count):
    if byte_count >= 10**12:
        value = byte_count / 10**12
        return ("%.1f" % value).rstrip("0").rstrip(".") + " To"
    if byte_count >= 10**9:
        value = byte_count / 10**9
        return ("%.0f" % value) + " Go"
    if byte_count >= 10**6:
        return ("%.0f" % (byte_count / 10**6)) + " Mo"
    return str(byte_count) + " o"


def snapshot():
    mount_map = mounted_by_device_number()
    uuid_map = uuid_by_device_name()
    disks = []
    try:
        candidates = sorted(SYS_BLOCK.iterdir(), key=lambda item: item.name)
    except OSError:
        candidates = []

    for block_path in candidates:
        name = block_path.name
        if not PHYSICAL_NAME.match(name):
            continue

        stat_fields = read_text(block_path / "stat").split()
        if len(stat_fields) < 7:
            continue

        model = read_text(block_path / "device" / "model")
        vendor = read_text(block_path / "device" / "vendor")
        serial = read_text(block_path / "device" / "serial")
        if not serial:
            serial = read_text(block_path / "device" / "wwid")
        identity = " ".join(part for part in (vendor, model) if part).strip()
        if not identity:
            identity = name

        sectors = read_int(block_path / "size")
        byte_count = sectors * 512
        rotational = read_int(block_path / "queue" / "rotational", -1)
        transport = device_transport(name, block_path)
        location = "Externe" if transport == "USB" else "Interne"
        media = "HDD" if rotational == 1 else "SSD" if rotational == 0 else "Disque"
        if transport == "USB":
            short_label = "USB " + human_capacity(byte_count)
        else:
            short_label = media + " " + human_capacity(byte_count)

        mounts = []
        for number in device_numbers(block_path):
            mounts.extend(mount_map.get(number, []))
        mounts = sorted(set(mounts))
        partitions = []
        for member_path in disk_member_paths(block_path):
            member_name = member_path.name
            member_number = read_text(member_path / "dev")
            member_mounts = sorted(set(mount_map.get(member_number, [])))
            member_bytes = read_int(member_path / "size") * 512
            member_sensor_ids = sorted(
                set(
                    "disk/" + filesystem_uuid
                    for filesystem_uuid in uuid_map.get(member_name, [])
                )
            )
            partitions.append(
                {
                    "name": member_name,
                    "path": "/dev/" + member_name,
                    "capacity": human_capacity(member_bytes),
                    "shortLabel": member_name,
                    "mounts": member_mounts,
                    "sensorIds": member_sensor_ids,
                }
            )

        disks.append(
            {
                "name": name,
                "path": "/dev/" + name,
                "model": identity,
                "serial": serial,
                "transport": transport,
                "location": location,
                "media": media,
                "capacity": human_capacity(byte_count),
                "shortLabel": short_label,
                "mounts": mounts,
                "partitions": partitions,
                "reads": int(stat_fields[0]),
                "readSectors": int(stat_fields[2]),
                "writes": int(stat_fields[4]),
                "writeSectors": int(stat_fields[6]),
            }
        )
    return {"version": 1, "disks": disks}


def main():
    print(json.dumps(snapshot(), ensure_ascii=False, separators=(",", ":")))


if __name__ == "__main__":
    main()
