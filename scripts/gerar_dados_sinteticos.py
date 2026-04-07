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
