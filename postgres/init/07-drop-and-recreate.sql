-- postgres/init/07-drop-and-recreate.sql
-- Dropar tabelas antigas e deixar o Agno recriar

-- Dropar tabelas existentes
DROP TABLE IF EXISTS agno.agent_sessions CASCADE;
DROP TABLE IF EXISTS agno.user_memories CASCADE;

-- 🚨 ÂNCORA: AGNO_AUTO_CREATE - Deixando o Agno criar as tabelas
-- Contexto: Nossa estrutura manual não é compatível com o que o Agno espera
-- Cuidado: Isso apaga todos os dados existentes
-- Dependências: Usar auto_upgrade_schema=True no código Python