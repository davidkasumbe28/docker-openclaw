
.PHONY: install up down restart logs status backup restore verify validate

install:
	bash scripts/install.sh

up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose restart openclaw-gateway

logs:
	docker compose logs -f openclaw-gateway

status:
	docker compose ps

backup:
	bash scripts/backup.sh

restore:
	bash scripts/restore.sh

verify:
	bash scripts/verify.sh

validate:
	docker compose config --quiet
