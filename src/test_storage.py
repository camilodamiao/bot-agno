from agno.agent import Agent
from agno.models.openai import OpenAIChat
from agno.storage.postgres import PostgresStorage
from dotenv import load_dotenv
import os

load_dotenv()

# Testar storage diretamente
db_url = os.getenv("DATABASE_URL")
storage = PostgresStorage(
    table_name="agent_sessions",
    schema="agno",
    db_url=db_url
)

# Criar agente com session_id fixo
agent = Agent(
    name="test_agent",
    model=OpenAIChat(id="gpt-4o-mini"),
    storage=storage,
    session_id="test_debug_001",
    add_history_to_messages=True
)

# Enviar mensagem
print("Enviando mensagem de teste...")
response = agent.run("Olá, me chamo João. Lembre-se do meu nome.")
print(f"Resposta: {response.content}")

# Verificar se salvou
print("\nVerificando sessão salva...")
sessions = agent.get_sessions()
print(f"Sessões encontradas: {len(sessions) if sessions else 0}")

# Testar recuperação
print("\nTestando nova instância do agente...")
agent2 = Agent(
    name="test_agent",
    model=OpenAIChat(id="gpt-4o-mini"),
    storage=storage,
    session_id="test_debug_001",
    add_history_to_messages=True
)
response2 = agent2.run("Qual é meu nome?")
print(f"Resposta: {response2.content}")