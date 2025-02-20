#!/bin/bash

# Fonction de logging
log() {
    echo "[MariaDB Init] $1"
}

# Vérification des variables d'environnement
if [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ] || [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    log "Error: Required environment variables are not set"
    exit 1
fi

# Création des répertoires nécessaires
log "Creating necessary directories..."
mkdir -p /var/run/mysqld /var/lib/mysql /var/log/mysql
chown -R mysql:mysql /var/run/mysqld /var/lib/mysql /var/log/mysql
chmod 777 /var/run/mysqld
chmod 755 /var/log/mysql

# Initialisation de la base de données si nécessaire
if [ ! -d "/var/lib/mysql/mysql" ]; then
    log "Initializing MariaDB database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --basedir=/usr > /dev/null 2>&1

    # Démarrer MariaDB temporairement
    log "Starting temporary MariaDB server..."
    mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0 --skip-networking=0 &
    
    # Attendre que MariaDB soit prêt
    until mysqladmin ping -h localhost --silent; do
        log "Waiting for MariaDB to be ready..."
        sleep 1
    done

    log "Configuring MariaDB..."
    mysql -u root << EOF
-- Nettoyage initial
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Création de la base de données
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

-- Configuration de root
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- Configuration de l'utilisateur WordPress
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF

    # Arrêter le serveur temporaire
    log "Stopping temporary MariaDB server..."
    mysqladmin -u root shutdown
    
    log "Initial database configuration completed"
fi

# Démarrer MariaDB normalement
log "Starting MariaDB server..."
log "MariaDB will listen on 0.0.0.0:3306"
exec mysqld --user=mysql --bind-address=0.0.0.0 --skip-networking=0 --console