#!/bin/bash

# Fonction de logging
log() {
    echo "[WordPress Init] $1"
}

# Vérification du nom d'admin
if [[ "${WP_ADMIN_USER}" =~ ^.*admin.*$ ]] || [[ "${WP_ADMIN_USER}" =~ ^.*Admin.*$ ]]; then
    log "Error: Admin username cannot contain 'admin' or 'Admin'"
    exit 1
fi

# Vérification des variables d'environnement
if [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ] || [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    log "Error: Required database environment variables are not set"
    exit 1
fi

# Fonction pour tester la connexion à la base de données
test_db_connection() {
    log "Testing connection to MariaDB (Host: mariadb, User: ${MYSQL_USER})..."
    mysqladmin ping -h mariadb -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" 2>/dev/null
    local result=$?
    if [ $result -eq 0 ]; then
        log "Connection test successful!"
    else
        log "Connection test failed. Error code: $result"
    fi
    return $result
}

# Attendre que MariaDB soit disponible
log "Waiting for MariaDB to be ready..."
max_tries=30
count=0

while [ $count -lt $max_tries ]; do
    if test_db_connection; then
        log "Successfully connected to MariaDB!"
        break
    fi
    count=$((count + 1))
    log "Attempt $count/$max_tries - Waiting for MariaDB..."
    sleep 10
done

if [ $count -eq $max_tries ]; then
    log "Error: Could not connect to MariaDB after $max_tries attempts"
    log "Last connection attempt details:"
    mysql -h mariadb -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT VERSION();" 2>&1
    exit 1
fi

# Préparation du répertoire
log "Setting up WordPress directory..."
mkdir -p /var/www/html
cd /var/www/html

if [ ! -f "wp-config.php" ]; then
    log "Downloading WordPress..."
    wp core download --allow-root

    log "Creating WordPress configuration..."
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost=mariadb \
        --allow-root

    log "Installing WordPress..."
    wp core install \
        --url="${DOMAIN_NAME}" \
        --title="WordPress Site" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    log "Creating additional user..."
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root

    log "Setting up French language..."
    wp language core install fr_FR --activate --allow-root
fi

# Configuration des permissions
log "Setting final permissions..."
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

log "Starting PHP-FPM..."
exec php-fpm7.4 -F