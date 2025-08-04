from agno.agent import Agent
from agno.models.openai import OpenAIChat
from agno.storage.postgres import PostgresStorage
from dotenv import load_dotenv
import os
from datetime import datetime

load_dotenv()

db_url = os.getenv("DATABASE_URL")

# Criar storage
storage = PostgresStorage(
    table_name="agent_sessions",
    schema="agno",
    db_url=db_url,
    auto_upgrade_schema=True
)

# Criar agente temporário
agent = Agent(
    name="debug_agent",
    model=OpenAIChat(id="gpt-4o-mini"),
    storage=storage
)

print("🔍 Testando métodos do Storage...\n")

# Tentar listar sessões
try:
    # Verificar métodos disponíveis
    print("📋 Métodos disponíveis no storage:")
    methods = [m for m in dir(storage) if not m.startswith('_') and callable(getattr(storage, m))]
    for m in methods:
        print(f"  - {m}")
    
    print("\n📊 Tentando recuperar sessões...")
    
    # Tentar diferentes métodos
    if hasattr(storage, 'get_sessions'):
        sessions = storage.get_sessions()
        print(f"✅ get_sessions() retornou: {len(sessions) if sessions else 0} sessões")
    
    if hasattr(storage, 'list_sessions'):
        sessions = storage.list_sessions()
        print(f"✅ list_sessions() retornou: {len(sessions) if sessions else 0} sessões")
        
    if hasattr(storage, 'get_all_sessions'):
        sessions = storage.get_all_sessions()
        print(f"✅ get_all_sessions() retornou: {len(sessions) if sessions else 0} sessões")
        
    # Tentar com user_id específico
    user_id = "camilo.damiao_0a8d"
    if hasattr(storage, 'get_sessions_for_user'):
        sessions = storage.get_sessions_for_user(user_id)
        print(f"✅ get_sessions_for_user('{user_id}') retornou: {len(sessions) if sessions else 0} sessões")
        
except Exception as e:
    print(f"❌ Erro: {type(e).__name__}: {e}")
    import traceback
    traceback.print_exc()

# Verificar estrutura dos dados
print("\n🔍 Verificando estrutura dos dados no banco...")
try:
    # Acessar diretamente via SQLAlchemy
    from sqlalchemy import create_engine, text
    
    engine = create_engine(db_url)
    with engine.connect() as conn:
        result = conn.execute(text("""
            SELECT session_id, user_id, 
                   to_timestamp(created_at) as created_timestamp,
                   created_at as created_unix
            FROM agno.agent_sessions 
            ORDER BY created_at DESC 
            LIMIT 2
        """))
        
        print("📅 Timestamps no banco:")
        for row in result:
            print(f"  Session: {row[0][:20]}...")
            print(f"  Unix: {row[3]} -> {datetime.fromtimestamp(row[3])}")
            print()
            
except Exception as e:
    print(f"❌ Erro SQL: {e}")