PROJECT_NAME=LangRace
COMPOSE_FILE=docker-compose.yml

# Default goal
.DEFAULT_GOAL := help

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  up         - Run containers"
	@echo "  down       - Stop containers"
	@echo "  rebuild    - Rebuild containers without cache"
	@echo "  ps         - List running containers"
	@echo "  clean      - Remove containers, volumes, and prune system"
	@echo "  benchmark  - Run benchmark tests against the services"

up:
	@docker compose -f $(COMPOSE_FILE) up --build -d
	@echo "Containers started! Use 'make benchmark' to test."

down:
	@docker compose -f $(COMPOSE_FILE) down

rebuild:
	@docker compose -f $(COMPOSE_FILE) build --no-cache

ps:
	@docker compose -f $(COMPOSE_FILE) ps

clean:
	@docker compose -f $(COMPOSE_FILE) down -v --remove-orphans
	@docker system prune -f
	@echo "All containers, volumes removed and system pruned."

benchmark:
	@bash scripts/benchmark.sh

