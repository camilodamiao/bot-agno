FROM python:3.13-slim

# Diretório de trabalho dentro do container
WORKDIR /app

# Copiar requirements e instalar dependências
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código fonte
COPY . .

# Porta para o Playground conectar
EXPOSE 8000 7777

# Comando para iniciar o bot
## CMD ["python", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]

# Comando que mantém container rodando sem fazer nada
CMD ["tail", "-f", "/dev/null"]