from agno.agent import Agent
from agno.models.openai import OpenAIChat
from agno.playground import Playground, serve_playground_app
from agno.storage.postgres import PostgresStorage
from agno.memory.v2.memory import Memory
from agno.memory.v2.db.postgres import PostgresMemoryDb
from dotenv import load_dotenv
import os

# Carregar variáveis
load_dotenv()

# 🚨 ÂNCORA: AGENT_ID_FIXO - Mantém consistência entre reinicializações
# Contexto: Sem ID fixo, cada restart cria novo agent_id e perde sessões anteriores
# Cuidado: Em produção, cada cliente deve ter seu próprio agent_id
# Dependências: Playground filtra sessões por agent_id
FIXED_AGENT_ID = "secretaria-quiro-001"

db_url = os.getenv("DATABASE_URL")
print(f"🗄️ Conectando ao PostgreSQL...")

# Criar storage para sessões do agente
try:
    agent_storage = PostgresStorage(
        table_name="agent_sessions",
        schema="agno",
        db_url=db_url,
        auto_upgrade_schema=True
    )
    print("✅ Storage do agente configurado!")
except Exception as e:
    print(f"❌ Erro ao configurar storage: {e}")
    agent_storage = None

# Criar storage para memórias
try:
    memory_db = PostgresMemoryDb(
        table_name="user_memories",
        schema="agno",
        db_url=db_url
    )
    memory = Memory(db=memory_db)
    print("✅ Memory storage configurado!")
except Exception as e:
    print(f"❌ Erro ao configurar memory: {e}")
    memory = None

# Criar o agente com storage e ID FIXO
agent = Agent(
    name=os.getenv("AGENT_NAME", "secretaria_quiro"),
    agent_id=FIXED_AGENT_ID,  # IMPORTANTE: ID fixo!
    model=OpenAIChat(id="gpt-4o-mini"),
    description="Você é uma secretária virtual prestativa e profissional de uma clínica de quiropraxia.",
    instructions=[
        "Responda de forma clara, objetiva e cordial",
        "Use linguagem profissional mas amigável",
        "Seja concisa nas respostas",
        "Lembre-se de informações importantes sobre os pacientes"
    ],
    tools=[],
    show_tool_calls=True,
    markdown=True,
    storage=agent_storage,
    memory=memory,
    enable_user_memories=True,
    add_history_to_messages=True,
    debug_mode=True,
    monitoring=True,
    num_history_runs=10
)

print(f"🤖 Agent ID: {agent.agent_id}")

# Criar playground
app = Playground(agents=[agent]).get_app()

if __name__ == "__main__":
    print("🚀 Iniciando Playground com PostgreSQL Storage!")
    print(f"📍 Acesse: http://localhost:7777")
    print(f"🆔 Agent ID fixo: {FIXED_AGENT_ID}")
    print(f"🧠 Memórias persistentes ativadas!")
    serve_playground_app("playground_with_storage:app", host="0.0.0.0", port=7777, reload=True)