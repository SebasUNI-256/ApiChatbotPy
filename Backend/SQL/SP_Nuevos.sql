USE [DB_EcommerceAgent]
GO

CREATE OR ALTER PROCEDURE dbo.sp_CrearConversacion
(
    @UsuarioID VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.HistorialConversaciones
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

CREATE OR ALTER PROCEDURE dbo.sp_GuardarMensaje
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

    INSERT INTO dbo.HistorialMensajes
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

CREATE OR ALTER PROCEDURE dbo.sp_BuscarRegla
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
    FROM dbo.ReglasChatbot R
    INNER JOIN dbo.PalabrasClaveRegla P
        ON R.ReglaID = P.ReglaID
    WHERE R.Activo = 1
      AND P.Activo = 1
      AND @Mensaje LIKE '%' + P.PalabraClave + '%'
    ORDER BY LEN(P.PalabraClave) DESC, R.ReglaID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ObtenerRespuesta
(
    @ReglaID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)
        PlantillaID,
        TextoRespuesta
    FROM dbo.PlantillasRespuesta
    WHERE ReglaID = @ReglaID
      AND Activo = 1
    ORDER BY NEWID();
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ObtenerHistorialConversacion
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
    FROM dbo.HistorialMensajes M
    WHERE M.ConversacionID = @ConversacionID
    ORDER BY M.FechaHora, M.MensajeID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ObtenerConversacionesUsuario
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
    FROM dbo.HistorialConversaciones
    WHERE UsuarioID = @UsuarioID
    ORDER BY FechaInicio DESC, ConversacionID DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_CerrarConversacion
(
    @ConversacionID BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.HistorialConversaciones
    SET FechaFin = GETDATE(),
        Activo = 0
    WHERE ConversacionID = @ConversacionID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_EliminarConversacion
(
    @ConversacionID BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.HistorialMensajes
    WHERE ConversacionID = @ConversacionID;

    DELETE FROM dbo.HistorialConversaciones
    WHERE ConversacionID = @ConversacionID;
END
GO
