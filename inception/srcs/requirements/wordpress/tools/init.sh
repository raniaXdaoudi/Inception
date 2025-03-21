#!/bin/bash
# Check admin username
if [[ "${WP_ADMIN_USER}" =~ .*admin.* ]]; then
    echo "Error: Admin username cannot contain 'admin'"
    exit 1
fi

# Create necessary directories for PHP-FPM
mkdir -p /run/php

# Fix permissions
chown -R www-data:www-data /var/www/html

if [ ! -f /var/www/html/wp-config.php ]; then
    # Clear existing WordPress files if they exist without config
    if [ -f /var/www/html/index.php ] && [ ! -f /var/www/html/wp-config.php ]; then
        rm -rf /var/www/html/*
    fi

    # Wait for MariaDB to be ready
    echo "Waiting for MariaDB to be ready..."
    max_tries=60
    counter=0

    # First wait for the server to be online
    while ! ping -c 1 mariadb &>/dev/null; do
        echo "MariaDB server is not reachable yet..."
        sleep 5
        counter=$((counter+1))
        if [ $counter -ge 30 ]; then
            echo "MariaDB server is still not reachable after $counter attempts. Continuing anyway..."
            break
        fi
    done

    # Then try to connect to the database
    counter=0
    while ! mariadb -h mariadb -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SHOW DATABASES;" 2>/dev/null; do
        counter=$((counter+1))
        if [ $counter -ge $max_tries ]; then
            echo "Failed to connect to MariaDB after $max_tries attempts. Trying with root..."
            # Try with root user as fallback
            if mariadb -h mariadb -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE}; GRANT ALL ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%'; FLUSH PRIVILEGES;" 2>/dev/null; then
                echo "Database created with root user."
                break
            else
                echo "Will retry in a few seconds..."
                sleep 10
                counter=$((counter-10))
            fi
        fi
        echo "MariaDB is not ready yet, waiting... Attempt $counter/$max_tries"
        sleep 5
    done
    echo "MariaDB is ready or we're proceeding anyway!"

    cd /var/www/html
    # Download WordPress core
    echo "Downloading WordPress..."
    wp core download --allow-root

    # Create config file
    echo "Creating wp-config.php..."
    wp config create --dbname=${MYSQL_DATABASE} \
                    --dbuser=${MYSQL_USER} \
                    --dbpass=${MYSQL_PASSWORD} \
                    --dbhost=mariadb \
                    --allow-root

    # Install WordPress
    echo "Installing WordPress..."
    wp core install --url=${DOMAIN_NAME} \
                   --title="WordPress Site" \
                   --admin_user=${WP_ADMIN_USER} \
                   --admin_password=${WP_ADMIN_PASSWORD} \
                   --admin_email=${WP_ADMIN_EMAIL} \
                   --allow-root

    # Create additional user
    echo "Creating additional user..."
    wp user create ${WP_USER} ${WP_USER_EMAIL} \
                   --role=author \
                   --user_pass=${WP_USER_PASSWORD} \
                   --allow-root

    # Fix permissions again after installation
    chown -R www-data:www-data /var/www/html
    # Make sure permissions are set correctly for execution
    find /var/www/html -type d -exec chmod 755 {} \;
    find /var/www/html -type f -exec chmod 644 {} \;
    echo "WordPress setup completed!"
fi

# Even if WordPress is already installed, ensure proper permissions
if [ -d /var/www/html ]; then
    echo "Setting proper permissions for WordPress files..."
    chown -R www-data:www-data /var/www/html
    find /var/www/html -type d -exec chmod 755 {} \;
    find /var/www/html -type f -exec chmod 644 {} \;
fi

echo "Starting PHP-FPM..."
exec php-fpm7.3 -F
