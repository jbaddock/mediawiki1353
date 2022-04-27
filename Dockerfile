#Maintaining this MediaWiki version at this time as unsure if I wish to go to Semantic MediaWiki
From mediawiki:1.35.3

# Install unzip
RUN apt-get update && apt-get install unzip

# Install composer
COPY --from=composer:2.1.10 /usr/bin/composer /usr/local/bin/composer

# Download and extract Extensions for MW 1.35
# When modifying this file, validate the extension download is still valid or if a new version was released.
WORKDIR /var/www/html/extensions
RUN curl -LJO https://extdist.wmflabs.org/dist/extensions/Elastica-REL1_35-91bafe6.tar.gz
RUN tar -xzf Elastica-REL1_35-91bafe6.tar.gz
RUN curl -LJO https://extdist.wmflabs.org/dist/extensions/CirrusSearch-REL1_35-52cfb5f.tar.gz
RUN tar -xzf CirrusSearch-REL1_35-52cfb5f.tar.gz
RUN curl -LJO https://extdist.wmflabs.org/dist/extensions/AdvancedSearch-REL1_35-4e8a9f3.tar.gz
RUN tar -xzf AdvancedSearch-REL1_35-4e8a9f3.tar.gzv
RUN curl -LJO https://extdist.wmflabs.org/dist/extensions/HeaderTabs-REL1_35-f688fab.tar.gz
RUN tar -xzf HeaderTabs-REL1_35-f688fab.tar.gz
RUN curl -LJO https://extdist.wmflabs.org/dist/extensions/UserMerge-REL1_35-184a438.tar.gz
RUN tar -xzf UserMerge-REL1_35-184a438.tar.gz



# Unzip section
RUN curl -LJO https://github.com/wikimedia/mediawiki-extensions-PageForms/archive/5.4.zip
RUN unzip mediawiki-extensions-PageForms-5.4.zip
RUN mv mediawiki-extensions-PageForms-5.4 PageForms


RUN rm Elastica-REL1* CirrusSearch-REL1* AdvancedSearch-REL1*z HeaderTabs-REL1* VoteNY-REL1* mediawiki-extensions-PageForms-5.4.zip UserMerge-REL1*

# Update and install prereqs for Mediawiki PDFHandler
# https://www.mediawiki.org/wiki/Extension:PdfHandler
RUN apt-get update && apt-get install -y ghostscript poppler-utils unzip

WORKDIR /var/www/html

RUN rm -r vendor

RUN COMPOSER=composer.local.json composer require --no-update mediawiki/semantic-media-wiki:~3.2.3
RUN COMPOSER=composer.local.json composer require --no-update mediawiki/chameleon-skin:~4.0
RUN COMPOSER=composer.local.json composer require --no-update mediawiki/semantic-result-formats:~4.0
RUN COMPOSER=composer.local.json composer require --no-update mediawiki/lingo:~3.0
RUN COMPOSER=composer.local.json composer require --no-update mediawiki/semantic-glossary:~4.0
RUN COMPOSER=composer.local.json composer require --no-update mediawiki/semantic-extra-special-properties:~3.0

RUN composer update
