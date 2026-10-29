# Création de POSTGRESQL avec docker compose

version: '3.8'

services:

# Notre base de données PostgreSQL

postgres:
image: postgres:16-alpine
container_name: todo-postgres
restart: always
environment:
POSTGRES_USER: app_user
POSTGRES_PASSWORD: app_password
POSTGRES_DB: todo_db
ports: - "5432:5432"
volumes: - postgres_data:/var/lib/postgresql/data

# Notre API FastAPI

backend:
build:
context: .
dockerfile: Dockerfile
container_name: todo-backend
restart: always
ports: - "8000:8000"
environment: - DATABASE_URL=postgresql://app_user:app_password@postgres:5432/todo_db
depends_on: - postgres

volumes:
postgres_data:

# Tester l'environnement

    docker compose up --build -d
