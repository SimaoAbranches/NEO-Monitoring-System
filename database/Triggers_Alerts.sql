USE [NEO_Monitoring_DB];
GO

-- Impede que se insiram observações com tempo negativo ou zero
CREATE OR ALTER TRIGGER trg_ValidateObservationDuration
ON Observation
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE duration_minutes <= 0)
    BEGIN
        RAISERROR ('Erro: A duração da observação deve ser positiva.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

