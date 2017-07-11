# Automatic file deployment to a local/server directory with rsync

## Setup 
In the file deploy.sh:
* Set the filter you want to apply to the files you want to synchronise (ex: SRC_FILTER="\*.py" or ="\*")
* Set the source folder (ex: SRC="./")
* Set destination folder (ex: DEST="thomas@192.168.1.1:/home/thomas/python/")

## Usage 
* Execute ./deploy to deploy all the files from SRC to DEST according to the filter
* Execute "./deploy file1 file2 dir1" to deploy only specific files or folders

* Options:
* -h to see help menu
* -m [push|pull|both]
  * push: pushes SRC files to DEST path (default mode)
  * pull: pulls files from DEST path to SRC path
  * both: pushes SRC files to DEST path & then pulls files from DEST path to SRC path
* -d to remove destination files/dirs that no longer exist in the source
