LOGIN ?= nkhamich
export LOGIN

PROJECT_DIR := srcs
COMPOSE := docker compose --project-directory $(PROJECT_DIR)

DATA_DIR := /home/$(LOGIN)/data

all: dirs secrets
	$(COMPOSE) up --build -d

dirs:
	@mkdir -p $(DATA_DIR)/wordpress $(DATA_DIR)/mysql

secrets:
	@SECRETS_DIR=$(CURDIR)/secrets bash $(PROJECT_DIR)/requirements/tools/generate_secrets.sh

down:
	$(COMPOSE) down

clean: down

fclean:
	$(COMPOSE) down -v --rmi all
	@rm -f secrets/*.txt
	@rm -f secrets/certificate/*.pem

re: fclean all

logs:
	$(COMPOSE) logs -f

.PHONY: all dirs secrets down clean fclean re logs
