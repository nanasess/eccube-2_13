FROM php:8.0-apache

RUN apt-get update \
    && apt-get install -y \
        git unzip curl apt-transport-https gnupg wget \
        libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
        libpq-dev \
        libzip-dev zlib1g-dev \
        libpcre3-dev \
        ssl-cert \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd zip mysqli pgsql opcache
RUN pecl install apcu && docker-php-ext-enable apcu

# composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

# entrypoint
COPY dockerbuild/docker-php-entrypoint /usr/local/bin/

# workdir
WORKDIR /var/www/app

# Enable SSL
RUN a2enmod ssl rewrite headers

ENV APACHE_DOCUMENT_ROOT /var/www/app/html
ENV ECCUBE_PREFIX /var/www/app

RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    ssl-cert \
    mariadb-client postgresql-client \
    && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${APACHE_DOCUMENT_ROOT} \
  && sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
  && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf \
  ;

## Enable SSL
RUN a2ensite default-ssl
EXPOSE 443

WORKDIR ${ECCUBE_PREFIX}

COPY dockerbuild/wait-for-*.sh /
RUN chmod +x /wait-for-*.sh

COPY composer.json ${ECCUBE_PREFIX}/composer.json
COPY composer.lock ${ECCUBE_PREFIX}/composer.lock

RUN composer selfupdate --2
RUN composer install --no-scripts --no-autoloader --no-dev -d ${ECCUBE_PREFIX}

COPY . ${ECCUBE_PREFIX}
RUN composer dumpautoload -o --apcu
