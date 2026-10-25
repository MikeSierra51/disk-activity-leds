#!/usr/bin/python3
# SPDX-FileCopyrightText: 2026 Mike.Sierra.Nevada
# SPDX-License-Identifier: GPL-3.0-or-later

import importlib.util
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


PROBE = Path(__file__).parents[1] / "contents" / "code" / "disk_activity_probe.py"


class ProbeTests(unittest.TestCase):
    def test_live_output_is_valid_and_contains_only_whole_physical_disks(self):
        result = subprocess.run(
            [sys.executable, str(PROBE)],
            check=True,
            universal_newlines=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        payload = json.loads(result.stdout)
        self.assertEqual(payload["version"], 1)
        for disk in payload["disks"]:
            self.assertRegex(disk["name"], r"^(sd[a-z]+|nvme\d+n\d+|mmcblk\d+)$")
            self.assertNotRegex(disk["name"], r"(loop|sr|dm-|zram)")
            self.assertGreaterEqual(disk["readSectors"], 0)
            self.assertGreaterEqual(disk["writeSectors"], 0)
            self.assertIsInstance(disk["partitions"], list)
            self.assertGreaterEqual(len(disk["partitions"]), 1)
            for partition in disk["partitions"]:
                self.assertIsInstance(partition["sensorIds"], list)

    def test_mountinfo_escape_decoder(self):
        spec = importlib.util.spec_from_file_location("disk_activity_probe", PROBE)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        self.assertEqual(module.decode_mount_path("/media/Mon\\040disque"), "/media/Mon disque")

    def test_uuid_sensor_ids_are_normalized_for_kde(self):
        spec = importlib.util.spec_from_file_location("disk_activity_probe", PROBE)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary_root = Path(temporary_directory)
            uuid_directory = temporary_root / "by-uuid"
            uuid_directory.mkdir()
            device = temporary_root / "sdd"
            device.touch()
            (uuid_directory / "76E8-CACF").symlink_to(device)
            module.UUID_DIRECTORY = uuid_directory
            self.assertEqual(module.uuid_by_device_name(), {"sdd": ["76e8-cacf"]})


if __name__ == "__main__":
    unittest.main()
