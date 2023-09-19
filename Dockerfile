FROM php:7.4-fpm-alpine

RUN docker-php-ext-install pdo pdo_mysql pcntl \
  && apk add --update git unzip nodejs npm

# Composer install
# Version specification: --from=composer:2.1.11
COPY --from=composer /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer
ENV PATH $PATH:/composer/vendor/bin


WORKDIR /var/www/html

RUN composer global require "laravel/installer"
