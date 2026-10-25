# Release checklist

## Completed for the 1.3.0 Plasma 5 candidate

- [x] author set to Mike.Sierra.Nevada;
- [x] GPL-3.0-or-later license text and SPDX identifiers;
- [x] conventional `contents/ui/main.qml` entry point;
- [x] architecture-specific binary removed from the Store package;
- [x] portable sampler output compared with the validated native sampler;
- [x] sampler performance measured;
- [x] unit, QML, XML, JSON, JavaScript, and shell checks pass;
- [x] `.plasmoid` structure accepted by KPackage;
- [x] AppStream metadata generated successfully;
- [x] archive audited: no ELF binary, tests, panel scripts, or private files;
- [x] English, French, and Spanish README files;
- [x] English, French, and Spanish interface translation catalogs;
- [x] KDE Store descriptions in three languages and Plasma 6 port plan.

## Required before public upload

- [x] create the public GitHub source repository;
- [x] add the final repository and issue-tracker URLs to `metadata.json`;
- [x] keep personal contact addresses out of the public metadata;
- [ ] install the portable candidate under a temporary test ID;
- [ ] visually test the configuration dialog and automatic width;
- [ ] verify a real read and synchronized write with the portable sampler;
- [ ] test USB removal and reconnection while Plasma is running;
- [ ] produce privacy-safe screenshots;
- [ ] ask at least one second machine or tester to install the candidate;
- [ ] replace “release candidate” with the final release date in the changelog;
- [ ] rebuild, re-run all checks, and publish the final SHA-256.

## Plasma 6

- [ ] complete every item in `docs/PORTING_PLASMA6.md` before claiming support.
