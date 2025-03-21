#!/bin/bash

# Create directories if needed
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld /var/lib/mysql

# Check if this is the first run
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Start MariaDB in background
    /usr/bin/mysqld_safe --datadir=/var/lib/mysql &

    # Wait for MariaDB to start
    until mysqladmin ping >/dev/null 2>&1; do
        echo "Waiting for MariaDB to be ready..."
        sleep 2
    done

    # Create database and users
    echo "Creating database and users..."
    mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    # Stop the temporary server
    mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown
    echo "MariaDB initialization completed!"
else
    echo "MariaDB data directory already exists. Checking if initialization is needed..."
    # Start MariaDB in background for potential adjustments
    /usr/bin/mysqld_safe --datadir=/var/lib/mysql &

    # Wait for MariaDB to start
    until mysqladmin ping >/dev/null 2>&1; do
        echo "Waiting for MariaDB to be ready..."
        sleep 2
    done

    # Check if our user exists
    mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "SELECT User FROM mysql.user WHERE User='${MYSQL_USER}'" | grep -q ${MYSQL_USER}
    USER_EXISTS=$?

    if [ $USER_EXISTS -ne 0 ]; then
        echo "User ${MYSQL_USER} doesn't exist. Creating..."
        mysql -uroot -p${MYSQL_ROOT_PASSWORD} <<EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    else
        echo "User ${MYSQL_USER} already exists."
    fi

    # Stop the temporary server
    mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown
fi

# Start MariaDB in foreground
echo "Starting MariaDB in foreground..."
exec mysqld --user=mysql
