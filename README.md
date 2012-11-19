# Embedded Raspberry

Le but de ce projet est de contruire rapidement une chaine de compilation croisée pour le RaspberryPi à l'aide de __crosstool-ng__. 

Une chaine de compilation contient un compilateur, éditeur de liens et tout ce qu'il faut ainsi qu'une libc, en l'occurence la __eglibc__.

## Téléchargement du repo

Il faut __absolument__ mettre en place le repo dans son dossier perso.

    # cd ~
    # git clone --recursive git@82.235.99.234:embedded_raspberry.git

Il faut mettre l'option `--recursive` pour automatiquement télécharger crosstool-ng. Ça revient à faire:

    # git clone --recursive git@82.235.99.234:embedded_raspberry.git
    # git submodule init
    # git submodule update

## Installation

Ensuite il suffit de lancer le script `setup.sh` pour installer crosstool-ng.

Et enfin le script `build.sh` construit toute la chaine de compilation croisée automatiquement!

Il donne en premier un _menuconfig_ comme pour le noyau, il suffit de quitter pour lancer la compilation de la châine.

En fois que tout est fini, ça peut prendre des heures, la chaine se situe dans __toolchains__ et dedans on y trouve un dossier __sysroot__ avec le système de fichier à mettre dans le raspberrypi.

## Crosstool-ng
Si on veu bidouiller la configuration de la chaine:

Crosstool-ng sera installé dans le dossier __install__, il faut donc l'ajouter à la variables __PATH__:

    # export PATH=$PATH:$HOME/embedded_raspberry/install/bin

Ensuite la commande __ct-ng__ sera dispo. Pour l'utiliser il vaut mieux se placer dans un dossier à part, en l'occurence le dossier __build__. La configuration de la chaine se trouve dans le dossier __config__, il faut la copier dans le dossier __build__.

Ensuite:

    # ct-ng menuconfig

Pour éditer la config

    # ct-ng build

Pour construire la chaine.
