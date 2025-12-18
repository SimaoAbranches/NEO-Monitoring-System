USE [NEO_Monitoring_DB];
GO

-- Índice para Pesquisa por Nome
CREATE INDEX IX_Asteroid_Name 
ON Asteroid (name);
GO

-- Índice para o Diímetro
CREATE INDEX IX_Asteroid_Diameter 
ON Asteroid (diameter);
GO

-- Índice Composto para Observações
CREATE INDEX IX_Observation_Astronomer_Date
ON Observation (astronomer_id, observation_date);
GO

-- Índice para Chaves Estrangeiras
CREATE INDEX IX_Observation_AsteroidID
ON Observation (asteroid_id);
GO
