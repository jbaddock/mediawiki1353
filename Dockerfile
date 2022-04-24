#Maintaining this MediaWiki version at this time as unsure if I wish to go to Semantic MediaWiki
From mediawiki:1.35.3

# Install composer
COPY --from=composer:2.1.10 /usr/bin/composer /usr/local/bin/composer

# Download and extract Extensions for MW 1.35
WORKDIR /var/www/html/extensions
RUN curl -LJO https://extdist.wmflabs.org/dist/extensions/Elastica-REL1_35-cffef9d.tar.gz
RUN tar -xzf Elastica-REL1_35-cffef9d.tar.gz
RUN curl -LJO https://extdist.wmflabs.org/dist/extensions/CirrusSearch-REL1_35-41d631e.tar.gz
RUN tar -xzf CirrusSearch-REL1_35-41d631e.tar.gz
RUN curl -LJO https://extdist.wmflabs.org/dist/extensions/AdvancedSearch-REL1_35-d344ce2.tar.gz
RUN tar -xzf AdvancedSearch-REL1_35-d344ce2.tar.gz
RUN curl -LJO https://extdist.wmflabs.org/dist/extensions/HeaderTabs-REL1_35-f688fab.tar.gz
RUN tar -xzf HeaderTabs-REL1_35-f688fab.tar.gz
RUN curl -LJO https://extdist.wmflabs.org/dist/extensions/PageForms-REL1_35-81f6ff9.tar.gz
RUN tar -xzf PageForms-REL1_35-81f6ff9.tar.gz
RUN curl -LJO https://extdist.wmflabs.org/dist/extensions/VoteNY-REL1_35-2394205.tar.gz
RUN tar -xzf VoteNY-REL1_35-2394205.tar.gz


#RUN curl -LJO https://github.com/enterprisemediawiki/MasonryMainPage/archive/master.zip
#RUN unzip MasonryMainPage-master.zip
#RUN mv MasonryMainPage-master MasonryMainPage
#RUN curl -LJO https://github.com/wikimedia/mediawiki-extensions-PageForms/archive/5.3.4.zip
#RUN unzip mediawiki-extensions-PageForms-5.3.4.zip
#RUN mv mediawiki-extensions-PageForms-5.3.4 PageForms

RUN rm Elastica-REL1* CirrusSearch-REL1* AdvancedSearch-REL1*z HeaderTabs-REL1* PageForms-REL1* VoteNY-REL1*

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
