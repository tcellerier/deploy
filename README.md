# deploy files to directory/server

## Setup 
In the deploy file:
* Set files filter to include in the deployment (ex: files_source="*.py")
* Set destination folder to deploy (ex: dir_target="thomas@192.168.1.1:/home/python")

## Usage 
* Execute ./deploy to deploy all files in ./ with the filter set up
* Execute ./deploy file1 file2 dir1 to deploy only specific files/folders
