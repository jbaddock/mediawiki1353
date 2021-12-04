Intention is to backup required files.  Clone them down to a folder structure, and create SYMLINK to them if required.

Master files located in in mwgit:
  LocalSettings.php  --> Directly mapped within the docker-compose.yml
  php.ini            --> Symlink to the extracted php folder
  docker-compose.yml --> Symlink to root of the docker folder
