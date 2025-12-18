USE [NEO_Monitoring_DB];
GO

CREATE OR ALTER VIEW View_Astronomer_Observation_Summary AS
SELECT
    A.full_name AS Astronomer_Name,
    O.name AS Observatory_Name,
    AST.name AS Asteroid_Observed,
    OBS.observation_date
FROM Observation OBS
JOIN Astronomer A ON OBS.astronomer_id = A.astronomer_id
JOIN Observatory O ON OBS.observatory_id = O.observatory_id

JOIN Asteroid AST ON OBS.asteroid_id = AST.spkid;
GO

-- View para Lista Geral de Asteroides
CREATE OR ALTER VIEW View_Asteroid_Inventory AS
SELECT
    spkid,
    name,
    full_name,
    diameter
FROM Asteroid;
GO
