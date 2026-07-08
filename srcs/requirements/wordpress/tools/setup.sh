#!/bin/sh
set -eu

: "${WORDPRESS_DB_HOST:?WORDPRESS_DB_HOST is required}"
: "${WORDPRESS_DB_NAME:?WORDPRESS_DB_NAME is required}"
: "${WORDPRESS_DB_USER:?WORDPRESS_DB_USER is required}"
: "${WORDPRESS_DB_PASSWORD:?WORDPRESS_DB_PASSWORD is required}"

WP_PATH="/var/www/html"

if [ ! -f "$WP_PATH/wp-includes/version.php" ]; then
    cp -a /usr/share/wordpress/. "$WP_PATH/"
fi

if [ ! -f "$WP_PATH/wp-config.php" ] || grep -q "Debianised default master config file" "$WP_PATH/wp-config.php"; then
    cat > "$WP_PATH/wp-config.php" <<EOCFG
<?php
define( 'DB_NAME', '${WORDPRESS_DB_NAME}' );
define( 'DB_USER', '${WORDPRESS_DB_USER}' );
define( 'DB_PASSWORD', '${WORDPRESS_DB_PASSWORD}' );
define( 'DB_HOST', '${WORDPRESS_DB_HOST}' );
define( 'DB_CHARSET', 'utf8mb4' );
define( 'DB_COLLATE', '' );

define( 'AUTH_KEY',         'change-this-auth-key' );
define( 'SECURE_AUTH_KEY',  'change-this-secure-auth-key' );
define( 'LOGGED_IN_KEY',    'change-this-logged-in-key' );
define( 'NONCE_KEY',        'change-this-nonce-key' );
define( 'AUTH_SALT',        'change-this-auth-salt' );
define( 'SECURE_AUTH_SALT', 'change-this-secure-auth-salt' );
define( 'LOGGED_IN_SALT',   'change-this-logged-in-salt' );
define( 'NONCE_SALT',       'change-this-nonce-salt' );

\$table_prefix = 'wp_';

define( 'WP_DEBUG', false );
define( 'FORCE_SSL_ADMIN', true );

if (isset(\$_SERVER['HTTP_X_FORWARDED_PROTO']) && \$_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    \$_SERVER['HTTPS'] = 'on';
}

if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php';
EOCFG
fi

chown -R www-data:www-data "$WP_PATH"

exec php-fpm8.2 -F
