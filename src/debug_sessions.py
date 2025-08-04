import psycopg2
from dotenv import load_dotenv
import os
from datetime import datetime

load_dotenv()

# Conectar direto no PostgreSQL
conn_string = os.getenv("DATABASE_URL")
conn = psycopg2.connect(conn_string)
cur = conn.cursor()

print("🔍 Verificando dados no PostgreSQL...\n")

# Contar registros
cur.execute("SELECT COUNT(*) FROM agno.agent_sessions")
session_count = cur.fetchone()[0]
print(f"📋 Total de sessões: {session_count}")

cur.execute("SELECT COUNT(*) FROM agno.user_memories")
memory_count = cur.fetchone()[0]
print(f"🧠 Total de memórias: {memory_count}")

# Ver estrutura das tabelas
print("\n📊 Estrutura da tabela agent_sessions:")
cur.execute("""
    SELECT column_name, data_type 
    FROM information_schema.columns 
    WHERE table_schema = 'agno' AND table_name = 'agent_sessions'
    ORDER BY ordinal_position
""")
for col in cur.fetchall():
    print(f"  - {col[0]}: {col[1]}")

# Ver agent_ids únicos
print("\n🔍 Agent IDs encontrados:")
cur.execute("SELECT DISTINCT agent_id FROM agno.agent_sessions WHERE agent_id IS NOT NULL")
agent_ids = cur.fetchall()
for aid in agent_ids:
    print(f"  - {aid[0]}")

# Ver user_ids únicos
print("\n👤 User IDs encontrados:")
cur.execute("SELECT DISTINCT user_id FROM agno.agent_sessions WHERE user_id IS NOT NULL")
user_ids = cur.fetchall()
for uid in user_ids:
    print(f"  - {uid[0]}")

cur.close()
conn.close()

print("\n✅ Debug concluído!")