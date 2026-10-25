# Contributing

Contributions, hardware test reports, translations, and accessibility feedback
are welcome.

## Before opening a change

- keep the widget focused on storage activity indicators rather than turning it
  into a general system monitor;
- do not read file contents or require elevated privileges;
- preserve the meaning of the four LED colors;
- keep labels and tooltips usable in a 26 px horizontal panel;
- keep English source strings and update `translate/template.pot`, `fr.po`, and
  `es.po` whenever visible interface text changes;
- avoid architecture-specific binaries in the Store package;
- retain the safe-removal warning for removable media.

## Verification

Run:

```sh
./scripts/check.sh
./scripts/build-package.sh
```

For changes to activity detection, also test a real read and a synchronized
write, then confirm the LED returns to idle. State the filesystem, transport,
Plasma version, and kernel version in the test report.

## Compatibility

Changes for Plasma 5 and Plasma 6 should remain in distinct release lines until
both implementations have been tested. See `docs/PORTING_PLASMA6.md`.

By submitting a contribution, you agree to license it under
GPL-3.0-or-later, the license of this project.
