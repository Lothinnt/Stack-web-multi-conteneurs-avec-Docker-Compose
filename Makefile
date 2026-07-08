# Chemin des donnees (doit correspondre a DATA_PATH dans srcs/.env)
DATA_PATH = $(HOME)/data

# Creation des images et des conteneurs pour inception
all:
	mkdir -p $(DATA_PATH)/wordpress $(DATA_PATH)/mariadb
	docker compose -f ./srcs/docker-compose.yml up --build -d

# Stop inception
stop:
	docker compose -f ./srcs/docker-compose.yml stop

# Start inception
start:
	docker compose -f ./srcs/docker-compose.yml start

# Restart inception
restart: stop start

# Clean le projet (conteneurs + volumes docker)
clean:
	docker compose -f ./srcs/docker-compose.yml down -v

# Clean complet : conteneurs, images, volumes et donnees
fclean: clean
	docker system prune -af --volumes
	rm -rf $(DATA_PATH)/wordpress $(DATA_PATH)/mariadb

# Re build le projet
re: fclean all

# Regle phony
.PHONY: all stop start restart clean fclean re
