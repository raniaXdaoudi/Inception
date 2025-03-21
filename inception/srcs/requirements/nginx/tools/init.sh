#!/bin/bash

# Ensure proper access to webroot
echo "Checking WordPress directory permissions..."
if [ -d /var/www/html ]; then
    # Make sure nginx user has access to the files
    chmod -R 755 /var/www/html
    # Ensure Nginx can read all files
    find /var/www/html -type f -exec chmod 644 {} \;
    echo "Permissions set correctly"
fi

# Start Nginx in foreground
echo "Starting Nginx..."
exec nginx -g "daemon off;"
