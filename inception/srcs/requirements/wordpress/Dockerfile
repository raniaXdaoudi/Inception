FROM debian:bullseye

# Installation des dépôts et paquets PHP
RUN apt-get update && apt-get install -y lsb-release apt-transport-https ca-certificates wget \
    && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list

# Installation des paquets nécessaires
RUN apt-get update && apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-curl \
    php7.4-json \
    php7.4-mbstring \
    php7.4-xml \
    php7.4-zip \
    php7.4-gd \
    php7.4-intl \
    php7.4-soap \
    php7.4-opcache \
    curl \
    mariadb-client \
    && mkdir -p /run/php \
    && mkdir -p /var/log \
    && mkdir -p /var/www/html \
    && touch /var/log/php7.4-fpm.log \
    && chown -R www-data:www-data /var/log/php7.4-fpm.log \
    && chown -R www-data:www-data /run/php \
    && chown -R www-data:www-data /var/www/html \
    && chmod 755 /var/www/html \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Installation de WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Configuration de PHP-FPM
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
RUN mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www/html && \
    chmod 755 /var/www/html

# Script d'initialisation
COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

WORKDIR /var/www/html

EXPOSE 9000

# Vérification des fichiers de configuration
RUN test -f /etc/php/7.4/fpm/pool.d/www.conf || exit 1
RUN test -x /init.sh || exit 1
RUN test -d /var/www/html || exit 1
RUN test -w /var/www/html || exit 1

CMD ["/init.sh"] 