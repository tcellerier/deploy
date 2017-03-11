#!/bin/sh

# Script qui copie tout nouveau fichier ou fichier modifié vers le répertoire de destination avec soit :
#   - les filtres "files_source" sur le nom des fichiers de ./ (ex: ./deploy)
#   - uniquement les fichiers/dossiers de ./ passés en arguments (ex: ./deploy file1 dir2)

# Ce script ne supprime aucun fichier dans le répertoire de destination. Pour supprimer les fichiers en trop, rajouter l'option --delete-during


#########    Paramètres    #########

# Filtre sur les fichiers/dossiers à synchroniser dans le répertoire ./ du script
files_source="*py"

# Répertoire cible de la synchro (pas de / à la fin)
dir_target="thomas@192.168.1.1:/home/thomas/python"

####################################



# Si pas d'argument à l'exécution du script, on synchronise tout ./ sur la base du filtre files_source
if [ $# = "0" ]
then
    rsync -vrlth --exclude='.DS_Store' $files_source $dir_target

# Sinon on synchronise uniquement les fichiers/dossiers spécifiés en arguments du script
else
	rsync -vrlth --exclude='.DS_Store' "$@" $dir_target

fi
