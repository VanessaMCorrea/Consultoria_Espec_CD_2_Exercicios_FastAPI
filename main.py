from fastapi import FastAPI
from typing import Optional

app = FastAPI(
    title="Bella Tavola API",
    description="API do restaurante Bella Tavola",
    version="1.0.0"
)

@app.get("/")
async def root():
    return {
        "restaurante": "Bella Tavola",
        "mensagem": "Bem-vindo à nossa API",
        "chef": "Vanessa Correa",
        "cidade": "São Paulo",
        "especialidade": "Pizza"
    }

pratos = [
    {"id": 1, "nome": "Margherita", "categoria": "pizza", "preco": 45.0, "disponivel": True},
    {"id": 2, "nome": "Calabresa", "categoria": "pizza", "preco": 52.0, "disponivel": True},
    {"id": 3, "nome": "4 Queijos", "categoria": "pizza", "preco": 62.0, "disponivel": False},
    {"id": 4, "nome": "Frango Catupiry", "categoria": "pizza", "preco": 65.0, "disponivel": True},
    {"id": 4, "nome": "Tiramissú", "categoria": "sobremesa", "preco": 25.0, "disponivel": True},
]

@app.get("/pratos/{prato_id}")
async def buscar_prato(prato_id: int, formato: str= "completo"):
    for prato in pratos:
        if prato["id"] == prato_id:
            if formato == "resumido":
                return {"nome": prato["nome"], "preco": prato["preco"]}
            return prato
        return {"mensagem": "Prato não encontrado"}

@app.get("/pratos")
async def listar_pratos(
    categoria: Optional[str] = None, 
    preco_maximo: Optional[float] = None,
    apenas_disponiveis: bool = False
):
    resultado = pratos

    if categoria:
        resultado = [p for p in resultado if p["categoria"] == categoria]
    if preco_maximo:
        resultado = [p for p in resultado if p["preco"] <= preco_maximo]
    if apenas_disponiveis:
        resultado = [p for p in resultado if p["disponivel"]]
    return resultado

