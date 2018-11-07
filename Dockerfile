FROM nanasess/azure-nginx-fpm:latest
MAINTAINER Kentaro Ohkouchi

RUN echo "deb http://cdn.debian.net/debian/ stretch main contrib non-free" > /etc/apt/sources.list.d/mirror.jp.list
RUN echo "deb http://cdn.debian.net/debian/ stretch-updates main contrib" >> /etc/apt/sources.list.d/mirror.jp.list
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" >> /etc/apt/sources.list.d/mirror.jp.list

RUN /bin/rm /etc/apt/sources.list
RUN apt-get update && apt-get install -y wget gnupg2
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc \
     | apt-key add -

# apt-get and system utilities
RUN apt-get update && apt-get install -y postgresql \
    && rm -rf /var/lib/apt/lists/*

COPY dockerbuild/nginx.conf /etc/nginx/nginx.conf

RUN rm -Rf /home/site/wwwroot
COPY . /home/site/wwwroot
RUN rm -rf .git
RUN chown -R www-data:www-data /home/site/wwwroot

RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/bin/composer
USER www-data

WORKDIR /home/site/wwwroot
RUN composer install --no-dev -o --apcu-autoloader

WORKDIR /home/site/wwwroot
VOLUME ["/home/site/wwwroot"]
USER root

COPY dockerbuild/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
EXPOSE 2222 80

CMD ["entrypoint.sh"]
