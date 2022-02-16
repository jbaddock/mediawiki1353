#Maintaining this MediaWiki version at this time as unsure if I wish to go to Semantic MediaWiki
From mediawiki:1.35.3

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer



# Update and install prereqs for Mediawiki PDFHandler
# https://www.mediawiki.org/wiki/Extension:PdfHandler
RUN apt-get update && apt-get install -y ghostscript poppler-utils unzip


# Chameleon Installation Using Composer
# https://github.com/ProfessionalWiki/chameleon/blob/master/docs/installation.md
WORKDIR /var/www/html
RUN composer update --no-dev

# Error with older packages, removing vendor folder to resolve.
RUN rm -r vendor
RUN COMPOSER=composer.local.json composer require --no-update mediawiki/chameleon-skin:~3.0
RUN composer update mediawiki/chameleon-skin --no-dev -o
