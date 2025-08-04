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

# 🚨 ÂNCORA: POSTGRES_CONFIG - Configuração do PostgreSQL
# Contexto: Usa DATABASE_URL do .env para conectar ao PostgreSQL no Docker
# Cuidado: Em produção, use connection pooling
# Dependências: PostgreSQL deve estar rodando e schemas criados
db_url = os.getenv("DATABASE_URL")
print(f"🗄️ Conectando ao PostgreSQL...")

# Criar storage para sessões do agente
try:
    agent_storage = PostgresStorage(
        table_name="agent_sessions",
        schema="agno",  # Usando schema agno
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
        schema="agno",  # Usando schema agno
        db_url=db_url,
    )

    memory = Memory(db=memory_db)
    print("✅ Memory storage configurado!")
except Exception as e:
    print(f"❌ Erro ao configurar memory: {e}")
    memory = None

# Criar o agente com storage
agent = Agent(
    name=os.getenv("AGENT_NAME", "secretaria_quiro"),
    model=OpenAIChat(id="gpt-4o-mini"),
    description="Você é uma secretária virtual prestativa e profissional de uma clínica de quiropraxia.",
    instructions=[
        "Responda de forma clara, objetiva e cordial",
        "Use linguagem profissional mas amigável",
        "Seja concisa nas respostas",
        "Lembre-se de informações importantes sobre os pacientes"
    ],
    markdown=True,
    storage=agent_storage,
    memory=memory,
    enable_user_memories=True,
    debug_mode=True,
    monitoring=True,
    #session_id="test_session_001"  # Para teste, usando ID fixo
)

# Criar playground
app = Playground(agents=[agent]).get_app()

if __name__ == "__main__":
    print("🚀 Iniciando Playground com PostgreSQL Storage!")
    print(f"📍 Acesse: http://localhost:7777")
    print(f"🧠 Memórias persistentes ativadas!")
    serve_playground_app("playground_with_storage:app", host="0.0.0.0", port=7777, reload=True)