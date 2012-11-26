# Embedded Raspberry

Le but de ce projet est de contruire rapidement une chaine de compilation croisée pour le RaspberryPi à l'aide de __crosstool-ng__. 

Une chaine de compilation contient un compilateur, éditeur de liens et tout ce qu'il faut ainsi qu'une libc, en l'occurence la __eglibc__.

## Téléchargement du repo

    $ git clone git@82.235.99.234:embedded_raspberry.git

## Installation

Il faut tout d'abord installer __crosstool-ng__.

Ensuite il suffit de lancer le script `setup.sh`.