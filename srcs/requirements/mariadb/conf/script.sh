#!/bin/bash
set -eo pipefail

# Création des répertoires nécessaires
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Initialisation si nécessaire
if [ ! -d /var/lib/mysql/mysql ]; then
    echo "🔧 Initialisation de la base de données..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql

    # Démarrage temporaire
    echo "🚀 Démarrage temporaire de MariaDB..."
    mariadbd --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
    MARIADB_PID=$!

    # Attente connectivité
    echo "⏳ Attente du démarrage..."
    for i in {1..30}; do
        if mariadb -uroot -S/run/mysqld/mysqld.sock -e "SELECT 1" &>/dev/null; then
            break
        fi
        sleep 1
    done

    # Configuration initiale
    echo "⚙️ Configuration des utilisateurs..."
    mariadb -uroot -S/run/mysqld/mysqld.sock <<SQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
        DELETE FROM mysql.user WHERE User='';
        DROP DATABASE IF EXISTS test;
        CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MARIADB_ADMIN_USER}'@'%' IDENTIFIED BY '${MARIADB_ADMIN_USER_PASSWORD}';
        GRANT ALL ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_ADMIN_USER}'@'%';
        CREATE USER IF NOT EXISTS '${MARIADB_SECOND_USER}'@'%' IDENTIFIED BY '${MARIADB_SECOND_USER_PASSWORD}';
        GRANT SELECT,INSERT,UPDATE,DELETE ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_SECOND_USER}'@'%';
        FLUSH PRIVILEGES;
SQL

    # Arrêt propre
    kill ${MARIADB_PID}
    wait ${MARIADB_PID}
fi

# Démarrage final
echo "🎉 Démarrage de MariaDB en mode production"
exec mariadbd --user=mysql --bind-address=0.0.0.0
