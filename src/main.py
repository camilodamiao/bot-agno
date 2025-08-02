import os
from fastapi import FastAPI
from pydantic import BaseModel
from agno.agent import Agent  # Import correto!
from agno.models.openai import OpenAIChat  # Modelo OpenAI
from dotenv import load_dotenv

# Carregar variáveis de ambiente
load_dotenv()

# Criar app FastAPI
app = FastAPI(title="Bot Agno")

# Criar agente Agno
agent = Agent(
    model=OpenAIChat(id="gpt-4o-mini"),
    description=f"Você é {os.getenv('AGENT_NAME', 'assistente')} - uma secretária virtual prestativa e profissional.",
    instructions=[
        "Responda de forma clara, objetiva e cordial",
        "Use linguagem profissional mas amigável",
        "Seja concisa nas respostas"
    ],
    markdown=True
)

# Modelo para requisições
class Message(BaseModel):
    text: str
    session_id: str = "default"

# Rota de health check
@app.get("/")
def health():
    return {"status": "ok", "bot": os.getenv("BOT_NAME")}

# Rota principal do chat
@app.post("/chat")
async def chat(message: Message):
    response = agent.run(message.text)
    return {"response": response.content}