# Embedded Raspberry

Le but de ce projet est de contruire rapidement un système de fichier pour le RaspberryPi à l'aide de __crosstool-ng__. 

## Installation

Téléchargez les souces de __crosstool-ng__, en dehors du répo.

    $ wget http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.17.0.tar.bz2
    $ tar xjf crosstool-ng-1.16.0.tar.bz2
    $ cd crosstool-ng-1.16.0
    $ ./configure --prefix=/usr
    $ make
    # make install

Ensuite il suffit de lancer le script `setup.sh` pour mettre en place le projet. Ce qui reviens seulement à créer quelques répertoires.

## Usage

### Organisation

Le plan de travail de ce projet est construit en plusieurs répertoires:

- _config_

Stockage des fichiers de configuration permettant la compilation des outils nécessaires. _Ex: busybox/linux/ct-ng/..._

- _build_

Chaque compilation doit être faite depuis ce répertoire. Tout y est temporaire, c'est pourquoi il n'est pas présent dans le répo.

- _rootfs_

Contient l'arborescence du système de fichier final.

- _tarballs_

Sert à stocker toutes les archives des sources utilisées pour construire le système de fichier. _Ex: busybox/gcc/eglibc/binutils/..._

- _toolchains_

Contient la ou les chaîne de compilation croisée.

- _images_

Sert à stocker les images disques à installer sur la carte SD du RaspberryPi.

- _mnt_

Point de montage nécessaire à la création d'une image disque.

- _archives_

Archives de sauvegarde du système de fichier.

### Construction de la chaîne de compilation croisée avec ___ct-ng___

Le fichier de configuration de _crosstool-ng_ est stocké dans _config/ct-ng/_. Un grand merci à __Christophe Blaess__ pour son article à ce sujet : http://www.blaess.fr/christophe.

    $ cd build
    $ cp ../config/ct-ng/rpi-eglibc.conf .config 
    $ ct-ng build

Et c'est tout...

Il faut noter que ce processus peut prendre plus d'une heure.

_crosstool-ng_ offre le même système de configuration que le noyau linux.

    $ ct-ng menuconfig

_crosstool-ng_ installe les bibliothèques partagées pour la cible dans le répertoire _toolchains/arm-rpi-linux-gnueabi/arm-rpi-linux-gnueabi/sysroot_. Il suffit donc de copier ce que l'on veut dans _rootfs_.



