-include .env
export

.PHONY: db db-down migrate dbt-debug lint test

db:
	docker compose up -d

db-down:
	docker compose down

migrate:
	uv run alembic -c db/alembic.ini upgrade head

dbt-debug:
	uv run dbt debug --project-dir transform --profiles-dir transform

lint:
	uv run ruff check . && uv run ruff format --check .

test:
	uv run pytest
