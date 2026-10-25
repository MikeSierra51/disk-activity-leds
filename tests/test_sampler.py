#!/usr/bin/python3
# SPDX-FileCopyrightText: 2026 Mike.Sierra.Nevada
# SPDX-License-Identifier: GPL-3.0-or-later

import os
import subprocess
import tempfile
import unittest
from pathlib import Path


SAMPLER = Path(__file__).parents[1] / "contents" / "code" / "disk_activity_sample.sh"


class SamplerTests(unittest.TestCase):
    def run_sampler(self, root, *device_names):
        environment = os.environ.copy()
        environment["DISKLEDS_SYS_CLASS_BLOCK"] = str(root)
        return subprocess.run(
            ["/bin/sh", str(SAMPLER), *device_names],
            check=True,
            universal_newlines=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=environment,
        ).stdout

    def test_reports_read_and_write_sector_fields(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            device = root / "sda2"
            device.mkdir()
            (device / "stat").write_text(
                "10 2 345 4 20 3 678 5 0 9 10 0 0 0 0 0 0\n",
                encoding="ascii",
            )
            self.assertEqual(self.run_sampler(root, "sda2"), "sda2 345 678\n")

    def test_rejects_unsafe_names_and_skips_missing_devices(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            self.assertEqual(
                self.run_sampler(root, "../sda", "sda/1", "missing"),
                "",
            )

    def test_supports_large_kernel_counters_without_arithmetic(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            device = root / "nvme0n1p2"
            device.mkdir()
            (device / "stat").write_text(
                "1 0 1844674407370955161 0 1 0 9223372036854775807 0 0 0 0\n",
                encoding="ascii",
            )
            self.assertEqual(
                self.run_sampler(root, "nvme0n1p2"),
                "nvme0n1p2 1844674407370955161 9223372036854775807\n",
            )


if __name__ == "__main__":
    unittest.main()
