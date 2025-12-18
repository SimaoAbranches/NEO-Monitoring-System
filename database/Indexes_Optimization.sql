USE [NEO_Monitoring_DB];
GO

-- 1. Índice para Pesquisa por Nome
-- Essencial porque os utilizadores vão pesquisar asteroides pelo nome no Python
CREATE INDEX IX_Asteroid_Name 
ON Asteroid (name);
GO

-- 2. Índice para o Diímetro
-- Como a tua View de estatísticas calcula médias e máximos, este índice acelera o processo
CREATE INDEX IX_Asteroid_Diameter 
ON Asteroid (diameter);
GO

-- 3. Índice Composto para Observações
-- Acelera a filtragem de quem observou o quê e em que data
CREATE INDEX IX_Observation_Astronomer_Date
ON Observation (astronomer_id, observation_date);
GO

-- 4. Índice para Chaves Estrangeiras
-- O SQL Server não cria automaticamente Índices para FKs. 
-- Isto acelera a View_Astronomer_Observation_Summary que criaste
CREATE INDEX IX_Observation_AsteroidID
ON Observation (asteroid_id);
GO
