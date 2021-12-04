Building a github configuration for the building and maintenance of a MediaWiki site.

dockerfile is the build of the MediaWiki docker image.  See the file for the details.
  MediaWiki 1.35.3  -->  Hold at this version until Semantic MediaWiki is ready.  Might use this in the future
  Additional plugins are baked into the dockerfile for future ease of deployment. Otherwise, docker-compose down will lose some of the extension configuration.


Intention is to backup required files by building them on github, then do a git clone down to the required machine.  Clone them down to a folder structure, and create SYMLINK to them if required.

Master files located in in mwgit:
  LocalSettings.php  --> Directly mapped within the docker-compose.yml
  php.ini            --> Symlink to the extracted php folder
  docker-compose.yml --> Symlink to root of the docker folder
  
  Using Arch Linux, the command is "ln"
