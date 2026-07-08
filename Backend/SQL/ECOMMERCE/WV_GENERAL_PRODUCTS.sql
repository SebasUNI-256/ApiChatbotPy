USE [DB_ECOMMERCE]
GO

CREATE OR ALTER VIEW [SQM_CATALOGS].[VW_PRODUCT_IDENTIFICATORS]
AS
SELECT
	PDI.productIdentificatorId [productIdentificatorId],
	C.categoryId [categoryId],
	C.categoryName [categoryName],
	SC.subCategoryId [subCategoryId],
	SC.subCategoryName [subCategoryName],
	S.segmentId [segmentId],
	S.segmentName [segmentName]
FROM [SQM_CATALOGS].[Tbl_ProductIdentificators] (NOLOCK) PDI
INNER JOIN [SQM_CATALOGS].[Tbl_Categories] (NOLOCK) C
	ON PDI.productIdentificatorCategoryId = C.categoryId
	AND C.categoryStatusId = 1
INNER JOIN [SQM_CATALOGS].[Tbl_SubCategories] (NOLOCK) SC
	ON PDI.productIdentificatorSubCategoryId = SC.subCategoryId
	AND SC.subCategoryStatusId = 1
INNER JOIN [SQM_CATALOGS].[Tbl_Segments] (NOLOCK) S
	ON PDI.productIdentificatorSegmentId = S.segmentId
	AND S.segmentStatusId = 1
WHERE PDI.productIdentificatorStatusId = 1
GO

CREATE OR ALTER VIEW [SQM_GENERAL].[VW_GENERAL_PRODUCTS]
AS
SELECT
	P.productId [ProductID],
	P.productName [ProductName],
	VP.productVariableId [ProductVariableID],
	VP.productVariableValue [ProductVariableName],
	VP.productVariablePrice [ProductVariablePrice],
	C.currencyId [CurrencyID],
	C.currencyISO [CurrencyISO],
	GP.categoryId [CategoryID],
	GP.categoryName [CategoryName],
	GP.subCategoryId [SubcategoryID],
	GP.subCategoryName [SubcategoryName],
	GP.segmentId [SegmentID],
	GP.segmentName [SegmentName],
	M.markId [MarkID],
	M.markName [MarkName],
	PR.providerId [ProviderID],
	PR.providerName [ProviderName],
	ST.stockId [StockID],
	ST.stockQuantity [StockAvailable],
	ST.stockFactoryDate [StockFactoryDate],
	ST.stockExpirationDate [StockExpirationDate]
FROM [SQM_GENERAL].[Tbl_Products] (NOLOCK) P
INNER JOIN [SQM_GENERAL].[Tbl_ProductVariables] (NOLOCK) VP
	ON P.productId = VP.productVariableProductId
	AND VP.productVariableStatusId = 1
INNER JOIN [SQM_CATALOGS].[Tbl_Currencies] (NOLOCK) C
	ON VP.productVariableCurrencyId = C.currencyId
	AND C.currencyStatusId = 1
INNER JOIN [SQM_CATALOGS].[VW_PRODUCT_IDENTIFICATORS] (NOLOCK) GP
	ON P.productProductIdentificatorId = GP.productIdentificatorId
INNER JOIN [SQM_CATALOGS].[Tbl_MarkByProviders] (NOLOCK) MxP
	ON P.productMarkByProviderId = MxP.markByProviderId
	AND MxP.markByProviderStatusId = 1
INNER JOIN [SQM_CATALOGS].[Tbl_Marks] (NOLOCK) M
	ON MxP.markByProviderMarkId = M.markId
	AND M.markStatusId = 1
INNER JOIN [SQM_CATALOGS].[Tbl_Providers] (NOLOCK) PR
	ON MxP.markByProviderProviderId = PR.providerId
	AND PR.providerStatusId = 1
INNER JOIN [SQM_GENERAL].[Tbl_Stocks] (NOLOCK) ST
	ON VP.productVariableId = ST.stockProductVariableId
	AND ST.stockStatusId = 1
WHERE P.productStatusId = 1
GO

CREATE OR ALTER VIEW [SQM_GENERAL].[WV_GENERAL_PRODUCTS]
AS
SELECT
	ProductID,
	ProductName,
	ProductVariableID,
	ProductVariableName,
	ProductVariablePrice,
	CurrencyID,
	CurrencyISO,
	CategoryID,
	CategoryName,
	SubcategoryID,
	SubcategoryName,
	SegmentID,
	SegmentName,
	MarkID,
	MarkName,
	ProviderID,
	ProviderName,
	StockID,
	StockAvailable,
	StockFactoryDate,
	StockExpirationDate
FROM [SQM_GENERAL].[VW_GENERAL_PRODUCTS]
GO
