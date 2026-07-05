USE [DB_ECOMMERCE]
GO

CREATE OR ALTER VIEW [SQM_CATALOGS].[VW_PRODUCT_IDENTIFICATORS]
AS
SELECT
[PI].[productIdentificatorId],
[C].[categoryId],
[C].[categoryName],
[C].[categoryDescription],
[SC].[subCategoryId],
[SC].[subCategoryName],
[SC].[subCategoryDescription],
[S].[segmentId],
[S].[segmentName],
[S].[segmentDescription]
FROM [SQM_CATALOGS].[Tbl_ProductIdentificators] [PI]
INNER JOIN [SQM_CATALOGS].[Tbl_Categories] [C] ON [PI].[productIdentificatorCategoryId] = [C].[categoryId]
INNER JOIN [SQM_CATALOGS].[Tbl_SubCategories] [SC] ON [PI].[productIdentificatorSubCategoryId] = [SC].[subCategoryId]
INNER JOIN [SQM_CATALOGS].[Tbl_Segments] [S] ON [PI].[productIdentificatorSegmentId] = [S].[segmentId]
WHERE
	[C].[categoryStatusId] = 1 AND
	[SC].[subCategoryStatusId] = 1 AND
	[S].[segmentStatusId] = 1 AND
	[PI].[productIdentificatorStatusId] = 1
GO


