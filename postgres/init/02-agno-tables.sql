-- postgres/init/02-agno-tables.sql
-- Tabelas para o Agno Framework

-- Tabela para armazenar sessões do agente
CREATE TABLE IF NOT EXISTS agno.agent_sessions (
    session_id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255),
    agent_name VARCHAR(255),
    model VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}',
    messages JSONB DEFAULT '[]'
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_agent_sessions_user_id ON agno.agent_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_agent_sessions_created_at ON agno.agent_sessions(created_at);

-- Tabela para memórias de usuário (Memory v2)
CREATE TABLE IF NOT EXISTS agno.user_memories (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    memory_id VARCHAR(255) UNIQUE NOT NULL,
    memory TEXT NOT NULL,
    topics TEXT[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_user_memories_user_id ON agno.user_memories(user_id);
CREATE INDEX IF NOT EXISTS idx_user_memories_memory_id ON agno.user_memories(memory_id);
CREATE INDEX IF NOT EXISTS idx_user_memories_topics ON agno.user_memories USING GIN(topics);

-- Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION agno.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_agent_sessions_updated_at BEFORE UPDATE ON agno.agent_sessions
    FOR EACH ROW EXECUTE FUNCTION agno.update_updated_at_column();

CREATE TRIGGER update_user_memories_updated_at BEFORE UPDATE ON agno.user_memories
    FOR EACH ROW EXECUTE FUNCTION agno.update_updated_at_column();