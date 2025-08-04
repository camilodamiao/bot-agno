-- postgres/init/01-create-schemas.sql
-- Criar schemas separados para cada contexto

-- Schema para o Agno Framework (sessões e memórias)
CREATE SCHEMA IF NOT EXISTS agno;
COMMENT ON SCHEMA agno IS 'Schema para dados do Agno Framework - sessões e memórias';

-- Schema para lógica de negócio
CREATE SCHEMA IF NOT EXISTS business;
COMMENT ON SCHEMA business IS 'Schema para dados de negócio - contatos, conversas, mensagens';

-- Schema para Evolution API
CREATE SCHEMA IF NOT EXISTS evolution;
COMMENT ON SCHEMA evolution IS 'Schema para webhooks e filas do Evolution API';

-- Schema para Chatwoot (preparado para futuro)
CREATE SCHEMA IF NOT EXISTS chatwoot;
COMMENT ON SCHEMA chatwoot IS 'Schema para integração com Chatwoot - handoff e atendimento humano';

-- Garantir permissões
GRANT ALL ON SCHEMA agno TO agno_user;
GRANT ALL ON SCHEMA business TO agno_user;
GRANT ALL ON SCHEMA evolution TO agno_user;
GRANT ALL ON SCHEMA chatwoot TO agno_user;