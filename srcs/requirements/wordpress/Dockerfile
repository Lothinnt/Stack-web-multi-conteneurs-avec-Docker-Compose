FROM debian:12-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        php-fpm \
        php-mysql \
        php-curl \
        php-gd \
        php-mbstring \
        php-xml \
        php-zip \
        mariadb-client \
        wordpress \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh \
    && mkdir -p /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]
