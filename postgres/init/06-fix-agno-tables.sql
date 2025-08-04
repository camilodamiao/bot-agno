-- postgres/init/06-fix-agno-tables.sql
-- Adicionar colunas faltantes na tabela agent_sessions

-- Adicionar colunas que o Agno espera
ALTER TABLE agno.agent_sessions 
ADD COLUMN IF NOT EXISTS memory JSONB DEFAULT '{}',
ADD COLUMN IF NOT EXISTS session_data JSONB DEFAULT '{}',
ADD COLUMN IF NOT EXISTS extra_data JSONB DEFAULT '{}',
ADD COLUMN IF NOT EXISTS agent_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS team_session_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS agent_data JSONB DEFAULT '{}';

-- Adicionar índices para as novas colunas
CREATE INDEX IF NOT EXISTS idx_agent_sessions_agent_id ON agno.agent_sessions(agent_id);
CREATE INDEX IF NOT EXISTS idx_agent_sessions_team_session_id ON agno.agent_sessions(team_session_id);

-- 🚨 ÂNCORA: AGNO_SCHEMA - Estrutura esperada pelo PostgresStorage
-- Contexto: O Agno espera colunas específicas que não estavam na documentação
-- Cuidado: Sempre verificar schema com auto_upgrade_schema=True primeiro
-- Dependências: PostgresStorage do Agno requer estas colunas exatas