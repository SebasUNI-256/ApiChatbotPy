USE [DB_EcommerceAgent]
GO

CREATE OR ALTER PROCEDURE dbo.sp_BuscarProductosAgente
    @i_FilterText VARCHAR(100),
    @i_UsuarioID VARCHAR(100),
    @i_ConversacionID BIGINT = NULL,
    @o_ConversacionID BIGINT OUTPUT,
    @o_ResultCode INT OUTPUT,
    @o_ResultMessage VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ReglaBusquedaID INT;
    DECLARE @ReglaNoEntendidoID INT;

    SELECT TOP 1 @ReglaBusquedaID = ReglaID
    FROM dbo.ReglasChatbot
    WHERE AccionPython = 'buscar_producto_en_db'
      AND Activo = 1;

    SELECT TOP 1 @ReglaNoEntendidoID = ReglaID
    FROM dbo.ReglasChatbot
    WHERE NombreRegla = 'No Entendimos La Peticion'
      AND Activo = 1;

    BEGIN TRY
        SET @o_ConversacionID = @i_ConversacionID;

        IF @o_ConversacionID IS NULL OR @o_ConversacionID = 0
        BEGIN
            DECLARE @NuevaConversacion TABLE
            (
                ConversacionID BIGINT NOT NULL
            );

            INSERT INTO @NuevaConversacion (ConversacionID)
            EXEC dbo.sp_CrearConversacion
                @UsuarioID = @i_UsuarioID;

            SELECT @o_ConversacionID = ConversacionID
            FROM @NuevaConversacion;
        END;

        IF @i_FilterText IS NULL OR LTRIM(RTRIM(@i_FilterText)) = ''
        BEGIN
            DECLARE @TextoFiltroVacio NVARCHAR(3000) = ISNULL(@i_FilterText, '[Texto vacio]');
            SET @o_ResultCode = 400;
            SET @o_ResultMessage = 'El texto de filtro no puede estar vacio.';

            EXEC dbo.sp_GuardarMensaje
                @ConversacionID = @o_ConversacionID,
                @ChatBot = 0,
                @Texto = @TextoFiltroVacio,
                @ReglaActivadaID = NULL,
                @MetaData = NULL;

            EXEC dbo.sp_GuardarMensaje
                @ConversacionID = @o_ConversacionID,
                @ChatBot = 1,
                @Texto = @o_ResultMessage,
                @ReglaActivadaID = @ReglaNoEntendidoID,
                @MetaData = NULL;

            SELECT TOP 0
                ProductID,
                ProductName,
                ProductVariableID,
                ProductVariableName,
                ProductVariablePrice,
                CurrencyISO,
                CategoryName,
                SubcategoryName,
                SegmentName,
                MarkName,
                ProviderName,
                StockAvailable
            FROM [DB_ECOMMERCE].[SQM_GENERAL].[VW_GENERAL_PRODUCTS];

            RETURN;
        END;

        EXEC dbo.sp_GuardarMensaje
            @ConversacionID = @o_ConversacionID,
            @ChatBot = 0,
            @Texto = @i_FilterText,
            @ReglaActivadaID = NULL,
            @MetaData = NULL;

        DECLARE @Buscar VARCHAR(102) = '%' + LTRIM(RTRIM(@i_FilterText)) + '%';

        SELECT
            ProductID,
            ProductName,
            ProductVariableID,
            ProductVariableName,
            ProductVariablePrice,
            CurrencyISO,
            CategoryName,
            SubcategoryName,
            SegmentName,
            MarkName,
            ProviderName,
            StockAvailable
        FROM [DB_ECOMMERCE].[SQM_GENERAL].[VW_GENERAL_PRODUCTS] WITH (NOLOCK)
        WHERE ProductName LIKE @Buscar
            OR ProductVariableName LIKE @Buscar
            OR CategoryName LIKE @Buscar
            OR SubcategoryName LIKE @Buscar
            OR SegmentName LIKE @Buscar
            OR MarkName LIKE @Buscar
            OR ProviderName LIKE @Buscar;

        SET @o_ResultCode = 200;
        SET @o_ResultMessage = 'Busqueda realizada satisfactoriamente.';

        EXEC dbo.sp_GuardarMensaje
            @ConversacionID = @o_ConversacionID,
            @ChatBot = 1,
            @Texto = @o_ResultMessage,
            @ReglaActivadaID = @ReglaBusquedaID,
            @MetaData = NULL;
    END TRY
    BEGIN CATCH
        SET @o_ResultCode = 500;
        SET @o_ResultMessage = 'Error SQL [' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ']: ' + ERROR_MESSAGE();

        IF @o_ConversacionID IS NOT NULL AND @o_ConversacionID > 0
        BEGIN
            EXEC dbo.sp_GuardarMensaje
                @ConversacionID = @o_ConversacionID,
                @ChatBot = 1,
                @Texto = 'Error interno del sistema: No se pudo procesar la busqueda.',
                @ReglaActivadaID = @ReglaNoEntendidoID,
                @MetaData = NULL;
        END
    END CATCH
END;
GO
