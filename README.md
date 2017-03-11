# deploy files to directory/server

## Setup 
In the file deploy:
* Set files filter you want to include in the deployment (ex: files_source="*.py")
* Set destination folder for the deployment (ex: dir_target="thomas@192.168.1.1:/home/python")

## Usage 
* Execute ./deploy to deploy all the files from ./ with the set up filter
* Execute "./deploy file1 file2 dir1" to deploy only specific files/folders
