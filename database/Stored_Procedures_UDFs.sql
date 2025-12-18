USE [NEO_Monitoring_DB];
GO

-- Procedimento para listar observações por astrónomo
CREATE OR ALTER PROCEDURE sp_GetObservationsByAstronomer
    @AstronomerID INT
AS
BEGIN
    SELECT observation_id, observation_date, duration_minutes, asteroid_id
    FROM Observation
    WHERE astronomer_id = @AstronomerID;
END;
GO

-- Função para classificar o tipo de observação
CREATE OR ALTER FUNCTION fn_ClassifyObservationDuration (@minutes INT)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @result VARCHAR(20);
    IF @minutes >= 60
        SET @result = 'Longa Duração';
    ELSE
        SET @result = 'Curta Duração';
    RETURN @result;
END;
GO

