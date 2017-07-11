#!/bin/bash

##########################################################################
###############            Script de deploiement           ###############
##########################################################################
#  Par défaut, déploie tout le répertoire source avec son filtre vers le répertoire cible sauf les fichiers cachés (.*)
#              Possibilité de restreindre la synchronisation aux fichiers/dossiers en argument uniquement (sans prise en compte du filtre), ex: ./deploy.sh file1 dir1
#              Ce script ne préserve pas les droits, ni les groupes/propriétaires
#
#  Options :
#    -h affiche l'aide
#    -m push: mode par défaut (synchronisation src -> dest)
#       pull: synchronisation inverse (dest -> src)
#       both: synchronisation 'push' puis 'pull'
#    -d efface les fichiers dans le répertoire cible qui n'existent pas dans le répertoire de référence (après transfert). Non compatible avec l'option '-m both'
##########################################################################
 

####################################
#########    Paramètres    #########
####################################

SRC_FILTER="*.py" # Filtre sur les fichiers/dossiers à synchroniser (Mettre * si pas de filtre)

SRC="./"         # Répertoire source (avec / à la fin)
DEST="thomas@192.168.1.1:/home/thomas/python/"  # Répertoire cible (avec / à la fin)

SYNC="push"  # Mode de synchronisation par défaut (push, pull ou both)
DELETE=""    # Comportement par défaut : ne rien supprimer du côté destination

####################################


# Lecture des arguments du script
while getopts "hm:d" option
do
    case $option in
        h)
            echo -e "\nUsage: ./deploy.sh [-h] [-m push|pull|both] [-d] [file1 file2 dir1]\n"
            exit 0
            ;;
        m)
            if [ "$OPTARG" == "push" ] || [ "$OPTARG" == "pull" ] || [ "$OPTARG" == "both" ]; then
                SYNC="$OPTARG"
            else
                echo -e "\nOption -m error"
                echo "Parameter usage: '-m push' pushes SRC files to DEST path (default mode)"
                echo "                 '-m pull' pulls files from DEST path to SRC path"
                echo -e "                 '-m both' pushes SRC files to DEST path & then pulls files from DEST path to SRC path\n"
                exit 1 
            fi
            ;;
        d)
            DELETE="--delete-after" # Efface les fichiers dans le répertoire cible qui n'existent pas dans le repertoire source (après transfert)
            echo -e "\nWarning : the script will remove destination files/dirs that no longer exist in the source"
            echo  "Press Return to continue or Ctrl-c to quit ..."
            read -s
            echo ""
            ;;
        \?)
            echo -e "\nInvalid option(s), -h to see help menu\n"
            exit 1 
            ;;
    esac
done
shift $((OPTIND-1))


# Si synchronisation dans les 2 sens, désactivation de l'option de suppression des fichiers
if [ "$SYNC" == "both" ] && [ "$DELETE" != "" ]; then
    DELETE=""
    echo -e "\n  '-d' cannot be used when option '-m both' is activated\n"
fi



# Si pas d'argument, on synchronise tout le répertoire (en prenant en compte le filtre)
if [ $# = "0" ]; then

    echo -e "\n --- PARAMETERS --- "
    echo "  SRC = $SRC"
    echo "  SRC_FILTER = $SRC_FILTER"
    echo "  DEST = $DEST"
    echo -e "  SYNC = $SYNC\n ------------------\n"

    if [ "$SYNC" == "push" ] || [ "$SYNC" == "both" ]; then
        echo -e " rsync -vhrlt --prune-empty-dirs --exclude='.*' --include='*/' --include=$SRC_FILTER --exclude='*' $DELETE $SRC $DEST\n"
        rsync -vhrlt --prune-empty-dirs --exclude='.*' --include='*/' --include=$SRC_FILTER --exclude='*' $DELETE $SRC $DEST
    fi

    if [ "$SYNC" == "pull" ] || [ "$SYNC" == "both" ]; then
        echo -e " rsync -vhrlt --prune-empty-dirs --exclude='.*' --include='*/' --include=$SRC_FILTER --exclude='*' $DELETE $DEST $SRC\n"
        rsync -vhrlt --prune-empty-dirs --exclude='.*' --include='*/' --include=$SRC_FILTER --exclude='*' $DELETE $DEST $SRC
    fi


# Sinon on synchronise uniquement le(s) fichier(s) et/ou dossier(s) spécifié(s) en argument du script (sans prise en compte du filtre)
else

    LIST_FILES=""

    echo -e "\n --- PARAMETERS --- "
    echo "  SRC = $SRC"
    echo "  SRC_FILES = $@"
    echo "  DEST = $DEST"
    echo -e "  SYNC = $SYNC\n ------------------\n"

    if [ "$SYNC" == "push" ] || [ "$SYNC" == "both" ]; then

        while [ "$1" ]; do
            LIST_FILES+="${SRC}${1} " # Génération de la liste des répertoires sources complets (SRC + sous-répertoire)
            shift
        done
        echo -e " rsync -vhrlt --prune-empty-dirs --exclude='.*' $DELETE $LIST_FILES $DEST\n"
        rsync -vhrlt --prune-empty-dirs --exclude='.*' $DELETE $LIST_FILES $DEST
    fi

    if [ "$SYNC" == "pull" ] || [ "$SYNC" == "both" ]; then

        while [ "$1" ]; do
            LIST_FILES+="${DEST}${1} " # Génération de la liste des répertoires sources complets (DEST + sous-répertoire)
            shift
        done
        echo -e " rsync -vhrlt --prune-empty-dirs --exclude='.*' $DELETE $LIST_FILES $SRC\n"
        rsync -vhrlt --prune-empty-dirs --exclude='.*' $DELETE $LIST_FILES $SRC
    fi

fi
