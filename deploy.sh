#!/bin/sh

# Script qui copie tout nouveau fichier ou fichier modifié vers le répertoire de destination avec les filtres "files_source" sur le nom des fichiers
# Ce script ne supprime aucun fichier dans le répertoire de destination. Pour supprimer les fichiers en trop, rajouter l'option --delete-after


files_source="*.py"
dir_target="thomas@192.168.1.1:/home/thomas/python"


# Si pas de paramètre, on synchronise tout
if [ $# = "0" ]
then
    rsync -vrlt --exclude='.DS_Store' $files_source $dir_target

# Sinon on synchronise uniquement les fichiers/dossiers spécifiés en paramètres
else
	rsync -vrlt "$@" $dir_target

fi
