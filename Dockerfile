#Maintaining this MediaWiki version at this time as unsure if I wish to go to Semantic MediaWiki
From mediawiki:1.35.3

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Download and extract Extensions for 1.35
WORKDIR /var/www/html/extensions
RUN curl -LJO https://extdist.wmflabs.org/dist/extensions/Elastica-REL1_35-cffef9d.tar.gz
RUN tar -xzf Elastica-REL1_35-cffef9d.tar.gz
RUN curl -LJO https://extdist.wmflabs.org/dist/extensions/CirrusSearch-REL1_35-41d631e.tar.gz
RUN tar -xzf CirrusSearch-REL1_35-41d631e.tar.gz
RUN curl -LJO https://extdist.wmflabs.org/dist/extensions/AdvancedSearch-REL1_35-d344ce2.tar.gz
RUN tar -xzf AdvancedSearch-REL1_35-d344ce2.tar.gz
#RUN curl -LJO https://github.com/enterprisemediawiki/MasonryMainPage/archive/master.zip
#RUN unzip MasonryMainPage-master.zip
#RUN mv MasonryMainPage-master MasonryMainPage

RUN rm Elastica-REL1_35-cffef9.tar.gz CirrusSearch-REL1_35-41d631e.tar.gz AdvancedSearch-REL1_35-d344ce2.tar.gz

# Update and install prereqs for Mediawiki PDFHandler
# https://www.mediawiki.org/wiki/Extension:PdfHandler
RUN apt-get update && apt-get install -y ghostscript poppler-utils unzip

# Chameleon Installation Using Composer
# https://github.com/ProfessionalWiki/chameleon/blob/master/docs/installation.md
WORKDIR /var/www/html
RUN composer update
# Error with older packages, removing vendor folder to resolve.
RUN rm -r vendor
RUN COMPOSER=composer.local.json composer require --no-update mediawiki/chameleon-skin:~3.0
RUN composer update mediawiki/chameleon-skin --no-dev -o

# Semantic Result Formats
RUN COMPOSER=composer.local.json composer require --no-update mediawiki/semantic-result-formats:~4.0

# Install Semantic MediaWiki  
# Installation instructions https://www.semantic-mediawiki.org/wiki/Help:Installation/Quick_guide
# Modified to run following the above example for composer.
RUN COMPOSER=composer.local.json composer require --no-update mediawiki/semantic-media-wiki
RUN composer update --no-dev
