# Automatic file deployment to a local/server directory with rsync

## Setup 
In the file deploy.sh:
* Set the source folder (ex: SRC="./")
* Set destination folder (ex: DEST="thomas@192.168.1.1:/home/thomas/python/")
* Set either (only one can be applied):
  * the list of specific files/dirs you want to synchronise (ex: FORCE_SRC_FILES="file.txt img")
  * the filter to select the files you want to include in the synchronisation (ex: SRC_FILTER="\*.py" or ="\*")


## Usage 
* Execute "./deploy.sh" to deploy all the files from SRC to DEST (according to the set up parameters)
* Execute "./deploy.sh file1 file2 dir1" to deploy only specific files or folders

* Options:
  * -h to see help menu
  * -n, dry-run: perform a trial run with no changes made
  * -m [push|pull|both]
    * push: pushes SRC files to DEST path (default mode)
    * pull: pulls files from DEST path to SRC path
    * both: pushes SRC files to DEST path & then pulls files from DEST path to SRC path
  * -d to remove destination files/dirs that no longer exist in the source
