#!/bin/bash
set -e

# Attendre que MariaDB soit prete (boucle de test, pas de sleep arbitraire)
echo "⏳ Attente de MariaDB..."
until mariadb -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1" &>/dev/null; do
    sleep 1
done
echo "✅ MariaDB est prete"

cd /var/www/wordpress

# Telecharger WordPress dans le volume s'il est vide
if [ ! -f wp-load.php ]; then
    echo "📥 Telechargement de WordPress..."
    wp core download --locale=fr_FR --allow-root
fi

# Creer wp-config.php s'il n'existe pas
if [ ! -f wp-config.php ]; then
    echo "⚙️ Creation du fichier wp-config.php..."
    wp config create --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASSWORD" --dbhost="$DB_HOST" --allow-root
fi

# Installer le site + les deux utilisateurs s'il n'est pas deja installe
if ! wp core is-installed --allow-root; then
    echo "🚀 Installation de WordPress..."
    wp core install --url="$WP_URL" --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" --skip-email --allow-root
    wp user create "$WP_USER" "$WP_USER_EMAIL" --role=author \
        --user_pass="$WP_USER_PASSWORD" --allow-root
fi

chown -R www-data:www-data /var/www/wordpress

# Lancer PHP-FPM au premier plan (-F)
echo "🎉 Demarrage de PHP-FPM"
exec php-fpm8.2 -F
