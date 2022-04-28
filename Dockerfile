From mediawiki:1.35.6

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
        && apt-get aptitude 


