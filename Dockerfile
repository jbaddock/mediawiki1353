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

# System Setup
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
        && aptitude update \
        && aptitude clean
   
# Extensions
RUN set -x; \
	cd $MW_HOME/extensions \
# AdvancedSearch
	&& git clone --single-branch -b $MW_VERSION https://gerrit.wikimedia.org/r/mediawiki/extensions/AdvancedSearch $MW_HOME/extensions/AdvancedSearch \
	&& cd $MW_HOME/extensions/AdvancedSearch \
	&& git checkout -q d1895707f3750a6d4a486b425ac9a727707f27f9 \
# CirrusSearch
	&& git clone --single-branch -b $MW_VERSION https://gerrit.wikimedia.org/r/mediawiki/extensions/CirrusSearch $MW_HOME/extensions/CirrusSearch \
	&& cd $MW_HOME/extensions/CirrusSearch \
	&& git checkout -q 203237ef2828c46094c5f6ba26baaeff2ab3596b \
# Elastica
	&& git clone --single-branch -b $MW_VERSION https://gerrit.wikimedia.org/r/mediawiki/extensions/Elastica $MW_HOME/extensions/Elastica \
	&& cd $MW_HOME/extensions/Elastica \
	&& git checkout -q 8af6b458adf628a98af4ba8e407f9c676bf4a4fb \
 # HeaderTabs (v. 2.2)
	&& git clone --single-branch -b master https://gerrit.wikimedia.org/r/mediawiki/extensions/HeaderTabs $MW_HOME/extensions/HeaderTabs \
	&& cd $MW_HOME/extensions/HeaderTabs \
	&& git checkout -q 37679158f93e4ba5a292744b30e2a64d50fb818c \
 # PageForms (v. 5.3.4)
	&& git clone --single-branch -b master https://gerrit.wikimedia.org/r/mediawiki/extensions/PageForms $MW_HOME/extensions/PageForms \
	&& cd $MW_HOME/extensions/PageForms \
	&& git checkout -q b9a4c1d8b8151611bc04bd7331d8b686e55e04af \ 
 # UserMerge
	&& git clone --single-branch -b $MW_VERSION https://gerrit.wikimedia.org/r/mediawiki/extensions/UserMerge $MW_HOME/extensions/UserMerge \
	&& cd $MW_HOME/extensions/UserMerge \
	&& git checkout -q 1c161b2c12c3882b4230561d1834e7c5170d9200 \
 # VoteNY
	&& git clone --single-branch -b $MW_VERSION https://gerrit.wikimedia.org/r/mediawiki/extensions/VoteNY $MW_HOME/extensions/VoteNY \
	&& cd $MW_HOME/extensions/VoteNY \
	&& git checkout -q b73dd009cf151a9f442361f6eb1e355817ca1e18 \



# Update and install prereqs for Mediawiki PDFHandler
# https://www.mediawiki.org/wiki/Extension:PdfHandler
 RUN set x; \
 	aptitude install -y \
 	  ghostscript \
 	  poppler-utils \
    && aptitude update \
    && aptitude clean

# Install composer
 COPY --from=composer:2.1.10 /usr/bin/composer /usr/local/bin/composer

# Configure Composer
# Issue with composer, so removing the vendor to prevent issues
 WORKDIR /var/www/html
 RUN rm -r vendor

RUN COMPOSER=composer.local.json composer require --no-update mediawiki/semantic-media-wiki:~3.2.3
RUN COMPOSER=composer.local.json composer require --no-update mediawiki/chameleon-skin:~4.0
RUN COMPOSER=composer.local.json composer require --no-update mediawiki/semantic-result-formats:~4.0
RUN COMPOSER=composer.local.json composer require --no-update mediawiki/lingo:~3.0
RUN COMPOSER=composer.local.json composer require --no-update mediawiki/semantic-glossary:~4.0
RUN COMPOSER=composer.local.json composer require --no-update mediawiki/semantic-extra-special-properties:~3.0

RUN composer update


# Patches
# Have not attempted any of these yet.  
# Review https://github.com/CanastaWiki/Canasta/blob/master/Dockerfile and how they manage it.

# SemanticResultFormats, see https://github.com/WikiTeq/SemanticResultFormats/compare/master...WikiTeq:fix1_35
COPY _sources/patches/semantic-result-formats.patch /tmp/semantic-result-formats.patch
RUN set -x; \
	cd $MW_HOME/extensions/SemanticResultFormats \
	&& patch < /tmp/semantic-result-formats.patch

# SWM maintenance page returns 503 (Service Unavailable) status code, PR: https://github.com/SemanticMediaWiki/SemanticMediaWiki/pull/4967
COPY _sources/patches/smw-maintenance-503.patch /tmp/smw-maintenance-503.patch
RUN set -x; \
	cd $MW_HOME/extensions/SemanticMediaWiki \
	&& patch -u -b src/SetupCheck.php -i /tmp/smw-maintenance-503.patch



# Cleanup all .git leftovers
RUN set -x; \
    cd $MW_HOME \
    && find . \( -name ".git" -o -name ".gitignore" -o -name ".gitmodules" -o -name ".gitattributes" \) -exec rm -rf -- {} +
    
    
