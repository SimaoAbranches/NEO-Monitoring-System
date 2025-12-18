USE [NEO_Monitoring_DB];
GO

-- 1. Criar um Login para a Aplicação Python (Nível de Servidor)
-- Nota: 'AppPassword123' deve ser trocada por uma segura
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'NEO_App_User')
BEGIN
    CREATE LOGIN NEO_App_User WITH PASSWORD = 'AppPassword123';
END
GO

-- 2. Criar um Utilizador na Base de Dados para esse Login
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'NEO_App_User')
BEGIN
    CREATE USER NEO_App_User FOR LOGIN NEO_App_User;
END
GO

-- 3. Definir Permissões (DCL - Data Control Language)
-- O utilizador da App só pode ler dados e executar procedimentos
GRANT SELECT ON SCHEMA::dbo TO NEO_App_User;
GRANT EXECUTE ON SCHEMA::dbo TO NEO_App_User;

-- Impedir explicitamente que o utilizador da App apague tabelas (Segurança extra)
DENY ALTER ON SCHEMA::dbo TO NEO_App_User;
GO

-- 4. Criar um Papel (Role) para os Colegas de Grupo (Administradores)
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Group_Admins' AND type = 'R')
BEGIN
    CREATE ROLE Group_Admins;
END
GO

-- Dar permissões totais aos Admins
GRANT CONTROL TO Group_Admins;
GO
