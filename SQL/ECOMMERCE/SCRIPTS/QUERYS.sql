USE [DB_ECOMMERCE]
GO

OPEN SYMMETRIC KEY KEY_HASH
DECRYPTION BY CERTIFICATE CERT_ECOMMERCE;

SELECT
	U.userId,
	U.userName,
	SQM_SECURITY.Fn_DecryptByKey(U.userPassword) AS [userPasswordDecrypted],
	U.userPassword
FROM [SQM_SECURITY].[Tbl_Users] (NOLOCK)U

CLOSE SYMMETRIC KEY KEY_HASH;

SELECT *
FROM [SQM_GENERAL].[Tbl_UserAddress]

SELECT *
FROM [SQM_CATALOGS].[Tbl_Categories]

SELECT *
FROM [SQM_CATALOGS].[Tbl_SubCategories]

SELECT *
FROM [SQM_CATALOGS].[Tbl_Segments]

SELECT *
FROM [SQM_CATALOGS].[Tbl_ProductIdentificators]

SELECT *
FROM [SQM_CATALOGS].[Tbl_StockMovementTypes]

SELECT
	[PDI].[productIdentificatorId],
	[C].[categoryId],
	[C].categoryName,
	[SC].[subCategoryId],
	[SC].subCategoryName,
	[S].[segmentId],
	[S].segmentName
FROM [SQM_CATALOGS].[Tbl_ProductIdentificators] (NOLOCK) [PDI]
INNER JOIN [SQM_CATALOGS].[Tbl_Categories] (NOLOCK) [C] ON [PDI].productIdentificatorCategoryId = [C].categoryId
INNER JOIN [SQM_CATALOGS].[Tbl_SubCategories] (NOLOCK) [SC] ON [PDI].productIdentificatorSubCategoryId = [SC].subCategoryId
INNER JOIN [SQM_CATALOGS].[Tbl_Segments] (NOLOCK) [S] ON [PDI].productIdentificatorSegmentId = [S].segmentId

SELECT *
FROM [SQM_SECURITY].[Tbl_Roles]

SELECT *
FROM [SQM_SECURITY].[Tbl_TransactionTypes]

SELECT *
FROM [SQM_SECURITY].[Tbl_RolByTransactionTypes]

SELECT *
FROM [SQM_SECURITY].[Tbl_UserByRoles]