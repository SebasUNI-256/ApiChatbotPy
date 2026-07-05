CREATE DATABASE [DB_EcommerceAgent]
GO

USE [DB_EcommerceAgent]
GO

    -- 1. CREACIÓN DE LA TABLA PRINCIPAL: REGLAS
    -- Aquí guardamos QUÉ debe hacer el bot cuando se activa una regla.
    CREATE TABLE ReglasChatbot (
        ReglaID INT PRIMARY KEY IDENTITY(1,1),
        NombreRegla VARCHAR(100) NOT NULL,
        AccionDinamica BIT NOT NULL,     -- 'TEXTO_ESTATICO' o 'ACCION_DINAMICA'
        AccionPython VARCHAR(100) NULL,         -- Nombre de la función en Python (si es dinámica)
        Activo BIT                    -- Para activar/desactivar reglas fácilmente
    );

    -- 2. CREACIÓN DE LA TABLA SECUNDARIA: PALABRAS CLAVE (TRIGGERS)
    -- Aquí guardamos las palabras que el usuario podría escribir para activar la regla.
    CREATE TABLE PalabrasClaveRegla (
        PalabraClaveID INT PRIMARY KEY IDENTITY(1,1),
        ReglaID INT NOT NULL REFERENCES ReglasChatbot(ReglaID),
        PalabraClave VARCHAR(100) NOT NULL,
	    Activo BIT
    );

    -- =====================================================================
    -- 1. TABLA: VARIACIONES DE RESPUESTAS (PLANTILLAS DE SALIDA)
    -- Modificamos el enfoque anterior para que una regla tenga MUCHAS opciones de respuesta.
    -- =====================================================================

    -- Primero, una buena práctica: si ya creaste la tabla 'ReglasChatbot' con la columna 'RespuestaTexto',
    -- la eliminamos de ahí porque ahora vivirá de forma más organizada en esta nueva tabla.
    CREATE TABLE PlantillasRespuesta (
        PlantillaID INT IDENTITY(1,1) PRIMARY KEY,
        ReglaID INT NOT NULL REFERENCES ReglasChatbot(ReglaID),
        TextoRespuesta NVARCHAR(MAX) NOT NULL, -- La frase exacta que dirá el bot
        Activo BIT
    );


    -- =====================================================================
    -- 2. TABLA: HISTORIAL DE CONVERSACIONES (LOGS DE ENTRADA Y SALIDA)
    -- Aquí se almacena la interacción real del e-commerce. Todo lo que entra y sale.
    -- =====================================================================
    CREATE TABLE HistorialConversaciones
    (
	    ConversacionID BIGINT IDENTITY(1,1) PRIMARY KEY,
	    UsuarioID VARCHAR(100) NOT NULL,
	    FechaInicio DATETIME NOT NULL,
	    FechaFin DATETIME NULL,
	    Activo BIT
    )

    CREATE TABLE HistorialMensajes (
        MensajeID BIGINT IDENTITY(1,1) PRIMARY KEY,
	    ConversacionID BIGINT REFERENCES HistorialConversaciones (ConversacionID) NOT NULL,
        ChatBot BIT NOT NULL,           -- 'USUARIO' o 'SISTEMA'
        Texto VARCHAR(1000) NOT NULL,            
        FechaHora DATETIME NOT NULL,     -- Momento exacto de la interacción
        ReglaActivadaID INT REFERENCES ReglasChatbot(ReglaID),               -- Qué regla del sistema experto respondió (si fue el SISTEMA)   
    );
    Alter table HistorialMensajes
    Alter column Texto NVARCHAR(3000) NOT NULL
    Alter table HistorialMensajes
    Add  MetaData NVARCHAR(3000)
    ALTER TABLE HistorialMensajes
    ALTER COLUMN ReglaActivadaID INT NULL;
    


SELECT *
FROM ReglasChatbot

SELECT *
FROM PalabrasClaveRegla

SELECT *
FROM PlantillasRespuesta

SELECT *
FROM HistorialMensajes

