FROM debian:bullseye

# Add PHP 7.3 repository
RUN apt-get update && apt-get install -y lsb-release apt-transport-https ca-certificates wget iputils-ping \
    && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list

RUN apt-get update && apt-get install -y \
    php7.3-fpm \
    php7.3-mysql \
    mariadb-client \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY conf/www.conf /etc/php/7.3/fpm/pool.d/www.conf

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Create directory for PHP-FPM socket
RUN mkdir -p /run/php && chown www-data:www-data /run/php

COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

WORKDIR /var/www/html

EXPOSE 9000

CMD ["/init.sh"]
