From mediawiki:1.35.6

# Many items and examples pulled from
# https://github.com/CanastaWiki/Canasta/blob/master/Dockerfile

ENV MW_VERSION=REL1_35 \
    MW_HOME=/var/www/html


#ENV MW_VERSION=REL1_35 \
#    MW_CORE_VERSION=1.35.6 \
#    WWW_ROOT=/var/www/mediawiki \
#    MW_HOME=/var/www/mediawiki/w \
#    MW_ORIGIN_FILES=/mw_origin_files \
#    MW_VOLUME=/mediawiki \
#    WWW_USER=www-data \
#      WWW_GROUP=www-data \
#      APACHE_LOG_DIR=/var/log/apache2

##############################################################
# System Setup
##############################################################
RUN set x; \
        apt-get clean \
        && apt-get update \
        && apt-get install -y aptitude \
        && aptitude -y upgrade \
        && aptitude install -y \
            git \
            rsync \
            unzip \
            curl \
            wget \
	    cron \
	    nano \
        && aptitude update \
        && aptitude clean


##############################################################
# Extensions
##############################################################
RUN set -x; \
	cd $MW_HOME/extensions \
# AdvancedSearch
	&& git clone --single-branch -b $MW_VERSION https://gerrit.wikimedia.org/r/mediawiki/extensions/AdvancedSearch $MW_HOME/extensions/AdvancedSearch \
	&& cd $MW_HOME/extensions/AdvancedSearch \
	&& git checkout -q 4e8a9f3710c821eb25a08e3d768bd2523bfb0e3b \
# CirrusSearch
	&& git clone --single-branch -b $MW_VERSION https://gerrit.wikimedia.org/r/mediawiki/extensions/CirrusSearch $MW_HOME/extensions/CirrusSearch \
	&& cd $MW_HOME/extensions/CirrusSearch \
	&& git checkout -q dfeff687cc100b2eb10dff411b344b38972131ef \
# Elastica
	&& git clone --single-branch -b $MW_VERSION https://gerrit.wikimedia.org/r/mediawiki/extensions/Elastica $MW_HOME/extensions/Elastica \
	&& cd $MW_HOME/extensions/Elastica \
	&& git checkout -q 91bafe6b11edf763c606bf332a0b8bcc7693b1b5 \
 # HeaderTabs (v. 2.2)
	&& git clone --single-branch -b master https://gerrit.wikimedia.org/r/mediawiki/extensions/HeaderTabs $MW_HOME/extensions/HeaderTabs \
	&& cd $MW_HOME/extensions/HeaderTabs \
	&& git checkout -q 38647067478a59dabf02e5cacbc7488d7812b388 \
 # PageForms (v. 5.3.4)
	&& git clone --single-branch -b master https://gerrit.wikimedia.org/r/mediawiki/extensions/PageForms $MW_HOME/extensions/PageForms \
	&& cd $MW_HOME/extensions/PageForms \
	&& git checkout -q dd09bde68d830f1232b7e92e42ada598f42b5d60 \
 # UserMerge
	&& git clone --single-branch -b $MW_VERSION https://gerrit.wikimedia.org/r/mediawiki/extensions/UserMerge $MW_HOME/extensions/UserMerge \
	&& cd $MW_HOME/extensions/UserMerge \
	&& git checkout -q 184a4380eafef0fb9d21cac956b69a4b35fc6a5f \
 # VoteNY
	&& git clone --single-branch -b $MW_VERSION https://gerrit.wikimedia.org/r/mediawiki/extensions/VoteNY $MW_HOME/extensions/VoteNY \
	&& cd $MW_HOME/extensions/VoteNY \
	&& git checkout -q 2394205bc88eb62b66080026e911d9984617b7ba \



# Update and install prereqs for Mediawiki PDFHandler
# https://www.mediawiki.org/wiki/Extension:PdfHandler
 RUN set x; \
 	aptitude install -y \
 	  ghostscript \
 	  poppler-utils \
    && aptitude update \
    && aptitude clean


#######################################
# Install composer
#######################################
 COPY --from=composer:2.1.10 /usr/bin/composer /usr/local/bin/composer

# Configure Composer
# Issue with composer, so removing the vendor to prevent issues
 WORKDIR /var/www/html
 RUN rm -r vendor
RUN composer update --no-dev
RUN composer update --no-dev

# Anchored SMW to 4.0.1 JRB - 2022-05-01
RUN COMPOSER=composer.local.json composer require --no-update mediawiki/semantic-media-wiki:4.0.1
RUN COMPOSER=composer.local.json composer require --no-update mediawiki/chameleon-skin:~4.0
RUN COMPOSER=composer.local.json composer require --no-update mediawiki/semantic-result-formats:~4.0
RUN COMPOSER=composer.local.json composer require --no-update mediawiki/lingo:~3.0
RUN COMPOSER=composer.local.json composer require --no-update mediawiki/semantic-glossary:dev-master
RUN COMPOSER=composer.local.json composer require --no-update mediawiki/semantic-extra-special-properties:~3.0

RUN composer update --no-dev
RUN composer update --no-dev


#############################
# Patches
# Review some patches https://github.com/CanastaWiki/Canasta/blob/master/Dockerfile and how they manage it.
# Patches currently not working, will have to review this later 
#############################

# SemanticResultFormats, see https://github.com/WikiTeq/SemanticResultFormats/compare/master...WikiTeq:fix1_35
#COPY _sources/patches/semantic-result-formats.patch /tmp/semantic-result-formats.patch
#RUN set -x; \
#	cd $MW_HOME/extensions/SemanticResultFormats \
#	&& patch < /tmp/semantic-result-formats.patch


##############################################################
# Scripts and Schedules
##############################################################
# Create cron schedule for every 5 minutes to execute runJobs.sh
# Modify LocalSettings.php "$WGJobRunRate = 0" to disable it from running based on the local trigger.
WORKDIR /
RUN mkdir scripts
COPY /scripts/runJobs.sh /scripts/runJobs.sh
RUN chmod 0644 /scripts/runJobs.sh
RUN crontab -l | { cat; echo "*/5 * * * * /scripts/runJobs.sh"; } | crontab -


#############################
# Cleanup
#############################

# Cleanup all .git leftovers
RUN set -x; \
    cd $MW_HOME \
    && find . \( -name ".git" -o -name ".gitignore" -o -name ".gitmodules" -o -name ".gitattributes" \) -exec rm -rf -- {} +

# Preference is to start here when using exec into the docker container.  
WORKDIR /var/www/html
    
