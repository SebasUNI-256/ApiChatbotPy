-- Foro 3 - Instalador principal de ecommerce, autenticacion, carrito y pagos.
-- Seguro para volver a ejecutarse: crea solamente los objetos que faltan y actualiza procedimientos/vistas.
USE [master]
GO

IF DB_ID(N'DB_ECOMMERCE') IS NULL
BEGIN
    CREATE DATABASE [DB_ECOMMERCE];
END
GO

USE [DB_ECOMMERCE]
GO

IF SCHEMA_ID(N'SQM_GENERAL') IS NULL EXEC(N'CREATE SCHEMA [SQM_GENERAL]');
IF SCHEMA_ID(N'SQM_CATALOGS') IS NULL EXEC(N'CREATE SCHEMA [SQM_CATALOGS]');
IF SCHEMA_ID(N'SQM_SECURITY') IS NULL EXEC(N'CREATE SCHEMA [SQM_SECURITY]');
GO

IF OBJECT_ID(N'SQM_CATALOGS.Tbl_Status', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_CATALOGS].[Tbl_Status]
(
	statusId INT PRIMARY KEY IDENTITY (1,1),
	statusName VARCHAR(50) NOT NULL,
	statusCreatorId INT,
	statusCreationDate DATETIME NOT NULL,
	statusModificatorId INT,
	statusModificationDate DATETIME NULL,
	statusStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_SECURITY.Tbl_Users', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_SECURITY].[Tbl_Users]
(
	userId INT PRIMARY KEY IDENTITY (1,1),
	userFullName VARCHAR(100) NOT NULL,
	userName VARCHAR(50) NOT NULL,
	userPassword VARBINARY(256) NOT NULL,
	userEmail VARCHAR(80) NOT NULL,
	userPhoneNumber VARCHAR(20) NOT NULL,
	userCountryId INT NOT NULL,
	userGenderId INT NOT NULL,
	userBirthDay DATE NOT NULL,
	userCreatorId INT NOT NULL,
	userCreationDate DATETIME NOT NULL,
	userModificatorId INT NULL,
	userModificationDate DATETIME NULL,
	userStatusId INT REFERENCES [SQM_CATALOGS].[Tbl_Status](statusId) NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_GENERAL.Tbl_UserAddress', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_GENERAL].[Tbl_UserAddress]
(
	userAddressId INT PRIMARY KEY IDENTITY (1,1),
	userAddressUserId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
	userAddressCountryId INT NOT NULL,
	userAddressZIPCode INT NOT NULL,
	userAddressDescription NVARCHAR(500) NOT NULL,
	userAddressIsPrincipal BIT NOT NULL,
	userAddressCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	userAddressCreationDate DATETIME NOT NULL,
	userAddressModificatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
	userAddressModificationDate DATETIME NULL,
	userAddressStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_CATALOGS.Tbl_Categories', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_CATALOGS].[Tbl_Categories]
(
	categoryId INT PRIMARY KEY IDENTITY (1,1),
	categoryName VARCHAR(50) NOT NULL,
	categoryDescription VARCHAR(100) NOT NULL,
	categoryCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	categoryCreationDate DATETIME NOT NULL,
	categoryModificatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
	categoryModificationDate DATETIME NULL,
	categoryStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_CATALOGS.Tbl_SubCategories', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_CATALOGS].[Tbl_SubCategories]
(
	subCategoryId INT PRIMARY KEY IDENTITY (1,1),
	subCategoryName VARCHAR(50) NOT NULL,
	subCategoryDescription VARCHAR(100) NOT NULL,
	subCategoryCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	subCategoryCreationDate DATETIME NOT NULL,
	subCategoryModificatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
	subCategoryModificationDate DATETIME NULL,
	subCategoryStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_CATALOGS.Tbl_Segments', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_CATALOGS].[Tbl_Segments]
(
	segmentId INT PRIMARY KEY IDENTITY (1,1),
	segmentName VARCHAR(50) NOT NULL,
	segmentDescription VARCHAR(100) NOT NULL,
	segmentCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	segmentCreationDate DATETIME NOT NULL,
	segmentModificatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
	segmentModificationDate DATETIME NULL,
	segmentStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_CATALOGS.Tbl_ProductIdentificators', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_CATALOGS].[Tbl_ProductIdentificators]
(
	productIdentificatorId INT PRIMARY KEY IDENTITY(1,1),
	productIdentificatorCategoryId INT REFERENCES [SQM_CATALOGS].[Tbl_Categories](categoryId) NOT NULL,
	productIdentificatorSubCategoryId INT REFERENCES [SQM_CATALOGS].[Tbl_SubCategories](subCategoryId) NOT NULL,
	productIdentificatorSegmentId INT REFERENCES [SQM_CATALOGS].[Tbl_Segments](segmentId) NOT NULL,
	productIdentificatorCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	productIdentificatorCreationDate DATETIME NOT NULL,
	productIdentificatorModificatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
	productIdentificatorModificationDate DATETIME NULL,
	productIdentificatorStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_CATALOGS.Tbl_Providers', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_CATALOGS].[Tbl_Providers]
(
	providerId INT PRIMARY KEY IDENTITY (1,1),
	providerName VARCHAR(50) NOT NULL,
	providerDescription VARCHAR(100) NOT NULL,
	providerCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	providerCreationDate DATETIME NOT NULL,
	providerModificatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
	providerModificationDate DATETIME NULL,
	providerStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_CATALOGS.Tbl_Marks', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_CATALOGS].[Tbl_Marks]
(
	markId INT PRIMARY KEY IDENTITY (1,1),
	markName VARCHAR(50) NOT NULL,
	markDescription VARCHAR(100) NOT NULL,
	markCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	markCreationDate DATETIME NOT NULL,
	markModificatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
	markModificationDate DATETIME NULL,
	markStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_CATALOGS.Tbl_MarkByProviders', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_CATALOGS].[Tbl_MarkByProviders]
(
	markByProviderId INT PRIMARY KEY IDENTITY(1,1),
	markByProviderMarkId INT REFERENCES [SQM_CATALOGS].[Tbl_Marks](markId) NOT NULL,
	markByProviderProviderId INT REFERENCES [SQM_CATALOGS].[Tbl_Providers](providerId) NOT NULL,
	markByProviderCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	markByProviderCreationDate DATETIME NOT NULL,
	markByProviderModificatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
	markByProviderModificationDate DATETIME NULL,
	markByProviderStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_CATALOGS.Tbl_AttributesTypes', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_CATALOGS].[Tbl_AttributesTypes]
(
	attributeTypeId INT PRIMARY KEY IDENTITY (1,1),
	attributeTypeName VARCHAR(50) NOT NULL,
	attributeTypeDescription VARCHAR(100) NOT NULL,
	attributeTypeCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	attributeTypeCreationDate DATETIME NOT NULL,
	attributeTypeModificatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
	attributeTypeModificationDate DATETIME NULL,
	attributeTypeStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_CATALOGS.Tbl_Currencies', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_CATALOGS].[Tbl_Currencies]
(
	currencyId INT PRIMARY KEY IDENTITY (1,1),
	currencyName VARCHAR(50) NOT NULL,
	currencyISO CHAR(5) NOT NULL,
	currencyCode INT NOT NULL,
	currencyDescription VARCHAR(100) NOT NULL,
	currencyCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	currencyCreationDate DATETIME NOT NULL,
	currencyModificatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
	currencyModificationDate DATETIME NULL,
	currencyStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_GENERAL.Tbl_Products', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_GENERAL].[Tbl_Products]
(
	productId INT PRIMARY KEY IDENTITY (1,1),
	productName VARCHAR(50) NOT NULL,
	productDescription VARCHAR(200) NOT NULL,
	productProductIdentificatorId INT REFERENCES [SQM_CATALOGS].[Tbl_ProductIdentificators](productIdentificatorId) NOT NULL,
	productMarkByProviderId INT REFERENCES [SQM_CATALOGS].[Tbl_MarkByProviders](markByProviderId) NOT NULL,
	productCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	productCreationDate DATETIME NOT NULL,
	productModificatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
	productModificationDate DATETIME NULL,
	productStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_CATALOGS.Tbl_AttributeProducts', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_CATALOGS].[Tbl_AttributeProducts]
(
	AttributeProductId INT PRIMARY KEY IDENTITY (1,1),
	AttributeProductAttributesTypeId INT REFERENCES [SQM_CATALOGS].[Tbl_AttributesTypes](attributeTypeId) NOT NULL,
	AttributeProductName VARCHAR(50) NOT NULL,
	AttributeProductDescription VARCHAR(100) NOT NULL,
	AttributeProductCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	AttributeProductCreationDate DATETIME NOT NULL,
	AttributeProductModificatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
	AttributeProductModificationDate DATETIME NULL,
	AttributeProductStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_GENERAL.Tbl_ProductImages', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_GENERAL].[Tbl_ProductImages]
(
	productImageId INT PRIMARY KEY IDENTITY (1,1),
	productImageProductId INT REFERENCES [SQM_GENERAL].[Tbl_Products](productId) NOT NULL,
	productImageURL VARCHAR(200) NOT NULL,
	productImageDescription VARCHAR(100) NOT NULL,
	productImageIsPrincipal BIT NOT NULL,
	productImageCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	productImageCreationDate DATETIME NOT NULL,
	productImageModificatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
	productImageModificationDate DATETIME NULL,
	productImageStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_CATALOGS.Tbl_ProductVariableTypes', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_CATALOGS].[Tbl_ProductVariableTypes]
(
	productVariableTypeId INT PRIMARY KEY IDENTITY (1,1),
	productVariableTypeName VARCHAR(50) NOT NULL,
	productVariableTypeDescription VARCHAR(100) NOT NULL,
	productVariableTypeCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	productVariableTypeCreationDate DATETIME NOT NULL,
	productVariableTypeModificatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
	productVariableTypeModificationDate DATETIME NULL,
	productVariableTypeStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_GENERAL.Tbl_ProductVariables', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_GENERAL].[Tbl_ProductVariables]
(
	productVariableId INT PRIMARY KEY IDENTITY (1,1),
	productVariableProductId INT REFERENCES [SQM_GENERAL].[Tbl_Products](productId) NOT NULL,
	productVariableValue VARCHAR(50) NOT NULL,
	productVariablePrice DECIMAL(18,2) NOT NULL,
	productVariableCurrencyId INT REFERENCES [SQM_CATALOGS].[Tbl_Currencies](currencyId) NOT NULL,
	productVariableCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	productVariableCreationDate DATETIME NOT NULL,
	productVariableModificatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
	productVariableModificationDate DATETIME NULL,
	productVariableStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_GENERAL.Tbl_AttributeProductVariables', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_GENERAL].[Tbl_AttributeProductVariables]
(
	attributeProductVariableId INT PRIMARY KEY IDENTITY (1,1),
	attributeProductVariableProductVariableId INT REFERENCES [SQM_GENERAL].[Tbl_ProductVariables] NOT NULL,
	attributeProductVariableAttributeProductId INT REFERENCES [SQM_CATALOGS].[Tbl_ProductVariableTypes](productVariableTypeId) NOT NULL,
	attributeProductVariableValue VARCHAR(50) NOT NULL,
	attributeProductVariableCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	attributeProductVariableCreationDate DATETIME NOT NULL,
	attributeProductVariableModificatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
	attributeProductVariableModificationDate DATETIME NULL,
	attributeProductVariableStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_GENERAL.Tbl_Stocks', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_GENERAL].[Tbl_Stocks]
(
	stockId INT PRIMARY KEY IDENTITY (1,1),
	stockProductVariableId INT REFERENCES [SQM_GENERAL].[Tbl_ProductVariables](productVariableId) NOT NULL,
	stockQuantity INT NOT NULL,
	stockFactoryDate DATE NOT NULL,
	stockExpirationDate DATE NOT NULL,
	stockCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	stockCreationDate DATETIME NOT NULL,
	stockModificatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
	stockModificationDate DATETIME NULL,
	stockStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_GENERAL.Tbl_Carts', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_GENERAL].[Tbl_Carts]
(
	cartId INT PRIMARY KEY IDENTITY (1,1),
	cartUserId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	cartCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	cartCreationDate DATETIME NOT NULL,
	cartModificatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
	cartModificationDate DATETIME NULL,
	cartStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_GENERAL.Tbl_CartDetails', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_GENERAL].[Tbl_CartDetails]
(
	cartDetailId INT PRIMARY KEY IDENTITY (1,1),
	cartDetailCartId INT REFERENCES [SQM_GENERAL].[Tbl_Carts](cartId) NOT NULL,
	cartDetailProductVariableId INT REFERENCES [SQM_GENERAL].[Tbl_ProductVariables](productVariableId) NOT NULL,
	cartDetailPrice DECIMAL(18,2) NOT NULL,
	cartDetailQuantity INT NOT NULL,
	cartDetailDiscount DECIMAL(18,2) NOT NULL,
	cartDetailSubTotal DECIMAL(18,2) NOT NULL,
	cartDetailTAX DECIMAL(18,2) NOT NULL,
	cartDetailTotal DECIMAL(18,2) NOT NULL,
	cartDetailCurrencyId INT REFERENCES [SQM_CATALOGS].[Tbl_Currencies](currencyId) NOT NULL,
	cartDetailCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	cartDetailCreationDate DATETIME NOT NULL,
	cartDetailModificatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
	cartDetailModificationDate DATETIME NULL,
	cartDetailStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_CATALOGS.Tbl_PaymentMethodTypes', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_CATALOGS].[Tbl_PaymentMethodTypes]
(
	paymentMethodTypeId INT PRIMARY KEY IDENTITY (1,1),
	paymentMethodTypeName VARCHAR(50) NOT NULL,
	paymentMethodTypeDescription VARCHAR(100) NOT NULL,
	paymentMethodTypeCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	paymentMethodTypeCreationDate DATETIME NOT NULL,
	paymentMethodTypeModificatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
	paymentMethodTypeModificationDate DATETIME NULL,
	paymentMethodTypeStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_GENERAL.Tbl_UserPaymentMethods', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_GENERAL].[Tbl_UserPaymentMethods]
(
	userPaymentMethodId INT PRIMARY KEY IDENTITY (1,1),
	userPaymentMethodUserId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	userPaymentMethodPaymentMethodTypeId INT REFERENCES [SQM_CATALOGS].[Tbl_PaymentMethodTypes](paymentMethodTypeId) NOT NULL,
	userPaymentMethodCardNumber VARBINARY(256) NOT NULL,
	userPaymentMethodExpirationDate VARBINARY(256) NOT NULL,
	userPaymentMethodCVV VARBINARY(256) NOT NULL,
	userPaymentMethodCardHolderName VARCHAR(100) NOT NULL,
	userPaymentMethodCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	userPaymentMethodCreationDate DATETIME NOT NULL,
	userPaymentMethodModificatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
	userPaymentMethodModificationDate DATETIME NULL,
	userPaymentMethodStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_GENERAL.Tbl_PaymentOrders', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_GENERAL].[Tbl_PaymentOrders]
(
	orderId INT PRIMARY KEY IDENTITY (1,1),
	orderUserId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	orderDeliveryAddress INT REFERENCES [SQM_GENERAL].[Tbl_UserAddress](userAddressId) NOT NULL,
	orderPaymentMethodId INT REFERENCES [SQM_GENERAL].[Tbl_UserPaymentMethods](userPaymentMethodId) NOT NULL,
	orderSubtotal DECIMAL(18,2) NOT NULL,
	orderDiscount DECIMAL(18,2) NOT NULL,
	orderShipping DECIMAL(18,2) NOT NULL,
	orderTAX DECIMAL(18,2) NOT NULL,
	orderTotal DECIMAL(18,2) NOT NULL,
	orderCurrencyId INT REFERENCES [SQM_CATALOGS].[Tbl_Currencies](currencyId) NOT NULL,
	orderCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	orderCreationDate DATETIME NOT NULL,
	orderModificatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
	orderModificationDate DATETIME NULL,
	orderStatusId INT REFERENCES [SQM_CATALOGS].[Tbl_Status](statusId) NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_GENERAL.Tbl_PaymentOrderDetails', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_GENERAL].[Tbl_PaymentOrderDetails]
(
	orderDetailId INT PRIMARY KEY IDENTITY (1,1),
	orderDetailOrderId INT REFERENCES [SQM_GENERAL].[Tbl_PaymentOrders](orderId) NOT NULL,
	orderDetailProductVariableId INT REFERENCES [SQM_GENERAL].[Tbl_ProductVariables](productVariableId) NOT NULL,
	orderDetailPrice DECIMAL(18,2) NOT NULL,
	orderDetailQuantity INT NOT NULL,
	orderDetailDiscount DECIMAL(18,2) NOT NULL,
	orderDetailSubTotal DECIMAL(18,2) NOT NULL,
	orderDetailTAX DECIMAL(18,2) NOT NULL,
	orderDetailTotal DECIMAL(18,2) NOT NULL,
	orderDetailCurrencyId INT REFERENCES [SQM_CATALOGS].[Tbl_Currencies](currencyId) NOT NULL,
	orderDetailCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	orderDetailCreationDate DATETIME NOT NULL,
	orderDetailModificatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
	orderDetailModificationDate DATETIME NULL,
	orderDetailStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_CATALOGS.Tbl_StockMovementTypes', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_CATALOGS].[Tbl_StockMovementTypes]
(
	stockMovementTypeId INT PRIMARY KEY IDENTITY (1,1),
	stockMovementTypeName VARCHAR(50) NOT NULL,
	stockMovementTypeDescription VARCHAR(100) NOT NULL,
	stockMovementTypeCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
	stockMovementTypeCreationDate DATETIME NOT NULL,
	stockMovementTypeModificatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
	stockMovementTypeModificationDate DATETIME NULL,
	stockMovementTypeStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_GENERAL.Tbl_StockMovements', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_GENERAL].[Tbl_StockMovements]
(
    stockMovementId INT PRIMARY KEY IDENTITY(1,1),
    stockMovementTypeId INT REFERENCES [SQM_CATALOGS].[Tbl_StockMovementTypes](stockMovementTypeId) NOT NULL,
    stockMovementOrderId INT REFERENCES [SQM_GENERAL].[Tbl_PaymentOrders](orderId), -- FK to order
    stockMovementReference NVARCHAR(100),
    stockMovementCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
    stockMovementCreationDate DATETIME NOT NULL,
    stockMovementModifierId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
    stockMovementModificationDate DATETIME NULL,
    stockMovementStatusId INT REFERENCES [SQM_CATALOGS].[Tbl_Status](statusId) NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_GENERAL.Tbl_StockMovementDetails', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_GENERAL].[Tbl_StockMovementDetails]
(
    stockMovementDetailId INT PRIMARY KEY IDENTITY(1,1),
    stockMovementDetailMovementId INT REFERENCES [SQM_GENERAL].[Tbl_StockMovements](stockMovementId) NOT NULL,
    stockMovementDetailOrderDetailId INT REFERENCES [SQM_GENERAL].[Tbl_PaymentOrderDetails](orderDetailId) NULL,
    stockMovementDetailProductVariableId INT REFERENCES [SQM_GENERAL].[Tbl_ProductVariables](productVariableId) NULL,
	stockMovementDetailStockId INT REFERENCES [SQM_GENERAL].[Tbl_Stocks](stockId) NULL,
    stockMovementDetailQuantity INT NOT NULL,
	stockMovementDetailFactoryDate DATE NULL,
	stockMovementDetailExpirationDate DATE NULL,
    stockMovementDetailCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
    stockMovementDetailCreationDate DATETIME NOT NULL,
    stockMovementDetailModifierId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
    stockMovementDetailModificationDate DATETIME NULL,
    stockMovementDetailStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_SECURITY.Tbl_Roles', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_SECURITY].[Tbl_Roles]
(
	RolId INT PRIMARY KEY IDENTITY(1,1),
	RolName VARCHAR(50) NOT NULL,
	RolDescription VARCHAR(255) NOT NULL,
	RolCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
    RolCreationDate DATETIME NOT NULL,
    RolModifierId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
    RolModificationDate DATETIME NULL,
    RolStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_SECURITY.Tbl_TransactionTypes', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_SECURITY].[Tbl_TransactionTypes]
(
	TransactionTypeId INT PRIMARY KEY IDENTITY(1,1),
	TransactionTypeName VARCHAR(50) NOT NULL,
	TransactionTypeDescription VARCHAR(255) NOT NULL,
	TransactionTypeCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
    TransactionTypeCreationDate DATETIME NOT NULL,
    TransactionTypeModifierId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
    TransactionTypeModificationDate DATETIME NULL,
    TransactionTypeStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_SECURITY.Tbl_RolByTransactionTypes', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_SECURITY].[Tbl_RolByTransactionTypes]
(
	RolByTransactionTypeId INT PRIMARY KEY IDENTITY(1,1),
	RolByTransactionRolId INT REFERENCES [SQM_SECURITY].[Tbl_Roles](RolId) NOT NULL,
	RolByTransactionTransactionTypeId INT REFERENCES [SQM_SECURITY].[Tbl_TransactionTypes](TransactionTypeId) NOT NULL,
	RolByTransactionTypeCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
    RolByTransactionTypeCreationDate DATETIME NOT NULL,
    RolByTransactionTypeModifierId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
    RolByTransactionTypeModificationDate DATETIME NULL,
    RolByTransactionTypeStatusId BIT NOT NULL
);
END
GO

IF OBJECT_ID(N'SQM_SECURITY.Tbl_UserByRoles', N'U') IS NULL
BEGIN
CREATE TABLE [SQM_SECURITY].[Tbl_UserByRoles]
(
	UserByRolId INT PRIMARY KEY IDENTITY(1,1),
	UserByRolRolId INT REFERENCES [SQM_SECURITY].[Tbl_Roles](RolId) NOT NULL,
	UserByRolUserId INT REFERENCES [SQM_SECURITY].[Tbl_Users](UserId) NOT NULL,
	UserByRolTypeCreatorId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId) NOT NULL,
    UserByRolTypeCreationDate DATETIME NOT NULL,
    UserByRolTypeModifierId INT REFERENCES [SQM_SECURITY].[Tbl_Users](userId),
    UserByRolTypeModificationDate DATETIME NULL,
    UserByRolTypeStatusId BIT NOT NULL
);
END
GO

USE [DB_ECOMMERCE]
GO
--------------------------------------
/* ENCRIPTADO CON LLAVE SIMETRICA   */
--------------------------------------

--------------------------------------
/* CLAVE MAESTRA DE BASE DE DATOS   */
--------------------------------------
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Ecommerce2026!';
END

--------------------------------------
/* CERTIFICADO DE ENCRIPTION        */
--------------------------------------
IF NOT EXISTS (SELECT * FROM sys.certificates WHERE name = 'CERT_ECOMMERCE')
BEGIN
    CREATE CERTIFICATE CERT_ECOMMERCE
    WITH SUBJECT = 'Certificado de protección para la clave simétrica';
END

--------------------------------------
/* CLAVE SIMETRICA                  */
--------------------------------------
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'KEY_HASH')
BEGIN
    CREATE SYMMETRIC KEY KEY_HASH
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE CERT_ECOMMERCE;
END

USE [DB_ECOMMERCE]
GO

--------------------------------------
/* FUNCION ESCALAR PARA ENCRIPTADO  */
--------------------------------------
CREATE OR ALTER FUNCTION [SQM_SECURITY].Fn_EncryptByKey
(
	@UnencryptedValue VARCHAR(256)
)
RETURNS VARBINARY(256)
AS
BEGIN
	DECLARE @EncryptedValue VARBINARY(256);

		SET @EncryptedValue = ENCRYPTBYKEY(KEY_GUID('KEY_HASH'), @UnencryptedValue);

	RETURN @EncryptedValue;
END
GO

USE [DB_ECOMMERCE]
GO

----------------------------------------
/* FUNCION ESCALAR PARA DESENCRIPTADO */
----------------------------------------
CREATE OR ALTER FUNCTION [SQM_SECURITY].Fn_DecryptByKey
(
	@EncryptedValue VARBINARY(256)
)
RETURNS VARCHAR(256)
AS
BEGIN
	DECLARE @UnencryptedValue VARCHAR(256);

		SET @UnencryptedValue = CONVERT(VARCHAR(256), DECRYPTBYKEY(@EncryptedValue));

	RETURN @UnencryptedValue;
END
GO

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

-- Datos internos minimos requeridos por los procedimientos de autenticacion.
IF NOT EXISTS
(
    SELECT 1 FROM SQM_CATALOGS.Tbl_Status
    WHERE UPPER(statusName) = 'ACTIVO' AND statusStatusId = 1
)
BEGIN
    INSERT INTO SQM_CATALOGS.Tbl_Status
        (statusName, statusCreatorId, statusCreationDate, statusStatusId)
    VALUES ('ACTIVO', 1, GETDATE(), 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM SQM_SECURITY.Tbl_Users WHERE userId = 1)
BEGIN
    DECLARE @EstadoActivoSistema INT =
    (
        SELECT TOP (1) statusId
        FROM SQM_CATALOGS.Tbl_Status
        WHERE UPPER(statusName) = 'ACTIVO' AND statusStatusId = 1
        ORDER BY statusId
    );

    OPEN SYMMETRIC KEY KEY_HASH
        DECRYPTION BY CERTIFICATE CERT_ECOMMERCE;

    SET IDENTITY_INSERT SQM_SECURITY.Tbl_Users ON;
    INSERT INTO SQM_SECURITY.Tbl_Users
    (
        userId, userFullName, userName, userPassword, userEmail,
        userPhoneNumber, userCountryId, userGenderId, userBirthDay,
        userCreatorId, userCreationDate, userStatusId
    )
    VALUES
    (
        1, 'USUARIO INTERNO DEL SISTEMA', 'SISTEMA',
        SQM_SECURITY.Fn_EncryptByKey('SistemaInterno-NoUsarParaLogin'),
        'sistema@foro3.local', '00000000', 1, 1, '2000-01-01',
        1, GETDATE(), @EstadoActivoSistema
    );
    SET IDENTITY_INSERT SQM_SECURITY.Tbl_Users OFF;

    CLOSE SYMMETRIC KEY KEY_HASH;
END
GO

USE [DB_ECOMMERCE]
GO

IF EXISTS
(
    SELECT userName
    FROM SQM_SECURITY.Tbl_Users
    GROUP BY userName
    HAVING COUNT(*) > 1
)
    THROW 50001, 'No se puede crear UX_Tbl_Users_UserName: existen usuarios duplicados.', 1;
GO

IF EXISTS
(
    SELECT userEmail
    FROM SQM_SECURITY.Tbl_Users
    GROUP BY userEmail
    HAVING COUNT(*) > 1
)
    THROW 50002, 'No se puede crear UX_Tbl_Users_UserEmail: existen correos duplicados.', 1;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_Tbl_Users_UserName'
      AND object_id = OBJECT_ID('SQM_SECURITY.Tbl_Users')
)
    CREATE UNIQUE INDEX UX_Tbl_Users_UserName
        ON SQM_SECURITY.Tbl_Users(userName);
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_Tbl_Users_UserEmail'
      AND object_id = OBJECT_ID('SQM_SECURITY.Tbl_Users')
)
    CREATE UNIQUE INDEX UX_Tbl_Users_UserEmail
        ON SQM_SECURITY.Tbl_Users(userEmail);
GO

IF NOT EXISTS
(
    SELECT 1
    FROM SQM_SECURITY.Tbl_Roles
    WHERE UPPER(RolName) = 'CLIENTE'
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM SQM_SECURITY.Tbl_Users WHERE userId = 1)
        THROW 50003, 'No se puede crear el rol CLIENTE: no existe el usuario interno con ID 1.', 1;

    INSERT INTO SQM_SECURITY.Tbl_Roles
    (
        RolName, RolDescription, RolCreatorId, RolCreationDate, RolStatusId
    )
    VALUES
    (
        'CLIENTE', 'Compras, carrito y consulta de sus ordenes', 1, GETDATE(), 1
    );
END
GO

CREATE OR ALTER PROCEDURE SQM_SECURITY.sp_ObtenerUsuarioSesion
    @UsuarioID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)
        U.userId AS id,
        U.userName AS username,
        U.userFullName AS fullName,
        U.userEmail AS email,
        R.RolName AS role
    FROM SQM_SECURITY.Tbl_Users U
    INNER JOIN SQM_CATALOGS.Tbl_Status S ON S.statusId = U.userStatusId
    LEFT JOIN SQM_SECURITY.Tbl_UserByRoles UR
        ON UR.UserByRolUserId = U.userId AND UR.UserByRolTypeStatusId = 1
    LEFT JOIN SQM_SECURITY.Tbl_Roles R
        ON R.RolId = UR.UserByRolRolId AND R.RolStatusId = 1
    WHERE U.userId = @UsuarioID
      AND UPPER(S.statusName) = 'ACTIVO'
      AND S.statusStatusId = 1
    ORDER BY R.RolId;
END
GO

CREATE OR ALTER PROCEDURE SQM_SECURITY.sp_RegistrarCliente
    @NombreCompleto VARCHAR(100),
    @NombreUsuario VARCHAR(50),
    @Correo VARCHAR(80),
    @Contrasena VARCHAR(256),
    @Telefono VARCHAR(20),
    @PaisID INT,
    @GeneroID INT,
    @FechaNacimiento DATE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @NombreCompleto = LTRIM(RTRIM(@NombreCompleto));
    SET @NombreUsuario = UPPER(LTRIM(RTRIM(@NombreUsuario)));
    SET @Correo = LOWER(LTRIM(RTRIM(@Correo)));
    SET @Telefono = LTRIM(RTRIM(@Telefono));

    IF EXISTS (SELECT 1 FROM SQM_SECURITY.Tbl_Users WHERE userName = @NombreUsuario)
        THROW 50011, '[DUPLICATE_USERNAME] El nombre de usuario ya esta registrado.', 1;

    IF EXISTS (SELECT 1 FROM SQM_SECURITY.Tbl_Users WHERE userEmail = @Correo)
        THROW 50012, '[DUPLICATE_EMAIL] El correo ya esta registrado.', 1;

    DECLARE @EstadoActivoID INT =
    (
        SELECT TOP (1) statusId
        FROM SQM_CATALOGS.Tbl_Status
        WHERE UPPER(statusName) = 'ACTIVO' AND statusStatusId = 1
        ORDER BY statusId
    );
    DECLARE @RolClienteID INT =
    (
        SELECT TOP (1) RolId
        FROM SQM_SECURITY.Tbl_Roles
        WHERE UPPER(RolName) = 'CLIENTE' AND RolStatusId = 1
        ORDER BY RolId
    );

    IF @EstadoActivoID IS NULL
        THROW 50013, '[MISSING_ACTIVE_STATUS] No existe el estado ACTIVO.', 1;
    IF @RolClienteID IS NULL
        THROW 50014, '[MISSING_CLIENT_ROLE] No existe el rol CLIENTE.', 1;
    IF NOT EXISTS (SELECT 1 FROM SQM_SECURITY.Tbl_Users WHERE userId = 1)
        THROW 50015, '[MISSING_SYSTEM_USER] No existe el usuario interno con ID 1.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        OPEN SYMMETRIC KEY KEY_HASH
            DECRYPTION BY CERTIFICATE CERT_ECOMMERCE;

        INSERT INTO SQM_SECURITY.Tbl_Users
        (
            userFullName, userName, userPassword, userEmail, userPhoneNumber,
            userCountryId, userGenderId, userBirthDay, userCreatorId,
            userCreationDate, userStatusId
        )
        VALUES
        (
            @NombreCompleto, @NombreUsuario,
            SQM_SECURITY.Fn_EncryptByKey(@Contrasena), @Correo, @Telefono,
            @PaisID, @GeneroID, @FechaNacimiento, 1, GETDATE(), @EstadoActivoID
        );

        CLOSE SYMMETRIC KEY KEY_HASH;

        DECLARE @UsuarioID INT = CONVERT(INT, SCOPE_IDENTITY());

        INSERT INTO SQM_SECURITY.Tbl_UserByRoles
        (
            UserByRolRolId, UserByRolUserId, UserByRolTypeCreatorId,
            UserByRolTypeCreationDate, UserByRolTypeStatusId
        )
        VALUES (@RolClienteID, @UsuarioID, @UsuarioID, GETDATE(), 1);

        COMMIT TRANSACTION;

        EXEC SQM_SECURITY.sp_ObtenerUsuarioSesion @UsuarioID = @UsuarioID;
    END TRY
    BEGIN CATCH
        IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'KEY_HASH')
            CLOSE SYMMETRIC KEY KEY_HASH;
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE SQM_SECURITY.sp_IniciarSesion
    @Identificador VARCHAR(80),
    @Contrasena VARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UsuarioID INT;

    OPEN SYMMETRIC KEY KEY_HASH
        DECRYPTION BY CERTIFICATE CERT_ECOMMERCE;

    SELECT TOP (1) @UsuarioID = U.userId
    FROM SQM_SECURITY.Tbl_Users U
    INNER JOIN SQM_CATALOGS.Tbl_Status S ON S.statusId = U.userStatusId
    WHERE (U.userName = UPPER(LTRIM(RTRIM(@Identificador)))
           OR U.userEmail = LOWER(LTRIM(RTRIM(@Identificador))))
      AND SQM_SECURITY.Fn_DecryptByKey(U.userPassword) = @Contrasena
      AND UPPER(S.statusName) = 'ACTIVO'
      AND S.statusStatusId = 1;

    CLOSE SYMMETRIC KEY KEY_HASH;

    IF @UsuarioID IS NOT NULL
        EXEC SQM_SECURITY.sp_ObtenerUsuarioSesion @UsuarioID = @UsuarioID;
END
GO

USE [DB_ECOMMERCE]
GO

CREATE OR ALTER PROCEDURE dbo.SP_AgregarProductoCarrito
(
    @UsuarioId INT,
    @ProductoVariableId INT,
    @Cantidad INT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @Cantidad <= 0
    BEGIN
        SELECT 400 AS ResultCode, N'La cantidad debe ser mayor que cero.' AS ResultMessage;
        RETURN;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM SQM_SECURITY.Tbl_Users
        WHERE userId = @UsuarioId
          AND userStatusId = 1
    )
    BEGIN
        SELECT 404 AS ResultCode, N'Usuario no encontrado o inactivo.' AS ResultMessage;
        RETURN;
    END;

    DECLARE @CartId INT;
    DECLARE @CartDetailId INT;
    DECLARE @Precio DECIMAL(18,2);
    DECLARE @MonedaId INT;
    DECLARE @CantidadActual INT = 0;
    DECLARE @StockDisponible INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT
            @Precio = productVariablePrice,
            @MonedaId = productVariableCurrencyId
        FROM SQM_GENERAL.Tbl_ProductVariables WITH (UPDLOCK, HOLDLOCK)
        WHERE productVariableId = @ProductoVariableId
          AND productVariableStatusId = 1;

        IF @MonedaId IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 404 AS ResultCode, N'Producto no encontrado o inactivo.' AS ResultMessage;
            RETURN;
        END;

        SELECT @StockDisponible = ISNULL(SUM(stockQuantity), 0)
        FROM SQM_GENERAL.Tbl_Stocks WITH (UPDLOCK, HOLDLOCK)
        WHERE stockProductVariableId = @ProductoVariableId
          AND stockStatusId = 1;

        SELECT TOP (1) @CartId = cartId
        FROM SQM_GENERAL.Tbl_Carts WITH (UPDLOCK, HOLDLOCK)
        WHERE cartUserId = @UsuarioId
          AND cartStatusId = 1
        ORDER BY cartId DESC;

        IF @CartId IS NULL
        BEGIN
            INSERT INTO SQM_GENERAL.Tbl_Carts
            (
                cartUserId,
                cartCreatorId,
                cartCreationDate,
                cartStatusId
            )
            VALUES
            (
                @UsuarioId,
                @UsuarioId,
                GETDATE(),
                1
            );

            SET @CartId = CONVERT(INT, SCOPE_IDENTITY());
        END;

        SELECT TOP (1)
            @CartDetailId = cartDetailId,
            @CantidadActual = cartDetailQuantity
        FROM SQM_GENERAL.Tbl_CartDetails WITH (UPDLOCK, HOLDLOCK)
        WHERE cartDetailCartId = @CartId
          AND cartDetailProductVariableId = @ProductoVariableId
          AND cartDetailStatusId = 1
        ORDER BY cartDetailId DESC;

        IF @CantidadActual + @Cantidad > @StockDisponible
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 409 AS ResultCode, N'No hay existencias suficientes para esa cantidad.' AS ResultMessage;
            RETURN;
        END;

        IF @CartDetailId IS NULL
        BEGIN
            INSERT INTO SQM_GENERAL.Tbl_CartDetails
            (
                cartDetailCartId,
                cartDetailProductVariableId,
                cartDetailPrice,
                cartDetailQuantity,
                cartDetailDiscount,
                cartDetailSubTotal,
                cartDetailTAX,
                cartDetailTotal,
                cartDetailCurrencyId,
                cartDetailCreatorId,
                cartDetailCreationDate,
                cartDetailStatusId
            )
            VALUES
            (
                @CartId,
                @ProductoVariableId,
                @Precio,
                @Cantidad,
                0,
                @Precio * @Cantidad,
                0,
                @Precio * @Cantidad,
                @MonedaId,
                @UsuarioId,
                GETDATE(),
                1
            );

            SET @CartDetailId = CONVERT(INT, SCOPE_IDENTITY());
        END
        ELSE
        BEGIN
            UPDATE SQM_GENERAL.Tbl_CartDetails
            SET cartDetailPrice = @Precio,
                cartDetailQuantity = @CantidadActual + @Cantidad,
                cartDetailSubTotal = @Precio * (@CantidadActual + @Cantidad),
                cartDetailTotal = @Precio * (@CantidadActual + @Cantidad),
                cartDetailCurrencyId = @MonedaId,
                cartDetailModificatorId = @UsuarioId,
                cartDetailModificationDate = GETDATE()
            WHERE cartDetailId = @CartDetailId;
        END;

        COMMIT TRANSACTION;

        SELECT
            200 AS ResultCode,
            N'Producto agregado correctamente.' AS ResultMessage,
            @CartDetailId AS CartDetailId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END
GO

CREATE OR ALTER PROCEDURE dbo.SP_ConsultarCarrito
(
    @UsuarioId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CartId INT;

    SELECT TOP (1) @CartId = cartId
    FROM SQM_GENERAL.Tbl_Carts
    WHERE cartUserId = @UsuarioId
      AND cartStatusId = 1
    ORDER BY cartId DESC;

    SELECT 200 AS ResultCode, N'Carrito consultado correctamente.' AS ResultMessage;

    SELECT
        CD.cartDetailId,
        CD.cartDetailProductVariableId AS productVariableId,
        P.productName,
        PV.productVariableValue,
        CD.cartDetailQuantity AS quantity,
        CD.cartDetailPrice AS unitPrice,
        CD.cartDetailTotal AS total,
        CD.cartDetailCurrencyId AS currencyId
    FROM SQM_GENERAL.Tbl_CartDetails CD
    INNER JOIN SQM_GENERAL.Tbl_ProductVariables PV
        ON PV.productVariableId = CD.cartDetailProductVariableId
    INNER JOIN SQM_GENERAL.Tbl_Products P
        ON P.productId = PV.productVariableProductId
    WHERE CD.cartDetailCartId = @CartId
      AND CD.cartDetailStatusId = 1
    ORDER BY CD.cartDetailId;
END
GO

CREATE OR ALTER PROCEDURE dbo.SP_EliminarProductoCarrito
(
    @UsuarioId INT,
    @CartDetailId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE CD
    SET cartDetailStatusId = 0,
        cartDetailModificatorId = @UsuarioId,
        cartDetailModificationDate = GETDATE()
    FROM SQM_GENERAL.Tbl_CartDetails CD
    INNER JOIN SQM_GENERAL.Tbl_Carts C
        ON C.cartId = CD.cartDetailCartId
    WHERE CD.cartDetailId = @CartDetailId
      AND CD.cartDetailStatusId = 1
      AND C.cartUserId = @UsuarioId
      AND C.cartStatusId = 1;

    IF @@ROWCOUNT = 0
    BEGIN
        SELECT 404 AS ResultCode, N'Producto no encontrado en el carrito activo.' AS ResultMessage;
        RETURN;
    END;

    SELECT 200 AS ResultCode, N'Producto eliminado del carrito.' AS ResultMessage;
END
GO

CREATE OR ALTER PROCEDURE dbo.SP_ProcesarPagoCarrito
(
    @UsuarioId INT,
    @DireccionId INT,
    @MetodoPagoId INT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM SQM_GENERAL.Tbl_UserAddress
        WHERE userAddressId = @DireccionId
          AND userAddressUserId = @UsuarioId
          AND userAddressStatusId = 1
    )
    BEGIN
        SELECT 404 AS ResultCode, N'Direccion de entrega no encontrada.' AS ResultMessage;
        RETURN;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM SQM_GENERAL.Tbl_UserPaymentMethods
        WHERE userPaymentMethodId = @MetodoPagoId
          AND userPaymentMethodUserId = @UsuarioId
          AND userPaymentMethodStatusId = 1
    )
    BEGIN
        SELECT 404 AS ResultCode, N'Metodo de pago no encontrado.' AS ResultMessage;
        RETURN;
    END;

    DECLARE @CartId INT;
    DECLARE @Subtotal DECIMAL(18,2);
    DECLARE @Total DECIMAL(18,2);
    DECLARE @MonedaId INT;
    DECLARE @OrderId INT;
    DECLARE @OrderStatusId INT;
    DECLARE @ExpectedStockRows INT;

    SELECT TOP (1) @OrderStatusId = statusId
    FROM SQM_CATALOGS.Tbl_Status
    WHERE statusName = 'PROCESADO'
      AND statusStatusId = 1
    ORDER BY statusId;

    IF @OrderStatusId IS NULL
    BEGIN
        SELECT 500 AS ResultCode, N'No existe el estado PROCESADO para crear la orden.' AS ResultMessage;
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT TOP (1) @CartId = cartId
        FROM SQM_GENERAL.Tbl_Carts WITH (UPDLOCK, HOLDLOCK)
        WHERE cartUserId = @UsuarioId
          AND cartStatusId = 1
        ORDER BY cartId DESC;

        IF @CartId IS NULL OR NOT EXISTS
        (
            SELECT 1
            FROM SQM_GENERAL.Tbl_CartDetails
            WHERE cartDetailCartId = @CartId
              AND cartDetailStatusId = 1
        )
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 409 AS ResultCode, N'El carrito esta vacio.' AS ResultMessage;
            RETURN;
        END;

        IF
        (
            SELECT COUNT(DISTINCT cartDetailCurrencyId)
            FROM SQM_GENERAL.Tbl_CartDetails
            WHERE cartDetailCartId = @CartId
              AND cartDetailStatusId = 1
        ) > 1
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 409 AS ResultCode, N'El carrito contiene productos con monedas diferentes.' AS ResultMessage;
            RETURN;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM
            (
                SELECT cartDetailProductVariableId, SUM(cartDetailQuantity) AS Quantity
                FROM SQM_GENERAL.Tbl_CartDetails
                WHERE cartDetailCartId = @CartId
                  AND cartDetailStatusId = 1
                GROUP BY cartDetailProductVariableId
            ) D
            WHERE NOT EXISTS
            (
                SELECT 1
                FROM SQM_GENERAL.Tbl_Stocks S WITH (UPDLOCK, HOLDLOCK)
                WHERE S.stockProductVariableId = D.cartDetailProductVariableId
                  AND S.stockStatusId = 1
                  AND S.stockQuantity >= D.Quantity
            )
        )
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 409 AS ResultCode, N'El stock cambio y ya no alcanza para completar la compra.' AS ResultMessage;
            RETURN;
        END;

        SELECT
            @Subtotal = SUM(cartDetailSubTotal),
            @Total = SUM(cartDetailTotal),
            @MonedaId = MIN(cartDetailCurrencyId)
        FROM SQM_GENERAL.Tbl_CartDetails
        WHERE cartDetailCartId = @CartId
          AND cartDetailStatusId = 1;

        INSERT INTO SQM_GENERAL.Tbl_PaymentOrders
        (
            orderUserId,
            orderDeliveryAddress,
            orderPaymentMethodId,
            orderSubtotal,
            orderDiscount,
            orderShipping,
            orderTAX,
            orderTotal,
            orderCurrencyId,
            orderCreatorId,
            orderCreationDate,
            orderStatusId
        )
        VALUES
        (
            @UsuarioId,
            @DireccionId,
            @MetodoPagoId,
            @Subtotal,
            0,
            0,
            0,
            @Total,
            @MonedaId,
            @UsuarioId,
            GETDATE(),
            @OrderStatusId
        );

        SET @OrderId = CONVERT(INT, SCOPE_IDENTITY());

        INSERT INTO SQM_GENERAL.Tbl_PaymentOrderDetails
        (
            orderDetailOrderId,
            orderDetailProductVariableId,
            orderDetailPrice,
            orderDetailQuantity,
            orderDetailDiscount,
            orderDetailSubTotal,
            orderDetailTAX,
            orderDetailTotal,
            orderDetailCurrencyId,
            orderDetailCreatorId,
            orderDetailCreationDate,
            orderDetailStatusId
        )
        SELECT
            @OrderId,
            cartDetailProductVariableId,
            cartDetailPrice,
            cartDetailQuantity,
            cartDetailDiscount,
            cartDetailSubTotal,
            cartDetailTAX,
            cartDetailTotal,
            cartDetailCurrencyId,
            @UsuarioId,
            GETDATE(),
            1
        FROM SQM_GENERAL.Tbl_CartDetails
        WHERE cartDetailCartId = @CartId
          AND cartDetailStatusId = 1;

        SELECT @ExpectedStockRows = COUNT(*)
        FROM
        (
            SELECT cartDetailProductVariableId
            FROM SQM_GENERAL.Tbl_CartDetails
            WHERE cartDetailCartId = @CartId
              AND cartDetailStatusId = 1
            GROUP BY cartDetailProductVariableId
        ) D;

        UPDATE S
        SET stockQuantity = S.stockQuantity - D.Quantity,
            stockModificatorId = @UsuarioId,
            stockModificationDate = GETDATE()
        FROM SQM_GENERAL.Tbl_Stocks S
        INNER JOIN
        (
            SELECT cartDetailProductVariableId, SUM(cartDetailQuantity) AS Quantity
            FROM SQM_GENERAL.Tbl_CartDetails
            WHERE cartDetailCartId = @CartId
              AND cartDetailStatusId = 1
            GROUP BY cartDetailProductVariableId
        ) D
            ON D.cartDetailProductVariableId = S.stockProductVariableId
        WHERE S.stockId =
        (
            SELECT TOP (1) S2.stockId
            FROM SQM_GENERAL.Tbl_Stocks S2
            WHERE S2.stockProductVariableId = D.cartDetailProductVariableId
              AND S2.stockStatusId = 1
              AND S2.stockQuantity >= D.Quantity
            ORDER BY
                CASE WHEN S2.stockExpirationDate IS NULL THEN 1 ELSE 0 END,
                S2.stockExpirationDate,
                S2.stockId
        );

        IF @@ROWCOUNT <> @ExpectedStockRows
            THROW 50001, 'No fue posible actualizar el inventario completo.', 1;

        UPDATE SQM_GENERAL.Tbl_CartDetails
        SET cartDetailStatusId = 0,
            cartDetailModificatorId = @UsuarioId,
            cartDetailModificationDate = GETDATE()
        WHERE cartDetailCartId = @CartId
          AND cartDetailStatusId = 1;

        UPDATE SQM_GENERAL.Tbl_Carts
        SET cartStatusId = 0,
            cartModificatorId = @UsuarioId,
            cartModificationDate = GETDATE()
        WHERE cartId = @CartId;

        COMMIT TRANSACTION;

        SELECT
            200 AS ResultCode,
            N'Pago procesado y orden creada correctamente.' AS ResultMessage,
            @OrderId AS OrderId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END
GO

CREATE OR ALTER PROCEDURE dbo.SP_ConsultarOrdenPago
(
    @UsuarioId INT,
    @OrderId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM SQM_GENERAL.Tbl_PaymentOrders
        WHERE orderId = @OrderId
          AND orderUserId = @UsuarioId
    )
    BEGIN
        SELECT 404 AS ResultCode, N'Orden no encontrada.' AS ResultMessage;
        RETURN;
    END;

    SELECT 200 AS ResultCode, N'Orden consultada correctamente.' AS ResultMessage;

    SELECT
        O.orderId,
        O.orderCreationDate,
        S.statusName AS status,
        O.orderSubtotal AS subtotal,
        O.orderDiscount AS discount,
        O.orderShipping AS shipping,
        O.orderTAX AS tax,
        O.orderTotal AS total,
        O.orderCurrencyId AS currencyId
    FROM SQM_GENERAL.Tbl_PaymentOrders O
    INNER JOIN SQM_CATALOGS.Tbl_Status S
        ON S.statusId = O.orderStatusId
    WHERE O.orderId = @OrderId;

    SELECT
        D.orderDetailId,
        D.orderDetailProductVariableId AS productVariableId,
        P.productName,
        PV.productVariableValue,
        D.orderDetailQuantity AS quantity,
        D.orderDetailPrice AS unitPrice,
        D.orderDetailTotal AS total
    FROM SQM_GENERAL.Tbl_PaymentOrderDetails D
    INNER JOIN SQM_GENERAL.Tbl_ProductVariables PV
        ON PV.productVariableId = D.orderDetailProductVariableId
    INNER JOIN SQM_GENERAL.Tbl_Products P
        ON P.productId = PV.productVariableProductId
    WHERE D.orderDetailOrderId = @OrderId
    ORDER BY D.orderDetailId;
END
GO
