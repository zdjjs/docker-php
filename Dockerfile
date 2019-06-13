FROM php:7.3-alpine
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

RUN wget https://github.com/progrium/entrykit/releases/download/v0.4.0/entrykit_0.4.0_linux_x86_64.tgz \
&& tar -xvzf entrykit_0.4.0_linux_x86_64.tgz \
&& rm entrykit_0.4.0_linux_x86_64.tgz \
&& mv entrykit /usr/local/bin/ \
&& entrykit --symlink

RUN apk --no-cache update \
&& apk add --no-cache curl postgresql-dev libpng-dev libjpeg-turbo-dev icu-dev \
&& docker-php-ext-configure gd --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ \
&& docker-php-ext-configure intl --enable-intl \
&& docker-php-ext-install exif pdo_pgsql gd intl opcache pcntl

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer \
&& composer config -g repos.packagist composer https://packagist.jp \
&& composer global require hirak/prestissimo \
&& composer clear-cache

WORKDIR /var/www/html

ENTRYPOINT [ "prehook", "composer install", "--", "/bin/sh" ]
