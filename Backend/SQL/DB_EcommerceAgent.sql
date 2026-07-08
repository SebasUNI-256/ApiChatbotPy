IF DB_ID(N'DB_EcommerceAgent') IS NULL
BEGIN
    CREATE DATABASE [DB_EcommerceAgent];
END
GO

USE [DB_EcommerceAgent]
GO

IF OBJECT_ID(N'dbo.HistorialMensajes', N'U') IS NOT NULL
    DROP TABLE dbo.HistorialMensajes;
GO

IF OBJECT_ID(N'dbo.HistorialConversaciones', N'U') IS NOT NULL
    DROP TABLE dbo.HistorialConversaciones;
GO

IF OBJECT_ID(N'dbo.PlantillasRespuesta', N'U') IS NOT NULL
    DROP TABLE dbo.PlantillasRespuesta;
GO

IF OBJECT_ID(N'dbo.PalabrasClaveRegla', N'U') IS NOT NULL
    DROP TABLE dbo.PalabrasClaveRegla;
GO

IF OBJECT_ID(N'dbo.ReglasChatbot', N'U') IS NOT NULL
    DROP TABLE dbo.ReglasChatbot;
GO

CREATE TABLE dbo.ReglasChatbot
(
    ReglaID INT IDENTITY(1,1) PRIMARY KEY,
    NombreRegla VARCHAR(100) NOT NULL,
    AccionDinamica BIT NOT NULL,
    AccionPython VARCHAR(100) NULL,
    Activo BIT NOT NULL
);
GO

CREATE TABLE dbo.PalabrasClaveRegla
(
    PalabraClaveID INT IDENTITY(1,1) PRIMARY KEY,
    ReglaID INT NOT NULL REFERENCES dbo.ReglasChatbot(ReglaID),
    PalabraClave VARCHAR(100) NOT NULL,
    Activo BIT NOT NULL
);
GO

CREATE TABLE dbo.PlantillasRespuesta
(
    PlantillaID INT IDENTITY(1,1) PRIMARY KEY,
    ReglaID INT NOT NULL REFERENCES dbo.ReglasChatbot(ReglaID),
    TextoRespuesta NVARCHAR(MAX) NOT NULL,
    Activo BIT NOT NULL
);
GO

CREATE TABLE dbo.HistorialConversaciones
(
    ConversacionID BIGINT IDENTITY(1,1) PRIMARY KEY,
    UsuarioID VARCHAR(100) NOT NULL,
    FechaInicio DATETIME NOT NULL,
    FechaFin DATETIME NULL,
    Activo BIT NOT NULL
);
GO

CREATE TABLE dbo.HistorialMensajes
(
    MensajeID BIGINT IDENTITY(1,1) PRIMARY KEY,
    ConversacionID BIGINT NOT NULL REFERENCES dbo.HistorialConversaciones(ConversacionID),
    ChatBot BIT NOT NULL,
    Texto NVARCHAR(3000) NOT NULL,
    FechaHora DATETIME NOT NULL,
    ReglaActivadaID INT NULL REFERENCES dbo.ReglasChatbot(ReglaID),
    MetaData NVARCHAR(3000) NULL
);
GO
