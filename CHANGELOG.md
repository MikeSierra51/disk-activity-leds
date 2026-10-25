# Changelog

All notable changes to this project will be documented in this file.

## 1.3.0 - release candidate

- add complete English, French, and Spanish interface translations, localized
  metadata, and Spanish documentation;
- add per-volume visibility and labels of up to five characters;
- remember removable volumes by filesystem UUID when available;
- detect internal partitions and USB volumes dynamically;
- distinguish idle, read, write, and simultaneous activity;
- hold brief activity pulses for four seconds;
- display live rates and system identification on hover;
- make the widget and optional dedicated panel content-sized;
- replace the x86-64 native sampler with a portable POSIX shell sampler;
- add sampler safety tests, packaging checks, public documentation, and license
  metadata.

## 1.2.4 - local validated build

- validate direct Linux block-counter sampling for exFAT USB writes;
- work around incomplete Plasma 5 KSystemStats write readings;
- retain the original native C sampler for the local x86-64 installation.
