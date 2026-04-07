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
