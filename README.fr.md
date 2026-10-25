# Voyants d’activité des disques

[English](README.md) · [Español](README.es.md)

**Un témoin d’activité, pas un autre moniteur système.**

Voyants d’activité des disques remplace dans le panneau KDE Plasma les témoins
physiques absents de nombreux ordinateurs modernes. Chaque disque, partition
ou volume USB sélectionné possède sa propre petite LED :

- gris : aucune activité ;
- vert : lecture ;
- rouge : écriture ;
- orange : lecture et écriture simultanées.

Lors d’une copie importante d’un disque vers un autre, les voyants permettent
de reconnaître d’un coup d’œil les volumes encore actifs, sans ouvrir de
moniteur ni lire une courbe. Le survol d’une LED affiche l’identification
système, le montage, la capacité, l’état et les débits de lecture et d’écriture.

## Fonctions principales

- un voyant par périphérique bloc ou partition réelle sélectionnée ;
- détection automatique des supports SATA, NVMe, MMC et USB ;
- actualisation des branchements toutes les dix secondes ;
- alias facultatifs de cinq caractères au maximum ;
- mémorisation des supports amovibles par UUID lorsqu’il est disponible ;
- maintien de la couleur pendant quatre secondes pour rendre visibles les
  rafales brèves ;
- largeur du composant adaptée automatiquement aux voyants affichés ;
- lecture directe des compteurs du noyau Linux ;
- aucun privilège administrateur et aucun service permanent.
- interface, métadonnées et documentation en anglais, français et espagnol.

Chaque volume détecté peut être affiché ou masqué dans la configuration. Les
choix déjà enregistrés ont toujours priorité sur les valeurs initiales.

## Prérequis

- Linux avec `/sys/class/block` et `/proc/self/mountinfo` ;
- KDE Plasma 5.27 ;
- Python 3 pour la découverte lente du matériel et des branchements ;
- un shell POSIX `/bin/sh` pour l’échantillonnage léger des compteurs.
- GNU gettext pour construire le paquet distribuable depuis les sources.

Cette branche vise Plasma 5. Le futur port Plasma 6 est décrit dans
[`docs/PORTING_PLASMA6.md`](docs/PORTING_PLASMA6.md).

## Installation

Construire le paquet distribuable :

```sh
./scripts/build-package.sh
```

Installer le fichier produit :

```sh
kpackagetool5 --type Plasma/Applet --install \
  releases/candidates/disk-activity-leds-1.3.0-plasma5.plasmoid
```

Pour une mise à jour, remplacer `--install` par `--upgrade`. Pour désinstaller :

```sh
kpackagetool5 --type Plasma/Applet --remove org.mike.diskactivityleds
```

Le fichier `.plasmoid` peut aussi être choisi depuis l’option graphique
**Installer un composant graphique depuis un fichier local…**.

## Configuration

Ouvrir **Configurer les voyants d’activité des disques…** depuis le menu
contextuel. Cocher les volumes à afficher et saisir, si nécessaire, un alias de
cinq caractères au maximum. Un alias vide conserve le nom du noyau, par exemple
`sda2` ou `nvme0n1p3`.

Le composant demande automatiquement la largeur nécessaire. Les exemples dans
[`extras/panel`](extras/panel) peuvent créer une barre dédiée flexible, mais ils
ne font pas partie du paquet Store et doivent être adaptés à l’écran concerné.

## Fonctionnement

La découverte identifie les disques physiques et leurs partitions depuis
sysfs, associe les points de montage avec `/proc/self/mountinfo` et utilise les
UUID pour retrouver les réglages des supports amovibles. Aucun fichier contenu
sur les volumes n’est ouvert.

L’activité provient des champs 3 et 7 de
`/sys/class/block/PÉRIPHÉRIQUE/stat`. QML transforme ces compteurs cumulés en
débits. Les valeurs inférieures à 1 Kio/s sont considérées comme du bruit de
métadonnées. Une activité détectée maintient sa couleur pendant quatre secondes.

Le paquet public utilise un petit script POSIX portable, sans binaire propre à
une architecture. La source de l’ancien lecteur C reste dans `extras/native`
uniquement pour les comparaisons de performances.

## Supports amovibles

Une LED grise signifie qu’aucune entrée/sortie n’a été observée pendant la
période de maintien. Cela **n’autorise pas** à débrancher directement un support.
Il faut toujours employer **Démonter** ou **Retirer le périphérique en toute
sécurité**, car le système de fichiers peut encore devoir vider ses caches.

## Vérification

Lancer tous les contrôles locaux avec :

```sh
./scripts/check.sh
```

Les contrôles couvrent la découverte matérielle, les UUID, les chemins de
montage, la sécurité du lecteur portable, les grands compteurs, JSON, XML, QML
et JavaScript.

## Vie privée et privilèges

Le composant ne lit que des métadonnées locales du noyau. Il n’envoie aucune
télémétrie, ne lit pas le contenu des fichiers, n’écrit pas sur les volumes
surveillés et ne demande aucun privilège élevé.

## Auteur et licence

Copyright 2026 **Mike.Sierra.Nevada**.

Licence **GPL-3.0-or-later**. Voir
[`LICENSES/GPL-3.0-or-later.txt`](LICENSES/GPL-3.0-or-later.txt).
