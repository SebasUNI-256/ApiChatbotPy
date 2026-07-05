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
	SUM(StockAvidable) [StockAvidable]
FROM SQM_GENERAL.VW_GENERAL_PRODUCTS
WHERE
   ProductName LIKE CONCAT('%', @QueryParameter, '%') OR
   ProductVariableName LIKE CONCAT('%', @QueryParameter, '%') OR
   CategoryName LIKE CONCAT ('%', @QueryParameter , '%')
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
  

