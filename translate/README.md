# Translations

The source language is English. The package currently ships complete French
(`fr.po`) and Spanish (`es.po`) translations.

The translation domain is:

```text
plasma_applet_org.mike.diskactivityleds
```

`scripts/build-package.sh` compiles every `translate/*.po` catalog into the
matching `contents/locale/LANGUAGE/LC_MESSAGES` directory of the distributable
package. Generated `.mo` files are deliberately not stored in the source tree.

When a visible `i18n()` or `i18np()` string changes, update `template.pot` and
merge the change into every `.po` catalog. Run `scripts/check.sh` before
building a release.
