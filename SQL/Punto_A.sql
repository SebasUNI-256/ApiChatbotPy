USE [DB_EcommerceAgent]
GO

CREATE OR ALTER PROCEDURE sp_BuscarProductosAgente
    @i_FilterText VARCHAR(100),
    @i_UsuarioID VARCHAR(100),         
    @i_ConversacionID BIGINT = NULL,   
    @o_ConversacionID BIGINT OUTPUT,   
    @o_ResultCode INT OUTPUT,
    @o_ResultMessage VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Variables internas de control
    DECLARE @FechaActual DATETIME = GETDATE();
    DECLARE @ReglaBusquedaID INT;
    DECLARE @ReglaNoEntendidoID INT;

    SELECT TOP 1 @ReglaBusquedaID = ReglaID FROM ReglasChatbot WHERE AccionPython = 'buscar_producto_en_db' AND Activo = 1;
    SELECT TOP 1 @ReglaNoEntendidoID = ReglaID FROM ReglasChatbot WHERE NombreRegla LIKE '%No Entendida%' AND Activo = 1;

    BEGIN TRY
        -- -----------------------------------------------------------------
        -- 1. CONTROL / CREACIÓN DE LA CONVERSACIÓN
        -- -----------------------------------------------------------------
        SET @o_ConversacionID = @i_ConversacionID;

        -- Si no mandan una conversación válida, abrimos una nueva sesión de chat
        IF @o_ConversacionID IS NULL OR @o_ConversacionID = 0
        BEGIN
            INSERT INTO HistorialConversaciones (UsuarioID, FechaInicio, FechaFin, Activo)
            VALUES (@i_UsuarioID, @FechaActual, NULL, 1);
            
            SET @o_ConversacionID = SCOPE_IDENTITY();
        END;

        -- -----------------------------------------------------------------
        -- 2. VALIDACIÓN DE ENTRADA (Filtro Vacío) -> Error Controlado 400
        -- -----------------------------------------------------------------
        IF @i_FilterText IS NULL OR TRIM(@i_FilterText) = ''
        BEGIN
            SET @o_ResultCode = 400;
            SET @o_ResultMessage = 'Error controlado: El texto de filtro no puede estar vacío.';

            -- A. Insertar el mensaje de texto inválido enviado por el USUARIO
            INSERT INTO HistorialMensajes (ConversacionID, ChatBot, Texto, FechaHora, ReglaActivadaID)
            VALUES (@o_ConversacionID, 0, ISNULL(@i_FilterText, '[Texto Vacío]'), @FechaActual, NULL);

            -- B. Insertar la respuesta del SISTEMA (Se activa la regla de fallback / no entendido)
            INSERT INTO HistorialMensajes (ConversacionID, ChatBot, Texto, FechaHora, ReglaActivadaID)
            VALUES (@o_ConversacionID, 1, @o_ResultMessage, @FechaActual, @ReglaNoEntendidoID);
            
            SELECT TOP 0 * FROM [DB_ECOMMERCE].[SQM_GENERAL].[WV_GENERAL_PRODUCTS];
            RETURN;
        END;

        -- -----------------------------------------------------------------
        -- 3. LOG DE ENTRADA: Guardar lo que escribió el usuario legítimamente
        -- -----------------------------------------------------------------
        INSERT INTO HistorialMensajes (ConversacionID, ChatBot, Texto, FechaHora, ReglaActivadaID)
        VALUES (@o_ConversacionID, 0, @i_FilterText, @FechaActual, NULL);

        -- -----------------------------------------------------------------
        -- 4. EJECUCIÓN DE LA CONSULTA PRINCIPAL
        -- -----------------------------------------------------------------
        DECLARE @Buscar VARCHAR(102) = '%' + TRIM(@i_FilterText) + '%';

        SELECT 
            [ProductID], [ProductName], [ProductVariableID], [ProductVariableName],
            [ProductVariablePrice], [CurrencyISO], [CategoryName], [SubcategoryName],
            [SegmentName], [MarkName], [ProviderName], [StockAvailable]
        FROM 
            [DB_ECOMMERCE].[SQM_GENERAL].[WV_GENERAL_PRODUCTS] WITH (NOLOCK)
        WHERE 
            [ProductName]          LIKE @Buscar
            OR [ProductVariableName] LIKE @Buscar
            OR [CategoryName]        LIKE @Buscar
            OR [SubcategoryName]     LIKE @Buscar
            OR [SegmentName]         LIKE @Buscar
            OR [MarkName]            LIKE @Buscar
            OR [ProviderName]        LIKE @Buscar;

        -- Asignación de respuesta exitosa
        SET @o_ResultCode = 200;
        SET @o_ResultMessage = 'OK: Búsqueda realizada satisfactoriamente.';

        -- -----------------------------------------------------------------
        -- 5. LOG DE SALIDA: Guardar la respuesta del sistema indicando éxito
        -- -----------------------------------------------------------------
        INSERT INTO HistorialMensajes (ConversacionID, ChatBot, Texto, FechaHora, ReglaActivadaID)
        VALUES (@o_ConversacionID, 1, @o_ResultMessage, @FechaActual, @ReglaBusquedaID);

    END TRY
    BEGIN CATCH
        -- -----------------------------------------------------------------
        -- 6. MANEJO DE ERRORES CRÍTICOS (SQL 500)
        -- -----------------------------------------------------------------
        SET @o_ResultCode = 500;
        SET @o_ResultMessage = 'Error SQL [' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ']: ' + ERROR_MESSAGE();

        -- Si logramos tener un ID de conversación, registramos la caída del sistema
        IF @o_ConversacionID IS NOT NULL AND @o_ConversacionID > 0
        BEGIN
            INSERT INTO HistorialMensajes (ConversacionID, ChatBot, Texto, FechaHora, ReglaActivadaID)
            VALUES (@o_ConversacionID, 1, 'Error interno del sistema: No se pudo procesar la búsqueda.', @FechaActual, NULL);
        END
    END CATCH
END;
GO