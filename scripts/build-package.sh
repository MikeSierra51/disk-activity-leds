#!/bin/sh
# SPDX-FileCopyrightText: 2026 Mike.Sierra.Nevada
# SPDX-License-Identifier: GPL-3.0-or-later

set -eu

diskleds_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
diskleds_version=$(python3 -c \
    'import json,sys; print(json.load(open(sys.argv[1]))["KPlugin"]["Version"])' \
    "$diskleds_root/metadata.json")
diskleds_output_directory="$diskleds_root/releases/candidates"
diskleds_output="$diskleds_output_directory/disk-activity-leds-$diskleds_version-plasma5.plasmoid"
diskleds_staging=$(mktemp -d "${TMPDIR:-/tmp}/disk-activity-leds.XXXXXX")

cleanup() {
    rm -rf "$diskleds_staging"
}
trap cleanup EXIT HUP INT TERM

mkdir -p "$diskleds_output_directory" "$diskleds_staging/package"
cp -R "$diskleds_root/contents" "$diskleds_staging/package/contents"
cp "$diskleds_root/metadata.json" "$diskleds_staging/package/metadata.json"

for diskleds_po in "$diskleds_root"/translate/*.po; do
    diskleds_locale=$(basename "$diskleds_po" .po)
    diskleds_locale_directory="$diskleds_staging/package/contents/locale/$diskleds_locale/LC_MESSAGES"
    mkdir -p "$diskleds_locale_directory"
    msgfmt --check --check-format \
        -o "$diskleds_locale_directory/plasma_applet_org.mike.diskactivityleds.mo" \
        "$diskleds_po"
done

find "$diskleds_staging/package" -type d -name __pycache__ -prune -exec rm -rf {} +
find "$diskleds_staging/package" -type f -name '*.pyc' -delete

rm -f "$diskleds_output" "$diskleds_output.sha256"
(
    cd "$diskleds_staging/package"
    python3 -m zipfile -c "$diskleds_output" metadata.json contents
)

python3 -m zipfile -t "$diskleds_output" >/dev/null
sha256sum "$diskleds_output" > "$diskleds_output.sha256"

printf '%s\n' "$diskleds_output"
cat "$diskleds_output.sha256"
