-- postgres/init/03-business-tables.sql
-- Tabelas para lógica de negócio

-- Tabela de contatos (usuários do WhatsApp)
CREATE TABLE IF NOT EXISTS business.contacts (
    id SERIAL PRIMARY KEY,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(255),
    email VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_interaction TIMESTAMP WITH TIME ZONE,
    tags TEXT[] DEFAULT '{}',
    metadata JSONB DEFAULT '{}',
    active BOOLEAN DEFAULT true
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_contacts_phone ON business.contacts(phone_number);
CREATE INDEX IF NOT EXISTS idx_contacts_active ON business.contacts(active);

-- Tabela de conversas
CREATE TABLE IF NOT EXISTS business.conversations (
    id SERIAL PRIMARY KEY,
    contact_id INTEGER REFERENCES business.contacts(id),
    session_id VARCHAR(255),
    channel VARCHAR(50) DEFAULT 'whatsapp',
    status VARCHAR(50) DEFAULT 'active', -- active, closed, transferred
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP WITH TIME ZONE,
    last_message_at TIMESTAMP WITH TIME ZONE,
    assigned_to VARCHAR(255), -- para handoff humano
    metadata JSONB DEFAULT '{}'
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_conversations_contact ON business.conversations(contact_id);
CREATE INDEX IF NOT EXISTS idx_conversations_status ON business.conversations(status);
CREATE INDEX IF NOT EXISTS idx_conversations_session ON business.conversations(session_id);

-- Tabela de mensagens
CREATE TABLE IF NOT EXISTS business.messages (
    id SERIAL PRIMARY KEY,
    conversation_id INTEGER REFERENCES business.conversations(id),
    contact_id INTEGER REFERENCES business.contacts(id),
    content TEXT NOT NULL,
    type VARCHAR(50) DEFAULT 'text', -- text, image, audio, video, document
    direction VARCHAR(10) NOT NULL, -- in, out
    status VARCHAR(50), -- sent, delivered, read, failed
    external_id VARCHAR(255), -- ID do Evolution/WhatsApp
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON business.messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_contact ON business.messages(contact_id);
CREATE INDEX IF NOT EXISTS idx_messages_external_id ON business.messages(external_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON business.messages(created_at);

-- Triggers para updated_at
CREATE TRIGGER update_contacts_updated_at BEFORE UPDATE ON business.contacts
    FOR EACH ROW EXECUTE FUNCTION agno.update_updated_at_column();

-- 🚨 ÂNCORA: BUSINESS_LOGIC - Estrutura de conversas
-- Contexto: Uma conversation agrupa várias messages de um contact
-- Cuidado: conversation_id é obrigatório em messages
-- Dependências: Evolution API precisa criar contact antes de enviar messages