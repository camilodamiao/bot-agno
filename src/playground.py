from agno.agent import Agent
from agno.models.openai import OpenAIChat
from agno.playground import Playground, serve_playground_app
from dotenv import load_dotenv
import os

# Carregar variáveis
load_dotenv()

# Criar o agente
agent = Agent(
    name=os.getenv("AGENT_NAME"),
    model=OpenAIChat(id="gpt-4o-mini"),
    description="Você é uma secretária virtual prestativa e profissional.",
    instructions=[
        "Responda de forma clara, objetiva e cordial",
        "Use linguagem profissional mas amigável", 
        "Seja concisa nas respostas"
    ],
    markdown=True,
    monitoring=True,
    debug_mode=True
    )

# Criar playground
app = Playground(agents=[agent]).get_app()

if __name__ == "__main__":
    serve_playground_app("playground:app", host="0.0.0.0", port=7777, reload=True)