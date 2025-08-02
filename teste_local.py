from agno.agent import Agent
from agno.models.openai import OpenAIChat
from agno.playground import Playground, serve_playground_app
from dotenv import load_dotenv
import os

# Carregar .env
load_dotenv()

# Verificar API key
if not os.getenv("OPENAI_API_KEY"):
    print("❌ Configure OPENAI_API_KEY no .env!")
    exit(1)

print(f"✅ API Key encontrada: {os.getenv('OPENAI_API_KEY')[:10]}...")

# Criar agente simples
agent = Agent(
    name="teste_local",
    model=OpenAIChat(id="gpt-4o-mini"),
    description="Assistente de teste",
    markdown=True
)

# Criar playground
app = Playground(agents=[agent]).get_app()

if __name__ == "__main__":
    print("🚀 Iniciando Playground LOCAL em http://localhost:7777")
    serve_playground_app("teste_local:app", reload=True)