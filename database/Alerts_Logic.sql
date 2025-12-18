USE [NEO_Monitoring_DB];
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Alert_Asteroid')
    ALTER TABLE Alert_Logs DROP CONSTRAINT FK_Alert_Asteroid;
GO

IF OBJECT_ID('Alert_Logs', 'U') IS NOT NULL 
    DROP TABLE Alert_Logs;
GO


CREATE TABLE Alert_Logs (
    alert_id INT PRIMARY KEY IDENTITY(1,1),
    asteroid_spkid VARCHAR(255), 
    priority_level VARCHAR(20), 
    alert_message VARCHAR(255),
    created_at DATETIME DEFAULT GETDATE(),
    is_active BIT DEFAULT 1
);
GO


DECLARE @length INT;
SELECT @length = character_maximum_length 
FROM information_schema.columns 
WHERE table_name = 'Asteroid' AND column_name = 'spkid';

DECLARE @sql NVARCHAR(MAX) = 'ALTER TABLE Alert_Logs ALTER COLUMN asteroid_spkid VARCHAR(' + CAST(@length AS VARCHAR) + ')';
EXEC sp_executesql @sql;

ALTER TABLE Alert_Logs 
ADD CONSTRAINT FK_Alert_Asteroid FOREIGN KEY (asteroid_spkid) REFERENCES Asteroid(spkid);
GO

CREATE OR ALTER PROCEDURE sp_GenerateAutomaticAlerts
AS
BEGIN

    INSERT INTO Alert_Logs (asteroid_spkid, priority_level, alert_message)
    SELECT spkid, 'Alta', 'ALERTA CRÍTICO: Objeto de grande porte detetado (D > 1km).'
    FROM Asteroid
    WHERE diameter > 1.0 
    AND NOT EXISTS (SELECT 1 FROM Alert_Logs WHERE Alert_Logs.asteroid_spkid = Asteroid.spkid);
    
    PRINT 'Alertas automáticos processados com sucesso!';
END;
GO
