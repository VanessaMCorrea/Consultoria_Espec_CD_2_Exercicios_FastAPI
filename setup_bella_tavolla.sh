#!/usr/bin/env bash
set -e

echo "==> Criando ambiente virtual"
python3 -m venv .venv

echo "==> Ativando ambiente virtual"
source .venv/bin/activate

echo "==> Atualizando pip"
pip install --upgrade pip

echo "==> Instalando dependências"
pip install fastapi uvicorn[standard] pydantic pytest requests

echo "==> Salvando requirements.txt"
pip freeze > requirements.txt

echo "==> Criando estrutura de diretórios"
mkdir -p .github/workflows
mkdir -p app
mkdir -p data
mkdir -p scripts
mkdir -p tests

echo "==> Criando arquivos base"
touch app/__init__.py
touch app/main.py
touch app/schemas.py
touch app/data.py
touch scripts/gerar_dados_sinteticos.py
touch tests/test_health.py
touch .github/workflows/ci.yml
touch .gitignore
touch Dockerfile
touch README.md

echo "==> Escrevendo .gitignore"
cat > .gitignore << 'EOF'
.venv/
__pycache__/
*.pyc
.ipynb_checkpoints/
.env
EOF

echo "==> Escrevendo app/schemas.py"
cat > app/schemas.py << 'EOF'
from pydantic import BaseModel


class Prato(BaseModel):
    id: int
    nome: str
    categoria: str
    preco: float
    disponivel: bool


class PratoCreate(BaseModel):
    nome: str
    categoria: str
    preco: float
    disponivel: bool = True
EOF

echo "==> Escrevendo app/data.py"
cat > app/data.py << 'EOF'
pratos = [
    {"id": 1, "nome": "Margherita", "categoria": "pizza", "preco": 45.0, "disponivel": True},
    {"id": 2, "nome": "Calabresa", "categoria": "pizza", "preco": 52.0, "disponivel": True},
    {"id": 3, "nome": "4 Queijos", "categoria": "pizza", "preco": 62.0, "disponivel": False},
    {"id": 4, "nome": "Frango com Catupiry", "categoria": "pizza", "preco": 65.0, "disponivel": True},
    {"id": 5, "nome": "Tiramisù", "categoria": "sobremesa", "preco": 25.0, "disponivel": True},
]
EOF

echo "==> Escrevendo app/main.py"
cat > app/main.py << 'EOF'
from typing import Optional
from fastapi import FastAPI, HTTPException

from app.schemas import Prato, PratoCreate
from app.data import pratos

app = FastAPI(
    title="Bella Tavolla API",
    description="API do restaurante Bella Tavolla",
    version="1.0.0"
)

@app.get("/")
def root():
    return {
        "restaurante": "Bella Tavolla",
        "mensagem": "Bem-vindo à API da Bella Tavolla"
    }

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/pratos", response_model=list[Prato])
def listar_pratos(
    categoria: Optional[str] = None,
    preco_maximo: Optional[float] = None,
    apenas_disponiveis: bool = False
):
    resultado = pratos

    if categoria:
        resultado = [p for p in resultado if p["categoria"].lower() == categoria.lower()]

    if preco_maximo is not None:
        resultado = [p for p in resultado if p["preco"] <= preco_maximo]

    if apenas_disponiveis:
        resultado = [p for p in resultado if p["disponivel"]]

    return resultado

@app.get("/pratos/{prato_id}", response_model=Prato)
def buscar_prato(prato_id: int):
    for prato in pratos:
        if prato["id"] == prato_id:
            return prato
    raise HTTPException(status_code=404, detail="Prato não encontrado")

@app.post("/pratos", response_model=Prato, status_code=201)
def adicionar_prato(payload: PratoCreate):
    novo_id = max([p["id"] for p in pratos], default=0) + 1
    novo_prato = {"id": novo_id, **payload.model_dump()}
    pratos.append(novo_prato)
    return novo_prato
EOF

echo "==> Escrevendo script de dados sintéticos"
cat > scripts/gerar_dados_sinteticos.py << 'EOF'
import csv
import os

dados = [
    {"id": 1, "nome": "Margherita", "categoria": "pizza", "preco": 45.0, "disponivel": True},
    {"id": 2, "nome": "Calabresa", "categoria": "pizza", "preco": 52.0, "disponivel": True},
    {"id": 3, "nome": "4 Queijos", "categoria": "pizza", "preco": 62.0, "disponivel": False},
    {"id": 4, "nome": "Frango com Catupiry", "categoria": "pizza", "preco": 65.0, "disponivel": True},
    {"id": 5, "nome": "Tiramisù", "categoria": "sobremesa", "preco": 25.0, "disponivel": True},
    {"id": 6, "nome": "Lasanha Bolonhesa", "categoria": "massa", "preco": 48.0, "disponivel": True},
    {"id": 7, "nome": "Ravioli de Ricota", "categoria": "massa", "preco": 54.0, "disponivel": False},
]

os.makedirs("data", exist_ok=True)

with open("data/pratos.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=["id", "nome", "categoria", "preco", "disponivel"])
    writer.writeheader()
    writer.writerows(dados)

print("Arquivo data/pratos.csv gerado com sucesso.")
EOF

echo "==> Gerando data/pratos.csv"
python scripts/gerar_dados_sinteticos.py

echo "==> Escrevendo teste"
cat > tests/test_health.py << 'EOF'
import requests

def test_health():
    response = requests.get("http://localhost:8000/health")
    assert response.status_code == 200
EOF

echo "==> Escrevendo workflow CI"
cat > .github/workflows/ci.yml << 'EOF'
name: CI - Bella Tavolla API

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  verificar-api:
    runs-on: ubuntu-latest

    steps:
      - name: Baixar o código
        uses: actions/checkout@v4

      - name: Configurar Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"

      - name: Instalar dependências
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt

      - name: Iniciar API em background
        run: |
          uvicorn app.main:app --host 0.0.0.0 --port 8000 &
          sleep 8

      - name: Verificar healthcheck
        run: |
          curl --fail http://localhost:8000/health

      - name: Rodar testes
        run: |
          pytest tests/ -v --tb=short
EOF

echo "==> Escrevendo Dockerfile"
cat > Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app
COPY scripts ./scripts
COPY data ./data
COPY tests ./tests

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

echo "==> Escrevendo README"
cat > README.md << 'EOF'
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