FROM php:7.2-fpm-stretch
MAINTAINER Kentaro Ohkouchi

RUN echo "deb http://cdn.debian.net/debian/ stretch main contrib non-free" > /etc/apt/sources.list.d/mirror.jp.list
RUN echo "deb http://cdn.debian.net/debian/ stretch-updates main contrib" >> /etc/apt/sources.list.d/mirror.jp.list
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" >> /etc/apt/sources.list.d/mirror.jp.list

RUN /bin/rm /etc/apt/sources.list
RUN apt-get update && apt-get install -y wget gnupg2
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc \
     | apt-key add -

# apt-get and system utilities
RUN apt-get update && apt-get install -y \
    curl apt-utils apt-transport-https debconf-utils gcc build-essential zlib1g-dev git gnupg2 libfreetype6-dev libjpeg62-turbo-dev libpng-dev libpq-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) iconv zip gd pgsql mysqli pdo pdo_pgsql pdo_mysql \
    && rm -rf /var/lib/apt/lists/*

RUN rm -Rf /var/www/*
COPY . /var/www
RUN rm -rf .git
RUN chown -R www-data:www-data /var/www

RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/bin/composer
USER www-data

WORKDIR /var/www
RUN composer install --no-dev -o --apcu-autoloader

WORKDIR /var/www/html
VOLUME ["/var/www/html"]
USER root

EXPOSE 9000
CMD ["php-fpm"]
