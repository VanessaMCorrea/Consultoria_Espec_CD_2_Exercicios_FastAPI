# Bella Tavolla API

API do restaurante Bella Tavolla desenvolvida com FastAPI.

## Rotas principais

- GET /
- GET /health
- GET /pratos
- GET /pratos/{prato_id}
- POST /pratos

## Rodar localmente

```bash
source .venv/bin/activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
