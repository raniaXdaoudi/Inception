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
  - WordPress database
  - WordPress website files
- 1 docker-network that establishes the connection between containers

## Bonus Services (Optional)

Additional containers can be added for:
- Redis cache for WordPress
- FTP server
- Static website
- Adminer
- Service of your choice

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
├── Makefile
├── srcs/
│   ├── docker-compose.yml
│   ├── .env
│   └── requirements/
│       ├── nginx/
│       │   ├── Dockerfile
│       │   ├── conf/
│       │   └── tools/
│       ├── wordpress/
│       │   ├── Dockerfile
│       │   ├── conf/
│       │   └── tools/
│       └── mariadb/
│           ├── Dockerfile
│           ├── conf/
│           └── tools/
└── volumes/
    ├── wordpress/
    └── mariadb/
```

### Environment Variables
Required environment variables in `.env`:
```env
DOMAIN_NAME=login.42.fr
CERTS_=/etc/ssl/certs/inception.crt
KEY_=/etc/ssl/private/inception.key
DB_NAME=wordpress
DB_ROOT=rootpass
DB_USER=wpuser
DB_PASS=wppass
```

## Implementation Details

The setup must:
1. Use Docker Compose for orchestration
2. Build all images from scratch
3. Configure SSL/TLS for NGINX
4. Set up WordPress with php-fpm
5. Configure MariaDB for data persistence
6. Establish container networking
7. Ensure service auto-restart
8. Mount volumes for data persistence

## Container Specifications

### NGINX Container
- Built from Alpine/Debian
- Only TLSv1.2 or TLSv1.3
- Listens on port 443 only
- SSL/TLS configuration
- Connects to WordPress container

### WordPress + php-fpm Container
- Built from Alpine/Debian
- WordPress latest version
- php-fpm configuration
- No NGINX
- Connected to MariaDB

### MariaDB Container
- Built from Alpine/Debian
- Data persistence through volume
- Secure initial setup
- No root access from outside

## Building and Usage
```bash
# Build and start all services
make

# Stop all services
make stop

# Clean everything
make fclean

# Rebuild all
make re
```

## Testing
Verify the setup by:
- Accessing WordPress via HTTPS (port 443)
- Testing database persistence
- Checking container logs
- Verifying auto-restart functionality
- Validating SSL/TLS configuration
- Testing volume persistence

## Authors
Project developed by:
- Rania (radaoudi)

## License
This project is part of the 42 school curriculum. Please refer to 42's policies regarding code usage and distribution.

## Acknowledgments
- 42 school for providing project requirements
- Docker documentation
- NGINX, WordPress, and MariaDB documentation
