#!/bin/sh
# SPDX-FileCopyrightText: 2026 Mike.Sierra.Nevada
# SPDX-License-Identifier: GPL-3.0-or-later

set -eu

diskleds_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
diskleds_extracted_messages=$(mktemp "${TMPDIR:-/tmp}/disk-activity-leds-messages.XXXXXX")

cleanup() {
    rm -f "$diskleds_extracted_messages"
}
trap cleanup EXIT HUP INT TERM

python3 -m unittest discover -s "$diskleds_root/tests" -v
python3 -m json.tool "$diskleds_root/metadata.json" >/dev/null
xmllint --noout "$diskleds_root/contents/config/main.xml"
qmllint \
    "$diskleds_root/contents/ui/main.qml" \
    "$diskleds_root/contents/ui/configGeneral.qml" \
    "$diskleds_root/contents/config/config.qml"
node --check "$diskleds_root/extras/panel/create-dedicated-panel.js"
node --check "$diskleds_root/extras/panel/remove-dedicated-panel.js"
sh -n "$diskleds_root/contents/code/disk_activity_sample.sh"

for diskleds_po in "$diskleds_root"/translate/*.po; do
    msgfmt --check --check-format -o /dev/null "$diskleds_po"
    msgcmp --no-fuzzy-matching "$diskleds_po" "$diskleds_root/translate/template.pot"
done

xgettext \
    --language=JavaScript \
    --from-code=UTF-8 \
    --width=120 \
    --add-location=file \
    -ki18n:1 \
    -ki18np:1,2 \
    -o "$diskleds_extracted_messages" \
    "$diskleds_root/contents/ui/main.qml" \
    "$diskleds_root/contents/ui/configGeneral.qml" \
    "$diskleds_root/contents/config/config.qml"
msgcmp --use-untranslated "$diskleds_root/translate/template.pot" "$diskleds_extracted_messages"
msgcmp --use-untranslated "$diskleds_extracted_messages" "$diskleds_root/translate/template.pot"

if command -v shellcheck >/dev/null 2>&1; then
    shellcheck \
        "$diskleds_root/contents/code/disk_activity_sample.sh" \
        "$diskleds_root/scripts/check.sh" \
        "$diskleds_root/scripts/build-package.sh"
fi

printf '%s\n' "All checks passed."
