# Plasma 6 port plan

The 1.x release line targets Plasma 5.27. Do not claim Plasma 6 compatibility
until the following work is implemented and tested on an actual Plasma 6
session.

## Required changes

1. Keep the conventional `contents/ui/main.qml` entry point.
2. Remove `X-Plasma-API` from `metadata.json`.
3. Add `"X-Plasma-API-Minimum-Version": "6.0"`.
4. Remove version numbers from QML imports where required by Qt 6.
5. Replace Plasma 5 `PlasmaCore.DataSource` usage with the supported Plasma 6
   compatibility or sensor API.
6. Revalidate tooltips, configuration bindings, sizing, and executable-source
   result keys.
7. Test installation, upgrade, removal, hot-plug, aliases, and activity colors.
8. Test a real read and a synchronized write on ext4 and removable exFAT media.
9. Measure sampler and plasmashell CPU use.
10. Publish a separate Plasma 6 package and compatibility declaration.

## Release policy

- Plasma 5 packages use the 1.x version line.
- Plasma 6 packages will use the 2.x version line.
- The two packages must not be presented as interchangeable before testing.

