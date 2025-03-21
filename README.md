# Inception

A system administration project using Docker to set up a complete web infrastructure. This project is part of the 42 school curriculum.

## Description

This project involves setting up a small infrastructure composed of different services under specific rules using Docker containers. Each service runs in its own container, built from scratch using either Alpine or Debian. The whole infrastructure is set up using Docker Compose and runs in a virtual machine.

## Mandatory Services

The project must contain exactly:
- 3 containers, each with a specific service:
  - NGINX container with TLSv1.2 or TLSv1.3
  - WordPress + php-fpm container (without NGINX)
  - MariaDB container
- 2 volumes:
  - WordPress database (/home/$(USER)/data/mysql/)
  - WordPress website files (/home/$(USER)/data/wordpress/)
- 1 docker-network that establishes the connection between containers

## Technologies Used
- Docker & Docker Compose
- NGINX with TLSv1.2/1.3
- WordPress + PHP-FPM
- MariaDB
- Alpine/Debian as base images
- Shell scripting
- SSL/TLS (self-signed certificates)
- Make (build system)

## Key Requirements

- All containers must be built from scratch using either Alpine or Debian
- Each service must run in a dedicated container
- Containers must restart in case of crash
- Docker-compose must be used for container orchestration
- No usage of pre-built images or services like DockerHub (except for base images)
- No installation using package managers or other tools in setup scripts

## Project Structure

```
Inception/
├── README.md
└── inception/
    ├── Makefile
    └── srcs/
        ├── docker-compose.yml
        ├── .env
        └── requirements/
            ├── nginx/
            │   ├── Dockerfile
            │   ├── conf/
            │   │   ├── main-nginx.conf
            │   │   ├── nginx.conf
            │   │   ├── nginx.crt
            │   │   └── nginx.key
            │   └── tools/
            │       └── init.sh
            ├── wordpress/
            │   ├── Dockerfile
            │   ├── conf/
            │   │   └── www.conf
            │   └── tools/
            │       └── init.sh
            └── mariadb/
                ├── Dockerfile
                ├── conf/
                │   └── 50-server.cnf
                └── tools/
                    └── init.sh
```

### Environment Variables
Required environment variables in `.env`:
```env
# Domain
DOMAIN_NAME=radaoudi.42.fr

# MariaDB
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD=wp_password
MYSQL_ROOT_PASSWORD=root_password

# WordPress
WP_ADMIN_USER=superuser
WP_ADMIN_PASSWORD=admin_password
WP_ADMIN_EMAIL=admin@example.com
WP_USER=user1
WP_USER_PASSWORD=user1_password
WP_USER_EMAIL=user1@example.com
```

## Implementation Details

The setup must:
1. Use Docker Compose for orchestration
2. Build all images from scratch
3. Configure SSL/TLS for NGINX with self-signed certificate
4. Set up WordPress with php-fpm and two users (admin and regular)
5. Configure MariaDB for data persistence with database creation at build
6. Establish container networking
7. Ensure service auto-restart
8. Mount volumes for data persistence in /home/$(USER)/data/

## Container Specifications

### NGINX Container
- Built from Alpine/Debian
- Only TLSv1.2 or TLSv1.3
- Listens on port 443 only
- SSL/TLS configuration with self-signed certificate
- Connects to WordPress container
- Configuration files:
  - main-nginx.conf: Main NGINX configuration
  - nginx.conf: Default site configuration
  - nginx.crt/nginx.key: SSL certificate and private key

### WordPress + php-fpm Container
- Built from Alpine/Debian
- WordPress latest version
- php-fpm configuration
- No NGINX
- Connected to MariaDB
- Two users configured:
  - Admin user (superuser with all privileges)
  - Regular user (user1 with author role)
- Configuration files:
  - www.conf: PHP-FPM pool configuration

### MariaDB Container
- Built from Alpine/Debian
- Data persistence through volume in /home/$(USER)/data/mysql/
- Secure initial setup
- No root access from outside
- Database created during container build
- User privileges configured at startup
- Configuration files:
  - 50-server.cnf: MariaDB server configuration with optimized settings

## Building and Usage
```bash
# Prepare environment, build and start services
make

# Start services
make up

# Stop services
make down

# Clean (prune and remove data)
make clean

# Full cleanup (including volumes)
make fclean

# Rebuild everything
make re
```

## Testing
Verify the setup by:
- Accessing WordPress via HTTPS (port 443)
- Testing database persistence in /home/$(USER)/data/mysql/
- Checking container logs
- Verifying auto-restart functionality
- Validating SSL/TLS configuration
- Testing volume persistence in both data directories

## Authors
Project developed by:
- Rania (radaoudi)

## License
This project is part of the 42 school curriculum. Please refer to 42's policies regarding code usage and distribution.

## Acknowledgments
- 42 school for providing project requirements
- Docker documentation
- NGINX, WordPress, and MariaDB documentation

## Recent Updates
- Added comprehensive configuration files for all services
- Improved container initialization scripts
- Optimized MariaDB server configuration for better performance
