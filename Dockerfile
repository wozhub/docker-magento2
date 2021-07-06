FROM php:7.3.28-apache-buster

# Install prerequisites
RUN apt-get update && \
    apt-get install -y \
        git \
        libfreetype6-dev \
        libicu-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libxml2-dev \
        libxslt1-dev \
        libzip-dev \
        && \
    rm -rf /var/lib/apt/lists/* && \
    curl -sS https://getcomposer.org/installer \
        | php -- --install-dir=/usr/bin --filename=composer \

# Build required extensions
RUN C_INCLUDE_PATH=/usr/include:/usr/local/include \
    docker-php-ext-configure gd --with-freetype-dir --with-jpeg-dir && \
    docker-php-ext-install -j$(nproc) \
        bcmath \
        gd \
        intl \
        pdo_mysql \
        soap \
        sockets \
        xsl \
        zip

# Install Magento2
ENV MAGENTO_VERSION=2.3.7
ENV MAGENTO_REPOSITORY=https://github.com/magento/magento2.git

RUN git clone \
        -b "${MAGENTO_VERSION}" \
        "${MAGENTO_REPOSITORY}" \
        /var/www/html && \
        cd /var/www/html && \
    composer install && \
    chown -R www-data:www-data .

RUN sed -i 's|Listen 80|Listen 8080|' /etc/apache2/ports.conf && \
    sed -i 's|*:80|*:8080|' /etc/apache2/sites-enabled/000-default.conf && \
    sed -i '/\/VirtualHost.*/i MARKER' /etc/apache2/sites-enabled/000-default.conf && \
    echo " \
    <Directory \"/var/www/html\">\n \
        Options FollowSymLinks \n \
        AllowOverride All \n \
    </Directory>" \
        > directory.conf && \
    sed -i -e '/MARKER/r directory.conf' -e '/MARKER/d' /etc/apache2/sites-enabled/000-default.conf && \
    rm directory.conf && \
    a2enmod rewrite

ADD *.sh *.env /

USER www-data
WORKDIR /var/www/html

ENTRYPOINT /run.sh
