-- postgres/init/04-evolution-tables.sql
-- Tabelas para Evolution API

-- Tabela para logs de webhooks recebidos
CREATE TABLE IF NOT EXISTS evolution.webhook_logs (
    id SERIAL PRIMARY KEY,
    event_type VARCHAR(100) NOT NULL, -- message.create, message.update, etc
    instance_name VARCHAR(100),
    remote_jid VARCHAR(255), -- número do WhatsApp
    message_id VARCHAR(255),
    payload JSONB NOT NULL, -- payload completo do webhook
    processed BOOLEAN DEFAULT false,
    processed_at TIMESTAMP WITH TIME ZONE,
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_webhook_logs_event_type ON evolution.webhook_logs(event_type);
CREATE INDEX IF NOT EXISTS idx_webhook_logs_processed ON evolution.webhook_logs(processed);
CREATE INDEX IF NOT EXISTS idx_webhook_logs_message_id ON evolution.webhook_logs(message_id);
CREATE INDEX IF NOT EXISTS idx_webhook_logs_created_at ON evolution.webhook_logs(created_at);

-- Tabela para fila de mensagens a enviar
CREATE TABLE IF NOT EXISTS evolution.message_queue (
    id SERIAL PRIMARY KEY,
    instance_name VARCHAR(100) NOT NULL,
    to_number VARCHAR(255) NOT NULL,
    message_type VARCHAR(50) DEFAULT 'text', -- text, image, audio, etc
    content TEXT,
    media_url TEXT,
    options JSONB DEFAULT '{}', -- opções extras do Evolution
    priority INTEGER DEFAULT 5, -- 1-10, menor = mais prioritário
    status VARCHAR(50) DEFAULT 'pending', -- pending, processing, sent, failed
    attempts INTEGER DEFAULT 0,
    max_attempts INTEGER DEFAULT 3,
    sent_at TIMESTAMP WITH TIME ZONE,
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    scheduled_for TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_message_queue_status ON evolution.message_queue(status);
CREATE INDEX IF NOT EXISTS idx_message_queue_priority ON evolution.message_queue(priority);
CREATE INDEX IF NOT EXISTS idx_message_queue_scheduled ON evolution.message_queue(scheduled_for);

-- Tabela para instâncias do Evolution
CREATE TABLE IF NOT EXISTS evolution.instances (
    id SERIAL PRIMARY KEY,
    instance_name VARCHAR(100) UNIQUE NOT NULL,
    api_key VARCHAR(255),
    webhook_url VARCHAR(500),
    status VARCHAR(50) DEFAULT 'disconnected', -- connected, disconnected, qr_code
    phone_number VARCHAR(20),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Trigger para updated_at
CREATE TRIGGER update_instances_updated_at BEFORE UPDATE ON evolution.instances
    FOR EACH ROW EXECUTE FUNCTION agno.update_updated_at_column();

-- 🚨 ÂNCORA: EVOLUTION_QUEUE - Sistema de fila de mensagens
-- Contexto: Mensagens são enfileiradas antes de enviar para controle de rate limit
-- Cuidado: Sempre verificar status antes de reprocessar
-- Dependências: Worker precisa processar esta fila periodicamente