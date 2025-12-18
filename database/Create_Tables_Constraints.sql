-- CRIAÇÃO DE TABELAS E RESTRIÇÕES

USE [NEO_Monitoring_DB];
GO

-- 1: Tabela de astronomos (Entidade Observacional)
-- Permite saber quem fez a observação 
CREATE TABLE Astronomer (
    astronomery_id INT IDENTITY(1,1) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    affiliation VARCHAR(100)
);
GO

-- 2: Tabela de centros de observação (Observatories)
-- Localização e identificação dos centros 
CREATE TABLE Observatory (
    observatory_id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(10) UNIQUE, -- Código do observatório (ex: IAU code)
    name VARCHAR(100) NOT NULL,
    location_lat DECIMAL(9,6),
    location_long DECIMAL(9,6),
    country VARCHAR(50)
);
GO

-- 3: Tabela de equipamento
-- Telescópios ou sensores usados 
CREATE TABLE Equipment (
    equipment_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50), -- Ex: Ótico, Radar, Infravermelho
    observatory_id INT, -- Equipamento pertence a um observatório
    CONSTRAINT FK_Equipment_Observatory FOREIGN KEY (observatory_id) REFERENCES Observatory(observatory_id)
);
GO

-- 4: Tabela de Software
-- Software utilizado para calcular a órbita ou processar imagem 
CREATE TABLE Software (
    software_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    version VARCHAR(20),
    developer VARCHAR(50)
);
GO

-- 5: Tabela de asteroides (Entidade Central)
-- Contém os dados "estáticos" ou identificadores principais 
-- Dados físicos (diâmetro, H, albedo) 
CREATE TABLE Asteroid (
    asteroid_id INT IDENTITY(1,1) PRIMARY KEY,
    
    -- Identificadores Externos
    spkid VARCHAR(20) UNIQUE NOT NULL, -- ID da NASA
    pdes VARCHAR(20), -- Primary Designation
    full_name VARCHAR(100) NOT NULL,
    name VARCHAR(100),
    prefix VARCHAR(10),
    
    -- Flags de Classificação
    neo_flag CHAR(1) NOT NULL DEFAULT 'N' CHECK (neo_flag IN ('Y', 'N')), 
    pha_flag CHAR(1) NOT NULL DEFAULT 'N' CHECK (pha_flag IN ('Y', 'N')),
    
    -- Parâmetros Físicos 
    diameter DECIMAL(10,4), -- em km
    diameter_sigma DECIMAL(10,4), -- incerteza
    albedo DECIMAL(6,4) CHECK (albedo >= 0 AND albedo <= 1), -- refletividade 0-1
    H_mag DECIMAL(5,2), -- Magnitude absoluta
    
    -- Metadados de registo
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- 6: Tabela de dados orbitais (Natureza Temporal)
-- Um asteroide pode ter várias órbitas calculadas em épocas diferentes 
CREATE TABLE OrbitalData (
    orbit_id INT IDENTITY(1,1) PRIMARY KEY,
    asteroid_id INT NOT NULL,
    
    -- Identificação da Órbita
    orbit_designation VARCHAR(20), -- (orbit_id no CSV)
    epoch_mjd DECIMAL(12,2) NOT NULL, -- Data Juliana Modificada (referência temporal)
    epoch_cal DATETIME, -- Data calendário legível
    equinox VARCHAR(10), -- Ex: J2000 
    
    -- Elementos Keplerianos 
    e DECIMAL(10,8) NOT NULL CHECK (e >= 0), -- Excentricidade
    a DECIMAL(12,8) NOT NULL, -- Semieixo maior (UA)
    q DECIMAL(12,8) NOT NULL, -- Distância periélio (UA)
    i DECIMAL(10,6) NOT NULL, -- Inclinação (graus)
    om DECIMAL(10,6) NOT NULL, -- Longitude nodo ascendente
    w DECIMAL(10,6) NOT NULL, -- Argumento do periélio
    ma DECIMAL(10,6), -- Anomalia média
    tp DECIMAL(15,6), -- Tempo de periélio (JD)
    
    -- Métricas de Risco e Qualidade 
    moid_au DECIMAL(12,8), -- Min Orbit Intersection Dist (UA)
    moid_ld DECIMAL(12,8), -- Min Orbit Intersection Dist (Lunar Dist)
    rms DECIMAL(10,5), -- Root Mean Square (qualidade do ajuste)
    
    -- Incertezas (Sigmas)
    sigma_e DECIMAL(12,9),
    sigma_a DECIMAL(12,9),
    sigma_q DECIMAL(12,9),
    sigma_i DECIMAL(12,9),
    sigma_om DECIMAL(12,9),
    sigma_w DECIMAL(12,9),
    
    -- Classificação da Órbita
    orbit_class VARCHAR(10), -- Ex: AMO, APO, ATE 
    
    CONSTRAINT FK_Orbital_Asteroid FOREIGN KEY (asteroid_id) REFERENCES Asteroid(asteroid_id) ON DELETE CASCADE,
    -- Garante que não há dados duplicados para o mesmo asteroide na mesma época
    CONSTRAINT UQ_Asteroid_Epoch UNIQUE (asteroid_id, epoch_mjd)
);
GO

-- 7: Tabela de Observações
-- Regista o ato de observar, ligando astrónomo, equipamento e asteroide
CREATE TABLE Observation (
    observation_id INT IDENTITY(1,1) PRIMARY KEY,
    asteroid_id INT NOT NULL,
    observatory_id INT,
    astronomer_id INT,
    equipment_id INT,
    software_id INT,
    
    observation_date DATETIME NOT NULL,
    duration_minutes INT,
    observation_mode VARCHAR(20), -- Ex: CCD, Visual
    
    -- Ligações (Chaves Estrangeiras)
    CONSTRAINT FK_Obs_Asteroid FOREIGN KEY (asteroid_id) REFERENCES Asteroid(asteroid_id),
    CONSTRAINT FK_Obs_Observatory FOREIGN KEY (observatory_id) REFERENCES Observatory(observatory_id),
    CONSTRAINT FK_Obs_Astronomer FOREIGN KEY (astronomer_id) REFERENCES Astronomer(astronomer_id),
    CONSTRAINT FK_Obs_Equipment FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id),
    CONSTRAINT FK_Obs_Software FOREIGN KEY (software_id) REFERENCES Software(software_id)
);
GO

-- 8: Tabela de Alertas
-- Armazena os alertas gerados automaticamente pelos Triggers
CREATE TABLE Alert (
    alert_id INT IDENTITY(1,1) PRIMARY KEY,
    asteroid_id INT NOT NULL,
    
    -- Dados do Alerta
    alert_date DATETIME DEFAULT GETDATE(),
    alert_type VARCHAR(50), -- Ex: "Aproximação Iminente", "Novo PHA"
    priority_level VARCHAR(20) CHECK (priority_level IN ('Alta', 'Média', 'Baixa')), 
    torino_scale INT CHECK (torino_scale BETWEEN 0 AND 10), -- Escala de perigo (Adaptado dos níveis 1-4)
    color_code VARCHAR(10), -- 'Verde', 'Amarelo', 'Laranja', 'Vermelho'
    
    message VARCHAR(500),
    is_active BIT DEFAULT 1, -- Para gerir notificações ativas/inativas
    
    CONSTRAINT FK_Alert_Asteroid FOREIGN KEY (asteroid_id) REFERENCES Asteroid(asteroid_id)
);
GO

-- Criação de Índices para Performance 
CREATE INDEX IX_Asteroid_SPKID ON Asteroid(spkid);
CREATE INDEX IX_Orbital_MOID ON OrbitalData(moid_ld);
CREATE INDEX IX_Orbital_Epoch ON OrbitalData(epoch_mjd);
CREATE INDEX IX_Alert_Priority ON Alert(priority_level);
