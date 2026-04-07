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
