    USE DB_ECOMMERCE
GO

INSERT INTO [SQM_CATALOGS].[Tbl_Status](statusName,statusCreatorId,statusCreationDate,statusStatusId)
VALUES
('ACTIVO', 1, GETDATE(), 1),
('INACTIVO', 1, GETDATE(), 1),
('BLOQUEADO', 1, GETDATE(), 1),
('PROCESADO', 1, GETDATE(), 1),
('ENTREGADO', 1, GETDATE(), 1),
('ANULADO', 1, GETDATE(), 1);
----------------------------------------
/* USO DE FUNCIONES ESCALARES         */
----------------------------------------
OPEN SYMMETRIC KEY KEY_HASH
DECRYPTION BY CERTIFICATE CERT_ECOMMERCE;

  DECLARE
	@UserPassword VARCHAR(256),
	@UserPasswordEncrypted VARBINARY(256)
  SET @UserPassword = '12345'
  SET @UserPasswordEncrypted = SQM_SECURITY.Fn_EncryptByKey(@UserPassword)

INSERT INTO [SQM_SECURITY].[Tbl_Users](userFullName,userName,userPassword,userEmail,userPhoneNumber,userCountryId,userGenderId,userBirthDay,userCreatorId,userCreationDate,userStatusId)
VALUES
('DARWING JOEL GARCIA LOPEZ', 'KAWIN', @UserPasswordEncrypted, 'kawin@dominio.local','88888888', 1, 2,CONVERT(DATE, '2000-05-12', 120), 1, GETDATE(), 1),
('RAQUEL ESMERALDA ROBLETO LOPEZ', 'RAKA', @UserPasswordEncrypted, 'raka@dominio.local','99999999', 1, 2,CONVERT(DATE, '2000-05-12', 120), 1, GETDATE(), 1);

CLOSE SYMMETRIC KEY KEY_HASH;


INSERT INTO [SQM_GENERAL].[Tbl_UserAddress](userAddressUserId, userAddressCountryId, userAddressZIPCode, userAddressDescription, userAddressIsPrincipal, userAddressCreatorId, userAddressCreationDate, userAddressStatusId)
VALUES 
(6, 1, '1001', 'El Crucero, Managua',   1, 6, GETDATE(), 1),
(7, 1, '1002', 'El Crucero, Managua',     1, 6, GETDATE(), 1);
GO

INSERT INTO [SQM_CATALOGS].[Tbl_Categories](categoryName, categoryDescription, categoryCreatorId, categoryCreationDate, categoryStatusId)
VALUES
('CALZADO',    'CALZADO EN GENERAL',    6, GETDATE(), 1),
('ROPA',       'ROPA EN GENERAL',       6, GETDATE(), 1),
('TECNOLOGIA', 'TECNOLOGIA EN GENERAL', 6, GETDATE(), 1),
('ACCESORIOS', 'ACCESORIOS EN GENERAL', 6, GETDATE(), 1);
GO

INSERT INTO [SQM_CATALOGS].[Tbl_SubCategories](subCategoryName, subCategoryDescription, subCategoryCreatorId, subCategoryCreationDate, subCategoryStatusId)
VALUES
('MASCULINO',    'ROPA MASCULINA',           6, GETDATE(), 1),
('FEMENINO',     'ROPA FEMENINA',            6, GETDATE(), 1),
('NIÑOS',        'ROPA PARA NIÑOS',          6, GETDATE(), 1),
('NIÑAS',        'ROPA PARA NIÑAS',          6, GETDATE(), 1),
('CELULARES',    'CELULARES EN GENERAL',     6, GETDATE(), 1),
('COMPUTADORAS', 'COMPUTADORAS EN GENERAL',  6, GETDATE(), 1);
GO

INSERT INTO [SQM_CATALOGS].[Tbl_Segments](segmentName, segmentDescription, segmentCreatorId, segmentCreationDate, segmentStatusId)
VALUES
('DEPORTIVO', 'SEGMENTO DEPORTIVO', 6, GETDATE(), 1),
('CASUAL',    'SEGMENTO CASUAL',    6, GETDATE(), 1),
('ELEGANTE',  'SEGMENTO ELEGANTE',  6, GETDATE(), 1),
('OFICINA',   'SEGMENTO OFICINA',   6, GETDATE(), 1),
('GAMING',    'SEGMENTO GAMING',    6, GETDATE(), 1),
('HOGAR',     'SEGMENTO HOGAR',     6, GETDATE(), 1),
('LAPTOS',    'SEGMENTO LAPTOS',    6, GETDATE(), 1),
('REPUESTOS', 'SEGMENTO REPUESTOS', 6, GETDATE(), 1);
GO

INSERT INTO [SQM_CATALOGS].[Tbl_ProductIdentificators](productIdentificatorCategoryId, productIdentificatorSubCategoryId, productIdentificatorSegmentId, productIdentificatorCreatorId, productIdentificatorCreationDate, productIdentificatorStatusId)
VALUES
(1,1,1,6,GETDATE(),1),
(1,2,1,6,GETDATE(),1),
(1,3,1,6,GETDATE(),1),
(1,4,1,6,GETDATE(),1),
(2,1,1,6,GETDATE(),1),
(2,2,1,6,GETDATE(),1),
(2,3,1,6,GETDATE(),1),
(2,4,1,6,GETDATE(),1),
(3,5,4,6,GETDATE(),1),
(3,5,5,6,GETDATE(),1),
(3,6,4,6,GETDATE(),1),
(3,6,5,6,GETDATE(),1),
(3,6,7,6,GETDATE(),1);
GO




-- ── ROLES (solo ADMIN y CLIENTE) ─────────────────────────────
INSERT INTO [SQM_SECURITY].[Tbl_Roles](RolName, RolDescription, RolCreatorId, RolCreationDate, RolStatusId)
VALUES
('ADMIN',   'Administrador del sistema, acceso total',          6, GETDATE(), 1),
('CLIENTE', 'Compras, carrito y consulta de sus órdenes',       6, GETDATE(), 1);
GO

-- ── PERMISOS ──────────────────────────────────────────────────
INSERT INTO [SQM_SECURITY].[Tbl_TransactionTypes](TransactionTypeName, TransactionTypeDescription, TransactionTypeCreatorId, TransactionTypeCreationDate, TransactionTypeStatusId)
VALUES
('PRODUCT_LIST','Consultar productos',1,GETDATE(),1),
('PRODUCT_CREATE','Crear productos',1,GETDATE(),1),
('PRODUCT_EDIT','Editar productos',1,GETDATE(),1),
('PRODUCT_DELETE','Eliminar productos',1,GETDATE(),1),

('ORDER_LIST','Consultar órdenes',1,GETDATE(),1),
('ORDER_CREATE','Crear órdenes',1,GETDATE(),1),
('ORDER_EDIT','Modificar órdenes',1,GETDATE(),1),

('USER_LIST','Consultar usuarios',1,GETDATE(),1),
('USER_CREATE','Crear usuarios',1,GETDATE(),1),
('USER_EDIT','Editar usuarios',1,GETDATE(),1),

('STOCK_LIST','Consultar inventario',1,GETDATE(),1),
('STOCK_EDIT','Modificar inventario',1,GETDATE(),1);
GO

-- ── PERMISOS POR ROL ──────────────────────────────────────────
-- ADMIN: todo
INSERT INTO SQM_SECURITY.Tbl_RolByTransactionTypes
(
    RolByTransactionRolId,
    RolByTransactionTransactionTypeId,
    RolByTransactionTypeCreatorId,
    RolByTransactionTypeCreationDate,
    RolByTransactionTypeStatusId
)
SELECT
    1,
    TransactionTypeId,
    1,
    GETDATE(),
    6
FROM SQM_SECURITY.Tbl_TransactionTypes;

-- CLIENTE: ver productos, carrito, sus órdenes
INSERT INTO SQM_SECURITY.Tbl_RolByTransactionTypes
(
    RolByTransactionRolId,
    RolByTransactionTransactionTypeId,
    RolByTransactionTypeCreatorId,
    RolByTransactionTypeCreationDate,
    RolByTransactionTypeStatusId
)
SELECT
    2,
    TransactionTypeId,
    1,
    GETDATE(),
    6
FROM SQM_SECURITY.Tbl_TransactionTypes
WHERE TransactionTypeName IN
(
    'PRODUCT_LIST',
    'ORDER_CREATE'
);
-- ── ASIGNAR ROLES A USUARIOS ──────────────────────────────────
INSERT INTO SQM_SECURITY.Tbl_UserByRoles
(
    UserByRolRolId,
    UserByRolUserId,
    UserByRolTypeCreatorId,
    UserByRolTypeCreationDate,
    UserByRolTypeStatusId
)
VALUES
(1, 6, 6, GETDATE(), 1),  -- HCALERO = ADMIN
(1, 7, 6, GETDATE(), 1);  -- DURBINA = ADMIN
GO




USE [DB_ECOMMERCE]
GO

-- ── 1. MARCAS ─────────────────────────────────────────────────
INSERT INTO [SQM_CATALOGS].[Tbl_Marks](markName, markDescription, markCreatorId, markCreationDate, markStatusId)
VALUES
('NIKE',      'Marca deportiva americana',         6, GETDATE(), 1),
('ADIDAS',    'Marca deportiva alemana',            6, GETDATE(), 1),
('APPLE',     'Marca tecnológica americana',        6, GETDATE(), 1),
('SAMSUNG',   'Marca tecnológica coreana',          6, GETDATE(), 1),
('XIAOMI',    'Marca tecnológica china',            6, GETDATE(), 1),
('LENOVO',    'Marca tecnológica china',            6, GETDATE(), 1),
('HP',        'Marca tecnológica americana',        6, GETDATE(), 1),
('ZARA',      'Marca de ropa española',             6, GETDATE(), 1),
('LEVIS',     'Marca de ropa americana',            6, GETDATE(), 1),
('PUMA',      'Marca deportiva alemana',            6, GETDATE(), 1);
GO

-- ── 2. PROVEEDORES ────────────────────────────────────────────
INSERT INTO [SQM_CATALOGS].[Tbl_Providers](providerName, providerDescription, providerCreatorId, providerCreationDate, providerStatusId)
VALUES
('TECH IMPORTS S.A.',     'Proveedor de tecnología',           6, GETDATE(), 1),
('MODA GLOBAL S.A.',      'Proveedor de ropa y calzado',       6, GETDATE(), 1),
('DEPORTES NICA S.A.',    'Proveedor de artículos deportivos', 6, GETDATE(), 1),
('DISTRIBUIDORA LEON',    'Distribuidor general Nicaragua',    6, GETDATE(), 1);
GO

-- ── 3. MARCA POR PROVEEDOR ────────────────────────────────────
-- markId: NIKE=1, ADIDAS=2, APPLE=3, SAMSUNG=4, XIAOMI=5
--         LENOVO=6, HP=7, ZARA=8, LEVIS=9, PUMA=10
-- providerId: TECH=1, MODA=2, DEPORTES=3, DISTRIB=4
INSERT INTO [SQM_CATALOGS].[Tbl_MarkByProviders](markByProviderMarkId, markByProviderProviderId, markByProviderCreatorId, markByProviderCreationDate, markByProviderStatusId)
VALUES
(1,  3, 6, GETDATE(), 1),  -- NIKE      → DEPORTES NICA
(2,  3, 6, GETDATE(), 1),  -- ADIDAS    → DEPORTES NICA
(10, 3, 6, GETDATE(), 1),  -- PUMA      → DEPORTES NICA
(3,  1, 6, GETDATE(), 1),  -- APPLE     → TECH IMPORTS
(4,  1, 6, GETDATE(), 1),  -- SAMSUNG   → TECH IMPORTS
(5,  1, 6, GETDATE(), 1),  -- XIAOMI    → TECH IMPORTS
(6,  1, 6, GETDATE(), 1),  -- LENOVO    → TECH IMPORTS
(7,  1, 6, GETDATE(), 1),  -- HP        → TECH IMPORTS
(8,  2, 6, GETDATE(), 1),  -- ZARA      → MODA GLOBAL
(9,  2, 6, GETDATE(), 1);  -- LEVIS     → MODA GLOBAL
GO

-----── 4. TIPOS DE ATRIBUTO ──────────────────────────────────────
INSERT INTO [SQM_CATALOGS].[Tbl_AttributesTypes](attributeTypeName, attributeTypeDescription, attributeTypeCreatorId, attributeTypeCreationDate, attributeTypeStatusId)
VALUES
('COLOR',       'Color del producto',              6, GETDATE(), 1),
('TALLA',       'Talla del producto',              6, GETDATE(), 1),
('MATERIAL',    'Material del producto',           6, GETDATE(), 1),
('PESO',        'Peso del producto',               6, GETDATE(), 1),
('ALMACENAMIENTO', 'Capacidad de almacenamiento',  6, GETDATE(), 1),
('RAM',         'Memoria RAM',                     6, GETDATE(), 1),
('PANTALLA',    'Tamaño de pantalla',              6, GETDATE(), 1),
('PROCESADOR',  'Tipo de procesador',              6, GETDATE(), 1);
GO

Select * from [SQM_CATALOGS].[Tbl_AttributesTypes]

-- ── 5. MONEDAS ────────────────────────────────────────────────
INSERT INTO [SQM_CATALOGS].[Tbl_Currencies](currencyName, currencyISO, currencyCode, currencyDescription, currencyCreatorId, currencyCreationDate, currencyStatusId)
VALUES
('DOLAR AMERICANO', 'USD', 840, 'Moneda de Estados Unidos', 6, GETDATE(), 1),
('CORDOBA',         'NIO', 558, 'Moneda de Nicaragua',      6, GETDATE(), 1);
GO

-- ── 6. TIPOS DE VARIABLE DE PRODUCTO ─────────────────────────
INSERT INTO [SQM_CATALOGS].[Tbl_ProductVariableTypes](productVariableTypeName, productVariableTypeDescription, productVariableTypeCreatorId, productVariableTypeCreationDate, productVariableTypeStatusId)
VALUES
('TALLA-COLOR',      'Variante por talla y color',          6, GETDATE(), 1),
('ALMACENAMIENTO',   'Variante por capacidad de almacen',   6, GETDATE(), 1),
('COLOR',            'Variante solo por color',             6, GETDATE(), 1),
('UNICO',            'Producto sin variantes',              6, GETDATE(), 1);
GO

-- ── 7. MÉTODOS DE PAGO ────────────────────────────────────────
INSERT INTO [SQM_CATALOGS].[Tbl_PaymentMethodTypes](paymentMethodTypeName, paymentMethodTypeDescription, paymentMethodTypeCreatorId, paymentMethodTypeCreationDate, paymentMethodTypeStatusId)
VALUES
('TARJETA CREDITO', 'Pago con tarjeta de crédito',  6, GETDATE(), 1),
('TARJETA DEBITO',  'Pago con tarjeta de débito',   6, GETDATE(), 1),
('TRANSFERENCIA',   'Transferencia bancaria',        6, GETDATE(), 1);
GO

-- ── 8. TIPOS DE MOVIMIENTO DE STOCK ──────────────────────────
INSERT INTO [SQM_CATALOGS].[Tbl_StockMovementTypes](stockMovementTypeName, stockMovementTypeDescription, stockMovementTypeCreatorId, stockMovementTypeCreationDate, stockMovementTypeStatusId)
VALUES
('ENTRADA',     'Ingreso de mercadería al inventario',      6, GETDATE(), 1),
('SALIDA',      'Salida por venta',                         6, GETDATE(), 1),
('AJUSTE',      'Ajuste manual de inventario',              6, GETDATE(), 1),
('DEVOLUCION',  'Devolución de producto por cliente',       6, GETDATE(), 1);
GO

-- ── 9. PRODUCTOS BASE ─────────────────────────────────────────
-- productProductIdentificatorId:
--   1=CALZADO/MASCULINO/DEPORTIVO, 2=CALZADO/FEMENINO/DEPORTIVO
--   9=TECNOLOGIA/CELULARES/OFICINA, 10=TECNOLOGIA/CELULARES/GAMING
--   11=TECNOLOGIA/COMPUTADORAS/OFICINA, 13=TECNOLOGIA/COMPUTADORAS/LAPTOS
-- productMarkByProviderId:
--   1=NIKE, 2=ADIDAS, 3=PUMA, 4=APPLE, 5=SAMSUNG
--   6=XIAOMI, 7=LENOVO, 8=HP, 9=ZARA, 10=LEVIS
INSERT INTO [SQM_GENERAL].[Tbl_Products](productName, productDescription, productProductIdentificatorId, productMarkByProviderId, productCreatorId, productCreationDate, productStatusId)
VALUES
('TENIS AIR MAX',        'Tenis deportivos Nike Air Max',          1,  1,  6, GETDATE(), 1),
('TENIS ULTRABOOST',     'Tenis deportivos Adidas Ultraboost',     1,  2,  6, GETDATE(), 1),
('IPHONE 15',            'Smartphone Apple iPhone 15',             9,  4,  6, GETDATE(), 1),
('GALAXY S24',           'Smartphone Samsung Galaxy S24',          9,  5,  6, GETDATE(), 1),
('REDMI NOTE 13',        'Smartphone Xiaomi Redmi Note 13',        9,  6,  6, GETDATE(), 1),
('THINKPAD E14',         'Laptop Lenovo ThinkPad E14',             13, 7,  6, GETDATE(), 1),
('HP PAVILION 15',       'Laptop HP Pavilion 15',                  13, 8,  6, GETDATE(), 1),
('CAMISETA ZARA',        'Camiseta casual Zara',                   5,  9,  6, GETDATE(), 1),
('JEANS LEVIS 501',      'Jeans clásicos Levis 501',               5,  10, 6, GETDATE(), 1);
GO

-- ── 10. VARIABLES DE PRODUCTO ─────────────────────────────────
-- currencyId: 1=USD, 2=NIO
INSERT INTO [SQM_GENERAL].[Tbl_ProductVariables](productVariableProductId, productVariableValue, productVariablePrice, productVariableCurrencyId, productVariableCreatorId, productVariableCreationDate, productVariableStatusId)
VALUES
-- TENIS AIR MAX (productId=1) → tallas
(1, 'TALLA 40', 120.00, 1, 6, GETDATE(), 1),
(1, 'TALLA 41', 120.00, 1, 6, GETDATE(), 1),
(1, 'TALLA 42', 120.00, 1, 6, GETDATE(), 1),
-- TENIS ULTRABOOST (productId=2)
(2, 'TALLA 40', 110.00, 1, 6, GETDATE(), 1),
(2, 'TALLA 41', 110.00, 1, 6, GETDATE(), 1),
-- IPHONE 15 (productId=3) → almacenamiento
(3, '128GB', 999.00, 1, 6, GETDATE(), 1),
(3, '256GB', 1099.00, 1, 6, GETDATE(), 1),
(3, '512GB', 1299.00, 1, 6, GETDATE(), 1),
-- GALAXY S24 (productId=4)
(4, '128GB', 799.00, 1, 6, GETDATE(), 1),
(4, '256GB', 899.00, 1, 6, GETDATE(), 1),
-- REDMI NOTE 13 (productId=5)
(5, '128GB/6GB RAM', 199.00, 1, 6, GETDATE(), 1),
(5, '256GB/8GB RAM', 249.00, 1, 6, GETDATE(), 1),
-- THINKPAD E14 (productId=6)
(6, 'RYZEN 5/8GB/256GB', 650.00, 1, 6, GETDATE(), 1),
(6, 'RYZEN 7/16GB/512GB', 850.00, 1, 6, GETDATE(), 1),
-- HP PAVILION 15 (productId=7)
(7, 'CORE i5/8GB/256GB',  550.00, 1, 6, GETDATE(), 1),
(7, 'CORE i7/16GB/512GB', 750.00, 1, 6, GETDATE(), 1),
-- CAMISETA ZARA (productId=8)
(8, 'TALLA S',  25.00, 1, 6, GETDATE(), 1),
(8, 'TALLA M',  25.00, 1, 6, GETDATE(), 1),
(8, 'TALLA L',  25.00, 1, 6, GETDATE(), 1),
-- JEANS LEVIS 501 (productId=9)
(9, 'TALLA 30', 60.00, 1, 6, GETDATE(), 1),
(9, 'TALLA 32', 60.00, 1, 6, GETDATE(), 1),
(9, 'TALLA 34', 60.00, 1, 6, GETDATE(), 1);
GO

-- ── 11. STOCK INICIAL ─────────────────────────────────────────
-- stockProductVariableId va del 1 al 22 según el orden de inserción
INSERT INTO [SQM_GENERAL].[Tbl_Stocks](stockProductVariableId, stockQuantity, stockFactoryDate, stockExpirationDate, stockCreatorId, stockCreationDate, stockStatusId)
VALUES
-- Tenis Air Max
(1,  50, CONVERT(DATE,'20240101',112), CONVERT(DATE,'20261231',112), 6, GETDATE(), 1),
(2,  50, CONVERT(DATE,'20240101',112), CONVERT(DATE,'20261231',112), 6, GETDATE(), 1),
(3,  50, CONVERT(DATE,'20240101',112), CONVERT(DATE,'20261231',112), 6, GETDATE(), 1),
-- Tenis Ultraboost
(4,  40, CONVERT(DATE,'20240101',112), CONVERT(DATE,'20261231',112), 6, GETDATE(), 1),
(5,  40, CONVERT(DATE,'20240101',112), CONVERT(DATE,'20261231',112), 6, GETDATE(), 1),
-- iPhone 15
(6,  20, CONVERT(DATE,'20240101',112), CONVERT(DATE,'20271231',112), 6, GETDATE(), 1),
(7,  15, CONVERT(DATE,'20240101',112), CONVERT(DATE,'20271231',112), 6, GETDATE(), 1),
(8,  10, CONVERT(DATE,'20240101',112), CONVERT(DATE,'20271231',112), 6, GETDATE(), 1),
-- Galaxy S24
(9,  25, CONVERT(DATE,'20240101',112), CONVERT(DATE,'20271231',112), 6, GETDATE(), 1),
(10, 20, CONVERT(DATE,'20240101',112), CONVERT(DATE,'20271231',112), 6, GETDATE(), 1),
-- Redmi Note 13
(11, 30, CONVERT(DATE,'20240101',112), CONVERT(DATE,'20271231',112), 6, GETDATE(), 1),
(12, 25, CONVERT(DATE,'20240101',112), CONVERT(DATE,'20271231',112), 6, GETDATE(), 1),
-- ThinkPad E14
(13, 10, CONVERT(DATE,'20240101',112), CONVERT(DATE,'20271231',112), 6, GETDATE(), 1),
(14, 8,  CONVERT(DATE,'20240101',112), CONVERT(DATE,'20271231',112), 6, GETDATE(), 1),
-- HP Pavilion
(15, 12, CONVERT(DATE,'20240101',112), CONVERT(DATE,'20271231',112), 6, GETDATE(), 1),
(16, 8,  CONVERT(DATE,'20240101',112), CONVERT(DATE,'20271231',112), 6, GETDATE(), 1),
-- Camiseta Zara
(17, 100, CONVERT(DATE,'20240101',112), CONVERT(DATE,'20271231',112), 6, GETDATE(), 1),
(18, 100, CONVERT(DATE,'20240101',112), CONVERT(DATE,'20271231',112), 6, GETDATE(), 1),
(19, 100, CONVERT(DATE,'20240101',112), CONVERT(DATE,'20271231',112), 6, GETDATE(), 1),
-- Jeans Levis
(20, 60, CONVERT(DATE,'20240101',112), CONVERT(DATE,'20271231',112), 6, GETDATE(), 1),
(21, 60, CONVERT(DATE,'20240101',112), CONVERT(DATE,'20271231',112), 6, GETDATE(), 1),
(22, 60, CONVERT(DATE,'20240101',112), CONVERT(DATE,'20271231',112), 6, GETDATE(), 1);
GO