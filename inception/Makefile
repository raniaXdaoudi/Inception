NAME = inception

all: prepare build up

prepare:
	@printf "Preparing environment...\n"
	@sudo mkdir -p /home/$(USER)/data/wordpress
	@sudo mkdir -p /home/$(USER)/data/mysql

build:
	@printf "Building containers...\n"
	@docker-compose -f srcs/docker-compose.yml build

up:
	@printf "Starting containers...\n"
	@docker-compose -f srcs/docker-compose.yml up -d

down:
	@printf "Stopping containers...\n"
	@docker-compose -f srcs/docker-compose.yml down

clean: down
	@printf "Cleaning up...\n"
	@docker system prune -af
	@sudo rm -rf /home/$(USER)/data/wordpress/*
	@sudo rm -rf /home/$(USER)/data/mysql/*

fclean: clean
	@printf "Full cleanup...\n"
	@docker volume ls -q | grep -q . && docker volume rm $$(docker volume ls -q) || true

re: fclean all

.PHONY: all prepare build up down clean fclean re