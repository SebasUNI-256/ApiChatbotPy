

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

-- ALT + SHIFT + DIRECCIONAL
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