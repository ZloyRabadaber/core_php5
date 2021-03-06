FROM php:5-apache

MAINTAINER Zloy Rabadaber <zrabadaber@gmail.com>
ENV REFRESHED_AT 2016-03-01

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libssl-dev \
        ssmtp \
    && docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install mbstring \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-configure mysql --with-mysql=mysqlnd \
    && docker-php-ext-configure mysqli --with-mysqli=mysqlnd \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install mysql \
    && docker-php-ext-install mcrypt \
    && docker-php-ext-install ftp \
    && docker-php-ext-install -j$(nproc) gd

RUN curl -fsSL 'https://xcache.lighttpd.net/pub/Releases/3.2.0/xcache-3.2.0.tar.gz' -o xcache.tar.gz \
    && mkdir -p /tmp/xcache \
    && tar -xf xcache.tar.gz -C /tmp/xcache --strip-components=1 \
    && rm xcache.tar.gz \
    && docker-php-ext-configure /tmp/xcache --enable-xcache \
    && docker-php-ext-install /tmp/xcache \
    && rm -r /tmp/xcache

RUN a2enmod remoteip
RUN a2enmod rewrite
RUN a2enmod ssl
RUN a2enmod headers

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ./php/uploads.ini  $PHP_INI_DIR/conf.d/uploads.ini
ADD ./php/mail.ini  $PHP_INI_DIR/conf.d/mail.ini
ADD ./php/xcache.ini  $PHP_INI_DIR/conf.d/xcache.ini

ADD ./html/myip.php /var/www/html/myip.php
ADD ./html/phpinfo.php /var/www/html/phpinfo.php

RUN echo "RemoteIPHeader X-Forwarded-For" >> /etc/apache2/apache2.conf && \
    echo "RemoteIPHeader X-Real-IP" >> /etc/apache2/apache2.conf

RUN echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf

ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOG_DIR /var/log/apache2

VOLUME /var/www
VOLUME /etc/apache2/sites-available

EXPOSE 80
EXPOSE 443
