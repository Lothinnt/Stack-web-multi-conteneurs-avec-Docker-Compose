FROM debian:12-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends nginx openssl \
    && rm -rf /var/lib/apt/lists/*

COPY conf/default.conf /etc/nginx/sites-available/default

RUN mkdir -p /etc/nginx/ssl /run/nginx \
    && openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
        -keyout /etc/nginx/ssl/server.key \
        -out /etc/nginx/ssl/server.crt \
        -subj "/C=FR/ST=Ile-de-France/L=Paris/O=WordPress/OU=Infra/CN=localhost"

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
