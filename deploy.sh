#!/bin/bash

##########################################################################
###############            Script de deploiement           ###############
##########################################################################
#  Par défaut, déploie le répertoire source vers le répertoire cible sauf les fichiers cachés (.*)
#       3 types de synchronisation : 
#         - Restriction aux fichiers/dossiers saisis dans $FORCE_SRC_FILES
#         - Restriction aux fichiers matchant le filtre saisi dans $SRC_FILTER
#         - Restriction aux fichiers/dossiers saisis en argument du script, ex: ./deploy.sh file1 dir1
#       Ce script ne préserve pas les droits, ni les groupes/propriétaires
#
#  Options :
#    -h affiche l'aide
#    -n mode dry-run, montre ce qui aurait été transféré 
#    -m push: mode par défaut (synchronisation src -> dest)
#       pull: synchronisation inverse (dest -> src)
#       both: synchronisation 'push' puis 'pull'
#    -d efface les fichiers dans le répertoire cible qui n'existent pas dans le répertoire de référence (après transfert). Non compatible avec l'option '-m both'
##########################################################################
 

####################################
#########    Paramètres    #########
####################################

# 1 des 2 paramètres suivants doit être renseigné (non vide)
FORCE_SRC_FILES="" # Restreint la synchronisation à la liste de ces fichiers/dossiers uniquement (sans prise en compte de $SRC_FILTER)
SRC_FILTER="*.py" # Filtre sur les fichiers/dossiers à synchroniser (Mettre * si pas de filtre). Inactif si $FORCE_SRC_FILES est renseigné

SRC="./"         # Répertoire source (avec / à la fin)
DEST="thomas@192.168.1.1:/home/thomas/python/"  # Répertoire cible (avec / à la fin)

SYNC="push"  # Mode de synchronisation par défaut (push, pull ou both)
DELETE=""    # Comportement par défaut : ne rien supprimer du côté destination

####################################


# Lecture des arguments du script
while getopts "hm:dn" option
do
    case $option in
        h)
            echo -e "\nUsage: ./deploy.sh [-h] [-n] [-m push|pull|both] [-d] [file1 file2 dir1]\n"
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
        n)
            DRY_RUN="--dry-run" # Mode dry-run, montre ce qui aurait été transféré 
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



# On identifie le type de synchronisation selon les paramètres/arguments :
#   en priorité les arguments, puis le paramètre $FORCE_SRC_FILES puis le paramètre $SRC_FILTER
if [ -n "$*" ]; then
    SRC_FILES="$*"
elif [ -n "$FORCE_SRC_FILES" ]; then
    SRC_FILES="$FORCE_SRC_FILES"
fi


# Affichage des paramètres
echo -e "\n--- PARAMETERS --- "
if [ -n "$DRY_RUN" ]; then
    echo "!! DRY RUN !!" 
fi
if [ -n "$SRC_FILES" ]; then
    echo "SRC_FILES = $SRC_FILES" 
else
    echo "SRC_FILTER = $SRC_FILTER"
fi
echo "DEST = $DEST"
echo -e "SYNC = $SYNC\n------------------\n"



# Si pas de $SRC_FILES (via argument ou paramètre), on synchronise tout le répertoire avec le filtre
if [ -z "$SRC_FILES" ]; then

    if [ "$SYNC" == "push" ] || [ "$SYNC" == "both" ]; then
        echo -e "rsync -vhrlt $DRY_RUN --prune-empty-dirs --exclude='.*' --include='*/' --include=$SRC_FILTER --exclude='*' $DELETE $SRC $DEST\n\n------------------\n"
        rsync -vhrlt $DRY_RUN --prune-empty-dirs --exclude='.*' --include='*/' --include=$SRC_FILTER --exclude='*' $DELETE $SRC $DEST
    fi

    if [ "$SYNC" == "pull" ] || [ "$SYNC" == "both" ]; then
        echo -e "rsync -vhrlt $DRY_RUN --prune-empty-dirs --exclude='.*' --include='*/' --include=$SRC_FILTER --exclude='*' $DELETE $DEST $SRC\n\n------------------\n"
        rsync -vhrlt $DRY_RUN --prune-empty-dirs --exclude='.*' --include='*/' --include=$SRC_FILTER --exclude='*' $DELETE $DEST $SRC
    fi


# Sinon on synchronise uniquement le(s) fichier(s) et/ou dossier(s) spécifié(s) (sans prise en compte du filtre)
else

    FULLPATH_FILES=""

    if [ "$SYNC" == "push" ] || [ "$SYNC" == "both" ]; then

        for FILE_I in $SRC_FILES; do
            FULLPATH_FILES+="${SRC}${FILE_I} " # Génération de la liste des répertoires sources complets (SRC + sous-répertoire)
        done
        echo -e "rsync -vhrlt $DRY_RUN --prune-empty-dirs --exclude='.*' $DELETE $FULLPATH_FILES $DEST\n\n------------------\n"
        rsync -vhrlt $DRY_RUN --prune-empty-dirs --exclude='.*' $DELETE $FULLPATH_FILES $DEST
    fi

    if [ "$SYNC" == "pull" ] || [ "$SYNC" == "both" ]; then

        for FILE_I in $SRC_FILES; do
            FULLPATH_FILES+="${DEST}${FILE_I} " # Génération de la liste des répertoires sources complets (DEST + sous-répertoire)
            shift
        done
        echo -e "rsync -vhrlt $DRY_RUN --prune-empty-dirs --exclude='.*' $DELETE $FULLPATH_FILES $SRC\n\n------------------\n"
        rsync -vhrlt $DRY_RUN --prune-empty-dirs --exclude='.*' $DELETE $FULLPATH_FILES $SRC
    fi

fi
