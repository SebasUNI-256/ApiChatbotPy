USE DB_ECOMMERCE
GO

DECLARE @QueryParameter VARCHAR(200)
SET @QueryParameter = '128'

IF ISNULL(@QueryParameter, '') = ''
BEGIN
	PRINT 'EL PARAMETRO DE BUSQUEDA NO PUEDE SER NULO'
END
ELSE
BEGIN

SELECT
	ProductID,
	ProductName,
	ProductVariableName,
	ProductVariablePrice,
	CurrencyISO,
	CategoryName,
	SubcategoryName,
	SegmentName,
	MarkName,
	ProviderName,
	SUM(StockAvilable) [StockAvilable]
FROM SQM_GENERAL.VW_GENERAL_PRODUCTS
WHERE
	ProductName LIKE CONCAT('%', @QueryParameter,'%') OR
	ProductVariableName LIKE CONCAT('%', @QueryParameter,'%') OR
	CategoryName LIKE CONCAT('%', @QueryParameter,'%')
GROUP BY 
	ProductID,
	ProductName,
	ProductVariableName,
	ProductVariablePrice,
	CurrencyISO,
	CategoryName,
	SubcategoryName,
	SegmentName,
	MarkName,
	ProviderName
END


/*
SELECT *
FROM [SQM_CATALOGS].[VW_PRODUCT_IDENTIFICATORS]

sp_tables
[SQM_GENERAL].[Tbl_CartDetails]
[SQM_GENERAL].[Tbl_PaymentOrderDetails]

UPDATE [SQM_GENERAL].[Tbl_Stocks]
SET stockFactoryDate = DATEADD(MONTH,1,stockFactoryDate),
	stockExpirationDate = DATEADD(MONTH,1,stockExpirationDate),
	stockCreationDate =  DATEADD(DAY,15,stockCreationDate)
WHERE stockId = 2

DECLARE @Products AS TABLE (
IDX INT IDENTITY(1,1),
STOCKID INT,
PRODUCTNAME VARCHAR(80),
STOCKAVILABLE INT,
STOCKEXPIRATIONDATE DATETIME
)

INSERT INTO @Products
SELECT
	StockId,
	ProductName,
	StockAvilable,
	StockExpirationDate
FROM SQM_GENERAL.VW_GENERAL_PRODUCTS
WHERE ProductVariableID = 2
ORDER BY StockExpirationDate ASC

SELECT *
FROM @Products
*/