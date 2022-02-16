#Maintaining this MediaWiki version at this time as unsure if I wish to go to Semantic MediaWiki
From mediawiki:1.35.3

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer


WORKDIR /var/www/html
RUN composer update -no-plugins --no-scripts
