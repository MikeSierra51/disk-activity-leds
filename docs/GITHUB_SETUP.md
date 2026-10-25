# GitHub repository

The public source repository is:

<https://github.com/MikeSierra51/disk-activity-leds>

Issues can be reported at:

<https://github.com/MikeSierra51/disk-activity-leds/issues>

The repository URL and issue tracker are also declared in `metadata.json` so
Plasma and software catalogs can display the appropriate project links.

Release packages are built locally with:

```sh
./scripts/check.sh
./scripts/build-package.sh
```

Do not commit the generated `.plasmoid` candidate to the source repository.
Upload the verified package separately as a release asset or to the KDE Store.
