DELETE FROM Alert_Logs;

INSERT INTO Alert_Logs (asteroid_spkid, priority_level, alert_message)
SELECT 
    a.spkid,
    CASE 
        -- Nível 4 - Vermelho (Crítica): PHAs grandes ou objetos > 1km
        WHEN a.pha_flag = 'Y' AND a.diameter > 1.0 THEN 'Critica'
        -- Nível 3 - Laranja (Alta): Restantes PHAs ou objetos > 0.4km
        WHEN a.pha_flag = 'Y' OR a.diameter > 0.4 THEN 'Alta'
        -- Nível 2 - Amarelo (Média): Objetos entre 0.1km e 0.4km
        WHEN a.diameter > 0.1 THEN 'Media'
        -- Nível 1 - Verde (Baixa): Tudo o resto abaixo de 0.1km
        ELSE 'Baixa'
    END,
    'Alerta NEO: Objeto de ' + CAST(ROUND(ISNULL(a.diameter,0), 2) AS VARCHAR) + ' km'
FROM Asteroid a
WHERE a.diameter > 0;
