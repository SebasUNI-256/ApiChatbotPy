USE DB_EcommerceAgent
GO

--CREATE OR ALTER PROCEDURE sp_GuardarConversacion
--    @ConversationJson NVARCHAR(MAX)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    DECLARE
--        @UsuarioID VARCHAR(100),
--        @FechaInicio DATETIME,
--        @ConversacionID BIGINT;

--    -------------------------------------------------------
--    -- Datos principales
--    -------------------------------------------------------
--    SELECT
--        @UsuarioID = user_id
--    FROM OPENJSON(@ConversationJson)
--    WITH
--    (
--        user_id VARCHAR(100) '$.user_id'
--    );

--    SET @FechaInicio = GETDATE();

--    -------------------------------------------------------
--    -- Crear conversación
--    -------------------------------------------------------
--    INSERT INTO HistorialConversaciones
--    (
--        UsuarioID,
--        FechaInicio,
--        Activo
--    )
--    VALUES
--    (
--        @UsuarioID,
--        @FechaInicio,
--        1
--    );

--    SET @ConversacionID = SCOPE_IDENTITY();

--    -------------------------------------------------------
--    -- Guardar mensajes
--    -------------------------------------------------------
--    INSERT INTO HistorialMensajes
--    (
--        ConversacionID,
--        ChatBot,
--        Texto,
--        FechaHora,
--        ReglaActivadaID,
--        MetaData
--    )
--    SELECT
--        @ConversacionID,

--        CASE
--            WHEN role='assistant' THEN 1
--            ELSE 0
--        END,

--        content,

--        CAST(timestamp AS DATETIME),

--        ISNULL(intent,0),

--        metadata
--    FROM OPENJSON(@ConversationJson,'$.messages')
--    WITH
--    (
--        role NVARCHAR(20) '$.role',
--        timestamp NVARCHAR(50) '$.timestamp',
--        intent INT '$.intent',
--        content NVARCHAR(MAX) '$.content',
--        metadata NVARCHAR(MAX) '$.metadata' AS JSON
--    );

--    -------------------------------------------------------
--    -- Finalizar conversación
--    -------------------------------------------------------
--    UPDATE HistorialConversaciones
--    SET FechaFin = GETDATE()
--    WHERE ConversacionID=@ConversacionID;

--    SELECT @ConversacionID AS ConversacionID;
--END
--GO

--CREATE OR ALTER PROCEDURE sp_ObtenerHistorialConversacion
--    @ConversacionID BIGINT
--AS
--BEGIN
--    SET NOCOUNT ON;

--    SELECT
--        hc.ConversacionID,
--        hc.UsuarioID,
--        hm.MensajeID,
--        hm.ChatBot,
--        hm.Texto,
--        hm.FechaHora,
--        hm.ReglaActivadaID,
--        hm.MetaData
--    FROM HistorialConversaciones hc
--        INNER JOIN HistorialMensajes hm
--            ON hc.ConversacionID=hm.ConversacionID
--    WHERE hc.ConversacionID=@ConversacionID
--    ORDER BY hm.FechaHora;
--END
--GO

--CREATE OR ALTER PROCEDURE sp_ObtenerConversacionesUsuario
--    @UsuarioID VARCHAR(100)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    SELECT
--        ConversacionID,
--        UsuarioID,
--        FechaInicio,
--        FechaFin,
--        Activo
--    FROM HistorialConversaciones
--    WHERE UsuarioID=@UsuarioID
--    ORDER BY FechaInicio DESC;
--END
--GO

--CREATE OR ALTER PROCEDURE sp_EliminarConversacion
--    @ConversacionID BIGINT
--AS
--BEGIN
--    SET NOCOUNT ON;

--    DELETE FROM HistorialMensajes
--    WHERE ConversacionID=@ConversacionID;

--    DELETE FROM HistorialConversaciones
--    WHERE ConversacionID=@ConversacionID;
--END
--GO

--CREATE OR ALTER PROCEDURE sp_BuscarRegla
--    @Mensaje NVARCHAR(3000)
--AS
--BEGIN

--    SELECT TOP(1)

--        R.ReglaID,
--        R.NombreRegla,
--        R.AccionDinamica,
--        R.AccionPython

--    FROM ReglasChatbot R
--        INNER JOIN PalabrasClaveRegla P
--            ON R.ReglaID=P.ReglaID

--    WHERE
--        R.Activo=1
--        AND P.Activo=1
--        AND @Mensaje LIKE '%' + P.PalabraClave + '%';

--END
--GO

--CREATE OR ALTER PROCEDURE sp_ObtenerRespuesta
--    @ReglaID INT
--AS
--BEGIN

--    SELECT TOP(1)
--        TextoRespuesta
--    FROM PlantillasRespuesta
--    WHERE
--        ReglaID=@ReglaID
--        AND Activo=1
--    ORDER BY NEWID();

--END
--GO

--Probar esto
CREATE OR ALTER PROCEDURE sp_CrearConversacion
(
    @UsuarioID VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO HistorialConversaciones
    (
        UsuarioID,
        FechaInicio,
        Activo
    )
    VALUES
    (
        @UsuarioID,
        GETDATE(),
        1
    );

    SELECT SCOPE_IDENTITY() AS ConversacionID;
END
GO

CREATE OR ALTER PROCEDURE sp_GuardarMensaje
(
    @ConversacionID BIGINT,
    @ChatBot BIT,
    @Texto NVARCHAR(3000),
    @ReglaActivadaID INT = NULL,
    @MetaData NVARCHAR(3000) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO HistorialMensajes
    (
        ConversacionID,
        ChatBot,
        Texto,
        FechaHora,
        ReglaActivadaID,
        MetaData
    )
    VALUES
    (
        @ConversacionID,
        @ChatBot,
        @Texto,
        GETDATE(),
        @ReglaActivadaID,
        @MetaData
    );
END
GO

CREATE OR ALTER PROCEDURE sp_BuscarRegla
(
    @Mensaje NVARCHAR(3000)
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)

        R.ReglaID,
        R.NombreRegla,
        R.AccionDinamica,
        R.AccionPython

    FROM ReglasChatbot R
        INNER JOIN PalabrasClaveRegla P
            ON R.ReglaID = P.ReglaID

    WHERE
        R.Activo = 1
        AND P.Activo = 1
        AND @Mensaje LIKE '%' + P.PalabraClave + '%';
END
GO

CREATE OR ALTER PROCEDURE sp_ObtenerRespuesta
(
    @ReglaID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)

        PlantillaID,
        TextoRespuesta

    FROM PlantillasRespuesta

    WHERE
        ReglaID = @ReglaID
        AND Activo = 1

    ORDER BY NEWID();
END
GO

CREATE OR ALTER PROCEDURE sp_ObtenerHistorialConversacion
(
    @ConversacionID BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT

        M.MensajeID,
        M.ChatBot,
        M.Texto,
        M.FechaHora,
        M.ReglaActivadaID,
        M.MetaData

    FROM HistorialMensajes M

    WHERE M.ConversacionID = @ConversacionID

    ORDER BY M.FechaHora;
END
GO

CREATE OR ALTER PROCEDURE sp_ObtenerConversacionesUsuario
(
    @UsuarioID VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT

        ConversacionID,
        UsuarioID,
        FechaInicio,
        FechaFin,
        Activo

    FROM HistorialConversaciones

    WHERE UsuarioID = @UsuarioID

    ORDER BY FechaInicio DESC;
END
GO
CREATE OR ALTER PROCEDURE sp_CerrarConversacion
(
    @ConversacionID BIGINT
)
AS
BEGIN 
    SET NOCOUNT ON;

    UPDATE HistorialConversaciones
    SET
        FechaFin = GETDATE(),
        Activo = 0
    WHERE ConversacionID = @ConversacionID;
END
GO

CREATE OR ALTER PROCEDURE sp_EliminarConversacion
(
    @ConversacionID BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM HistorialMensajes
    WHERE ConversacionID = @ConversacionID;

    DELETE FROM HistorialConversaciones
    WHERE ConversacionID = @ConversacionID;
END
GO
