-- CRIAÇÃO DE TABELAS E RESTRIÇÕES

USE [NEO_Monitoring_DB];
GO


CREATE TABLE Astronomer (
    astronomery_id INT IDENTITY(1,1) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    affiliation VARCHAR(100)
);
GO


CREATE TABLE Observatory (
    observatory_id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(10) UNIQUE, 
    name VARCHAR(100) NOT NULL,
    location_lat DECIMAL(9,6),
    location_long DECIMAL(9,6),
    country VARCHAR(50)
);
GO


CREATE TABLE Equipment (
    equipment_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50), 
    observatory_id INT, 
    CONSTRAINT FK_Equipment_Observatory FOREIGN KEY (observatory_id) REFERENCES Observatory(observatory_id)
);
GO

    
CREATE TABLE Software (
    software_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    version VARCHAR(20),
    developer VARCHAR(50)
);
GO


CREATE TABLE Asteroid (
    asteroid_id INT IDENTITY(1,1) PRIMARY KEY,
    

    spkid VARCHAR(20) UNIQUE NOT NULL, 
    pdes VARCHAR(20), 
    full_name VARCHAR(100) NOT NULL,
    name VARCHAR(100),
    prefix VARCHAR(10),
    
    -- Flags de classificações 
    neo_flag CHAR(1) NOT NULL DEFAULT 'N' CHECK (neo_flag IN ('Y', 'N')), 
    pha_flag CHAR(1) NOT NULL DEFAULT 'N' CHECK (pha_flag IN ('Y', 'N')),
    
    -- Parâmetros Físicos 
    diameter DECIMAL(10,4), -- em km
    diameter_sigma DECIMAL(10,4), -- incerteza
    albedo DECIMAL(6,4) CHECK (albedo >= 0 AND albedo <= 1), -- refletividade 0-1
    H_mag DECIMAL(5,2), -- Magnitude absoluta
    
    -- Data de registo
    created_at DATETIME DEFAULT GETDATE()
);
GO


CREATE TABLE OrbitalData (
    orbit_id INT IDENTITY(1,1) PRIMARY KEY,
    asteroid_id INT NOT NULL,
    
    -- Identificação da Órbita
    orbit_designation VARCHAR(20), )
    epoch_mjd DECIMAL(12,2) NOT NULL, 
    epoch_cal DATETIME, 
    equinox VARCHAR(10), 
    
    -- Elementos Keplerianos 
    e DECIMAL(10,8) NOT NULL CHECK (e >= 0), 
    a DECIMAL(12,8) NOT NULL, 
    q DECIMAL(12,8) NOT NULL, 
    i DECIMAL(10,6) NOT NULL, 
    om DECIMAL(10,6) NOT NULL, 
    w DECIMAL(10,6) NOT NULL, 
    ma DECIMAL(10,6), 
    tp DECIMAL(15,6), 
    
    -- Métricas de Risco e Qualidade 
    moid_au DECIMAL(12,8), 
    moid_ld DECIMAL(12,8), 
    rms DECIMAL(10,5), 
    
    -- Incertezas (Sigmas)
    sigma_e DECIMAL(12,9),
    sigma_a DECIMAL(12,9),
    sigma_q DECIMAL(12,9),
    sigma_i DECIMAL(12,9),
    sigma_om DECIMAL(12,9),
    sigma_w DECIMAL(12,9),
    
    -- Classificação da Órbita
    orbit_class VARCHAR(10), 
    
    CONSTRAINT FK_Orbital_Asteroid FOREIGN KEY (asteroid_id) REFERENCES Asteroid(asteroid_id) ON DELETE CASCADE,
    -- Garante que não há dados duplicados para o mesmo asteroide na mesma época
    CONSTRAINT UQ_Asteroid_Epoch UNIQUE (asteroid_id, epoch_mjd)
);
GO


CREATE TABLE Observation (
    observation_id INT IDENTITY(1,1) PRIMARY KEY,
    asteroid_id INT NOT NULL,
    observatory_id INT,
    astronomer_id INT,
    equipment_id INT,
    software_id INT,
    
    observation_date DATETIME NOT NULL,
    duration_minutes INT,
    observation_mode VARCHAR(20), 
    
    -- Ligações (FK)
    CONSTRAINT FK_Obs_Asteroid FOREIGN KEY (asteroid_id) REFERENCES Asteroid(asteroid_id),
    CONSTRAINT FK_Obs_Observatory FOREIGN KEY (observatory_id) REFERENCES Observatory(observatory_id),
    CONSTRAINT FK_Obs_Astronomer FOREIGN KEY (astronomer_id) REFERENCES Astronomer(astronomer_id),
    CONSTRAINT FK_Obs_Equipment FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id),
    CONSTRAINT FK_Obs_Software FOREIGN KEY (software_id) REFERENCES Software(software_id)
);
GO


CREATE TABLE Alert (
    alert_id INT IDENTITY(1,1) PRIMARY KEY,
    asteroid_id INT NOT NULL,
    
    -- Dados do Alerta
    alert_date DATETIME DEFAULT GETDATE(),
    alert_type VARCHAR(50), 
    priority_level VARCHAR(20) CHECK (priority_level IN ('Alta', 'Média', 'Baixa')), 
    torino_scale INT CHECK (torino_scale BETWEEN 0 AND 10), 
    color_code VARCHAR(10), 
    
    message VARCHAR(500),
    is_active BIT DEFAULT 1, 
    
    CONSTRAINT FK_Alert_Asteroid FOREIGN KEY (asteroid_id) REFERENCES Asteroid(asteroid_id)
);
GO

-- Criação de Índices para Performance 
CREATE INDEX IX_Asteroid_SPKID ON Asteroid(spkid);
CREATE INDEX IX_Orbital_MOID ON OrbitalData(moid_ld);
CREATE INDEX IX_Orbital_Epoch ON OrbitalData(epoch_mjd);
CREATE INDEX IX_Alert_Priority ON Alert(priority_level);
