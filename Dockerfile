FROM php:7.3.8-apache
maintainer Rodrigo Manara <me@rodrigomanara.co.uk>

RUN apt-get -y update --fix-missing
RUN apt-get upgrade -y

RUN apt-get install -y libgmp-dev re2c libmhash-dev libmcrypt-dev file
RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/local/include/
RUN docker-php-ext-configure gmp 
RUN docker-php-ext-install gmp

RUN apt-get -y install --fix-missing apt-utils build-essential

RUN apt-get -y install libsqlite3-dev libsqlite3-0 mariadb-client
RUN docker-php-ext-install pdo_mysql 
RUN docker-php-ext-install pdo_sqlite
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install bcmath

RUN apt-get update && apt-get install -y \
    zlib1g-dev \
    libzip-dev
RUN docker-php-ext-install zip
#setup composer
RUN curl -sS https://getcomposer.org/installer | php \
        && mv composer.phar /usr/local/bin/ \
        && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer


#RUN pecl install apcu && docker-php-ext-enable apcu
RUN a2enmod rewrite headers alias expires mime authz_host 
RUN docker-php-ext-install calendar && docker-php-ext-configure calendar


RUN apt-get install git -y
RUN docker-php-ext-install opcache

# Install Xdebug
RUN curl -fsSL 'https://xdebug.org/files/xdebug-2.5.1.tgz' -o xdebug.tar.gz
RUN ls
RUN mkdir -p xdebug
RUN tar -xf xdebug.tar.gz -C xdebug --strip-components=1
RUN rm xdebug.tar.gz
RUN mkdir test4
RUN	cd xdebug && phpize && ./configure --enable-xdebug && make -j$(nproc) && make install

RUN rm -r xdebug \
    && docker-php-ext-enable xdebug


RUN apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/freetype --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && rm -r /var/lib/apt/lists/*

# Set file permissions
RUN chmod -R 777 /var/www /var/www/.* \
  && chown -R www-data:www-data /var/www /var/www/.* \
  && usermod -u 1000 www-data \
  && chsh -s /bin/bash www-data



