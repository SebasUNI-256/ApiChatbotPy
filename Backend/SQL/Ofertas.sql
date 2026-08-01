USE [DB_ECOMMERCE]
GO

SET XACT_ABORT ON;
BEGIN TRANSACTION;
GO

IF OBJECT_ID(N'SQM_GENERAL.VW_ACTIVE_PRODUCT_OFFERS', N'V') IS NOT NULL
    DROP VIEW SQM_GENERAL.VW_ACTIVE_PRODUCT_OFFERS;
GO

IF OBJECT_ID(N'SQM_GENERAL.Tbl_ProductOffers', N'U') IS NOT NULL
   AND COL_LENGTH(N'SQM_GENERAL.Tbl_ProductOffers', N'productOfferOfferId') IS NULL
BEGIN
    DROP TABLE SQM_GENERAL.Tbl_ProductOffers;
END;
GO

IF OBJECT_ID(N'SQM_GENERAL.Tbl_Offers', N'U') IS NULL
BEGIN
    CREATE TABLE SQM_GENERAL.Tbl_Offers
    (
        offerId INT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_Tbl_Offers PRIMARY KEY,
        offerName VARCHAR(100) NOT NULL,
        offerDescription VARCHAR(255) NOT NULL,
        offerDiscountPercentage DECIMAL(5,2) NOT NULL,
        offerStartDate DATETIME2 NOT NULL,
        offerEndDate DATETIME2 NULL,
        offerStatusId BIT NOT NULL,
        CONSTRAINT UQ_Tbl_Offers_Name UNIQUE (offerName),
        CONSTRAINT CK_Tbl_Offers_DiscountPercentage
            CHECK (offerDiscountPercentage > 0 AND offerDiscountPercentage < 100),
        CONSTRAINT CK_Tbl_Offers_DateRange
            CHECK (offerEndDate IS NULL OR offerEndDate >= offerStartDate)
    );
END;
GO

IF OBJECT_ID(N'SQM_GENERAL.Tbl_ProductOffers', N'U') IS NULL
BEGIN
    CREATE TABLE SQM_GENERAL.Tbl_ProductOffers
    (
        productOfferId INT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_Tbl_ProductOffers PRIMARY KEY,
        productOfferOfferId INT NOT NULL
            CONSTRAINT FK_Tbl_ProductOffers_Offer
            REFERENCES SQM_GENERAL.Tbl_Offers(offerId),
        productOfferProductVariableId INT NOT NULL
            CONSTRAINT FK_Tbl_ProductOffers_ProductVariable
            REFERENCES SQM_GENERAL.Tbl_ProductVariables(productVariableId),
        productOfferStatusId BIT NOT NULL,
        CONSTRAINT UQ_Tbl_ProductOffers_OfferProductVariable
            UNIQUE (productOfferOfferId, productOfferProductVariableId)
    );
END;
GO

DECLARE @SeedOffers TABLE
(
    OfferName VARCHAR(100) NOT NULL,
    OfferDescription VARCHAR(255) NOT NULL,
    DiscountPercentage DECIMAL(5,2) NOT NULL,
    ProductName VARCHAR(100) NOT NULL
);

INSERT INTO @SeedOffers
(
    OfferName,
    OfferDescription,
    DiscountPercentage,
    ProductName
)
VALUES
    ('Camisetas Zara 20%', 'Veinte por ciento de descuento en camisetas Zara.', 20, 'CAMISETA ZARA'),
    ('Jeans Levis 15%', 'Quince por ciento de descuento en jeans Levis 501.', 15, 'JEANS LEVIS 501'),
    ('Ultraboost 10%', 'Diez por ciento de descuento en tenis Ultraboost.', 10, 'TENIS ULTRABOOST');

MERGE SQM_GENERAL.Tbl_Offers AS Target
USING
(
    SELECT DISTINCT
        OfferName,
        OfferDescription,
        DiscountPercentage
    FROM @SeedOffers
) AS Source
    ON Source.OfferName = Target.offerName
WHEN MATCHED THEN
    UPDATE SET
        Target.offerDescription = Source.OfferDescription,
        Target.offerDiscountPercentage = Source.DiscountPercentage,
        Target.offerStartDate = CONVERT(DATETIME2, '2026-01-01'),
        Target.offerEndDate = NULL,
        Target.offerStatusId = 1
WHEN NOT MATCHED THEN
    INSERT
    (
        offerName,
        offerDescription,
        offerDiscountPercentage,
        offerStartDate,
        offerEndDate,
        offerStatusId
    )
    VALUES
    (
        Source.OfferName,
        Source.OfferDescription,
        Source.DiscountPercentage,
        CONVERT(DATETIME2, '2026-01-01'),
        NULL,
        1
    );

;WITH SeedAssignments AS
(
    SELECT DISTINCT
        Offer.offerId,
        Catalog.ProductVariableID
    FROM @SeedOffers Seed
    INNER JOIN SQM_GENERAL.Tbl_Offers Offer
        ON Offer.offerName = Seed.OfferName
    INNER JOIN SQM_GENERAL.VW_GENERAL_PRODUCTS Catalog
        ON Catalog.ProductName = Seed.ProductName
)
MERGE SQM_GENERAL.Tbl_ProductOffers AS Target
USING SeedAssignments AS Source
    ON Source.offerId = Target.productOfferOfferId
   AND Source.ProductVariableID = Target.productOfferProductVariableId
WHEN MATCHED THEN
    UPDATE SET Target.productOfferStatusId = 1
WHEN NOT MATCHED THEN
    INSERT
    (
        productOfferOfferId,
        productOfferProductVariableId,
        productOfferStatusId
    )
    VALUES
    (
        Source.offerId,
        Source.ProductVariableID,
        1
    );
GO

CREATE OR ALTER VIEW SQM_GENERAL.VW_ACTIVE_PRODUCT_OFFERS
AS
    SELECT
        Catalog.ProductID,
        Catalog.ProductName,
        Catalog.ProductVariableID,
        Catalog.ProductVariableName,
        ActiveOffer.OfferID,
        ActiveOffer.OfferName,
        Catalog.ProductVariablePrice AS OriginalPrice,
        ActiveOffer.DiscountPercentage,
        CONVERT(
            DECIMAL(18,2),
            ROUND(
                Catalog.ProductVariablePrice
                    * (1 - ActiveOffer.DiscountPercentage / 100.0),
                2
            )
        ) AS ProductVariablePrice,
        Catalog.CurrencyISO,
        Catalog.CategoryName,
        Catalog.SubcategoryName,
        Catalog.SegmentName,
        Catalog.MarkName,
        Catalog.ProviderName,
        Catalog.StockAvailable
    FROM SQM_GENERAL.VW_GENERAL_PRODUCTS Catalog
    CROSS APPLY
    (
        SELECT TOP (1)
            Offer.offerId AS OfferID,
            Offer.offerName AS OfferName,
            Offer.offerDiscountPercentage AS DiscountPercentage
        FROM SQM_GENERAL.Tbl_ProductOffers ProductOffer
        INNER JOIN SQM_GENERAL.Tbl_Offers Offer
            ON Offer.offerId = ProductOffer.productOfferOfferId
        WHERE ProductOffer.productOfferProductVariableId = Catalog.ProductVariableID
          AND ProductOffer.productOfferStatusId = 1
          AND Offer.offerStatusId = 1
          AND Offer.offerStartDate <= SYSDATETIME()
          AND (Offer.offerEndDate IS NULL OR Offer.offerEndDate >= SYSDATETIME())
        ORDER BY
            Offer.offerDiscountPercentage DESC,
            Offer.offerId
    ) ActiveOffer
    WHERE Catalog.StockAvailable > 0;
GO

USE [DB_EcommerceAgent]
GO

CREATE OR ALTER PROCEDURE dbo.sp_BuscarOfertasAgente
    @i_pageNumber INT = 1,
    @o_ResultCode INT OUTPUT,
    @o_ResultMessage VARCHAR(500) OUTPUT,
    @o_pageNumber INT OUTPUT,
    @o_pageSize INT OUTPUT,
    @o_totalRows INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RowsPerPage INT = 10;
    DECLARE @RowsReturned INT = 0;

    SET @o_pageNumber = @i_pageNumber;
    SET @o_pageSize = @RowsPerPage;
    SET @o_totalRows = 0;

    IF @i_pageNumber IS NULL OR @i_pageNumber < 1
    BEGIN
        SET @o_ResultCode = 400;
        SET @o_ResultMessage = 'El numero de pagina debe ser un entero positivo.';

        SELECT TOP (0)
            ProductID,
            ProductName,
            ProductVariableID,
            ProductVariableName,
            OfferID,
            OfferName,
            OriginalPrice,
            DiscountPercentage,
            ProductVariablePrice,
            CurrencyISO,
            CategoryName,
            SubcategoryName,
            SegmentName,
            MarkName,
            ProviderName,
            StockAvailable
        FROM [DB_ECOMMERCE].[SQM_GENERAL].[VW_ACTIVE_PRODUCT_OFFERS];

        RETURN;
    END;

    SELECT @o_totalRows = COUNT(DISTINCT ProductVariableID)
    FROM [DB_ECOMMERCE].[SQM_GENERAL].[VW_ACTIVE_PRODUCT_OFFERS] WITH (NOLOCK);

    SELECT
        ProductID,
        ProductName,
        ProductVariableID,
        ProductVariableName,
        OfferID,
        OfferName,
        OriginalPrice,
        DiscountPercentage,
        ProductVariablePrice,
        CurrencyISO,
        CategoryName,
        SubcategoryName,
        SegmentName,
        MarkName,
        ProviderName,
        SUM(StockAvailable) AS StockAvailable
    FROM [DB_ECOMMERCE].[SQM_GENERAL].[VW_ACTIVE_PRODUCT_OFFERS] WITH (NOLOCK)
    GROUP BY
        ProductID,
        ProductName,
        ProductVariableID,
        ProductVariableName,
        OfferID,
        OfferName,
        OriginalPrice,
        DiscountPercentage,
        ProductVariablePrice,
        CurrencyISO,
        CategoryName,
        SubcategoryName,
        SegmentName,
        MarkName,
        ProviderName
    ORDER BY
        DiscountPercentage DESC,
        ProductID,
        ProductVariableID
    OFFSET (CONVERT(BIGINT, @i_pageNumber) - 1) * @RowsPerPage ROWS
    FETCH NEXT @RowsPerPage ROWS ONLY;

    SET @RowsReturned = @@ROWCOUNT;

    IF @RowsReturned > 0
    BEGIN
        SET @o_ResultCode = 200;
        SET @o_ResultMessage = 'Ofertas consultadas satisfactoriamente.';
    END
    ELSE
    BEGIN
        SET @o_ResultCode = 204;
        SET @o_ResultMessage = 'No hay ofertas activas en la pagina solicitada.';
    END;
END;
GO

DECLARE @OfferRuleId INT;

SELECT @OfferRuleId = ReglaID
FROM dbo.ReglasChatbot
WHERE AccionPython = 'buscar_ofertas_db';

IF @OfferRuleId IS NOT NULL
BEGIN
    DELETE FROM dbo.PlantillasRespuesta
    WHERE ReglaID = @OfferRuleId;

    INSERT INTO dbo.PlantillasRespuesta (ReglaID, TextoRespuesta, Activo)
    VALUES
        (@OfferRuleId, N'Estas son las ofertas activas disponibles en este momento.', 1),
        (@OfferRuleId, N'Encontre estos productos con descuento para ti.', 1),
        (@OfferRuleId, N'Estas promociones tienen precio reducido mientras sigan activas.', 1),
        (@OfferRuleId, N'Puedes agregar cualquiera de estas ofertas directamente al carrito.', 1),
        (@OfferRuleId, N'Revisa estas opciones con descuento y disponibilidad actual.', 1);
END;
GO

COMMIT TRANSACTION;
GO
