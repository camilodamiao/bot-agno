-- postgres/init/05-chatwoot-tables.sql
-- Tabelas para integração com Chatwoot (handoff humano)

-- Tabela para controle de transferências bot->humano
CREATE TABLE IF NOT EXISTS chatwoot.handoff_sessions (
    id SERIAL PRIMARY KEY,
    conversation_id INTEGER REFERENCES business.conversations(id),
    contact_id INTEGER REFERENCES business.contacts(id),
    chatwoot_conversation_id INTEGER,
    reason VARCHAR(255), -- user_request, sentiment_negative, complex_query, etc
    transferred_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    transferred_by VARCHAR(50) DEFAULT 'bot', -- bot, agent, system
    returned_at TIMESTAMP WITH TIME ZONE,
    agent_email VARCHAR(255),
    agent_name VARCHAR(255),
    status VARCHAR(50) DEFAULT 'active', -- active, completed, abandoned
    notes TEXT,
    metadata JSONB DEFAULT '{}'
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_handoff_conversation ON chatwoot.handoff_sessions(conversation_id);
CREATE INDEX IF NOT EXISTS idx_handoff_status ON chatwoot.handoff_sessions(status);
CREATE INDEX IF NOT EXISTS idx_handoff_chatwoot_id ON chatwoot.handoff_sessions(chatwoot_conversation_id);

-- Tabela para mapear conversas entre bot e Chatwoot
CREATE TABLE IF NOT EXISTS chatwoot.bot_conversations (
    id SERIAL PRIMARY KEY,
    bot_session_id VARCHAR(255) NOT NULL,
    chatwoot_conversation_id INTEGER UNIQUE,
    chatwoot_contact_id INTEGER,
    inbox_id INTEGER,
    synced BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_bot_conversations_session ON chatwoot.bot_conversations(bot_session_id);
CREATE INDEX IF NOT EXISTS idx_bot_conversations_synced ON chatwoot.bot_conversations(synced);

-- Tabela para disponibilidade de agentes
CREATE TABLE IF NOT EXISTS chatwoot.agent_availability (
    id SERIAL PRIMARY KEY,
    agent_id INTEGER NOT NULL,
    agent_email VARCHAR(255),
    agent_name VARCHAR(255),
    available BOOLEAN DEFAULT false,
    max_conversations INTEGER DEFAULT 5,
    current_conversations INTEGER DEFAULT 0,
    last_seen TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_agent_availability_available ON chatwoot.agent_availability(available);
CREATE INDEX IF NOT EXISTS idx_agent_availability_email ON chatwoot.agent_availability(agent_email);

-- Triggers
CREATE TRIGGER update_bot_conversations_updated_at BEFORE UPDATE ON chatwoot.bot_conversations
    FOR EACH ROW EXECUTE FUNCTION agno.update_updated_at_column();

CREATE TRIGGER update_agent_availability_updated_at BEFORE UPDATE ON chatwoot.agent_availability
    FOR EACH ROW EXECUTE FUNCTION agno.update_updated_at_column();

-- 🚨 ÂNCORA: CHATWOOT_HANDOFF - Sistema de transferência bot->humano
-- Contexto: Quando bot detecta necessidade, cria handoff_session
-- Cuidado: Sempre verificar agent_availability antes de transferir
-- Dependências: Chatwoot API precisa estar configurada para sync funcionar