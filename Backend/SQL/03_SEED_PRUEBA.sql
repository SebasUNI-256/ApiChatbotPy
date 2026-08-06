-- Foro 3 - Datos minimos para probar autenticacion, busqueda, carrito y pago.
-- Puede ejecutarse varias veces sin duplicar los registros de demostracion.
USE [DB_ECOMMERCE]
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @UsuarioSistemaID INT = 1;
DECLARE @EstadoActivoID INT =
(
    SELECT TOP (1) statusId
    FROM SQM_CATALOGS.Tbl_Status
    WHERE UPPER(statusName) = 'ACTIVO' AND statusStatusId = 1
    ORDER BY statusId
);

IF @EstadoActivoID IS NULL
    THROW 50201, 'Falta el estado ACTIVO. Ejecuta primero 01_DB_ECOMMERCE.sql.', 1;

IF NOT EXISTS
(
    SELECT 1 FROM SQM_CATALOGS.Tbl_Status
    WHERE UPPER(statusName) = 'PROCESADO' AND statusStatusId = 1
)
BEGIN
    INSERT INTO SQM_CATALOGS.Tbl_Status
        (statusName, statusCreatorId, statusCreationDate, statusStatusId)
    VALUES ('PROCESADO', @UsuarioSistemaID, GETDATE(), 1);
END;

IF NOT EXISTS
(
    SELECT 1 FROM SQM_CATALOGS.Tbl_Status
    WHERE UPPER(statusName) = 'ENTREGADO' AND statusStatusId = 1
)
BEGIN
    INSERT INTO SQM_CATALOGS.Tbl_Status
        (statusName, statusCreatorId, statusCreationDate, statusStatusId)
    VALUES ('ENTREGADO', @UsuarioSistemaID, GETDATE(), 1);
END;

IF NOT EXISTS
(
    SELECT 1 FROM SQM_CATALOGS.Tbl_Status
    WHERE UPPER(statusName) = 'ANULADO' AND statusStatusId = 1
)
BEGIN
    INSERT INTO SQM_CATALOGS.Tbl_Status
        (statusName, statusCreatorId, statusCreationDate, statusStatusId)
    VALUES ('ANULADO', @UsuarioSistemaID, GETDATE(), 1);
END;

IF NOT EXISTS (SELECT 1 FROM SQM_SECURITY.Tbl_Users WHERE userName = 'FORO3_DEMO')
BEGIN
    EXEC SQM_SECURITY.sp_RegistrarCliente
        @NombreCompleto = 'USUARIO DEMOSTRACION FORO 3',
        @NombreUsuario = 'FORO3_DEMO',
        @Correo = 'foro3.demo@example.com',
        @Contrasena = 'ClaveDemo123!',
        @Telefono = '88888888',
        @PaisID = 1,
        @GeneroID = 1,
        @FechaNacimiento = '2000-01-15';
END;

DECLARE @UsuarioDemoID INT =
(
    SELECT TOP (1) userId
    FROM SQM_SECURITY.Tbl_Users
    WHERE userName = 'FORO3_DEMO'
);

IF @UsuarioDemoID IS NULL
    THROW 50202, 'No fue posible crear o localizar FORO3_DEMO.', 1;

DECLARE @RolClienteID INT =
(
    SELECT TOP (1) RolId
    FROM SQM_SECURITY.Tbl_Roles
    WHERE UPPER(RolName) = 'CLIENTE' AND RolStatusId = 1
    ORDER BY RolId
);

IF @RolClienteID IS NULL
    THROW 50203, 'Falta el rol CLIENTE. Ejecuta primero 01_DB_ECOMMERCE.sql.', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM SQM_SECURITY.Tbl_UserByRoles
    WHERE UserByRolRolId = @RolClienteID
      AND UserByRolUserId = @UsuarioDemoID
      AND UserByRolTypeStatusId = 1
)
BEGIN
    INSERT INTO SQM_SECURITY.Tbl_UserByRoles
    (
        UserByRolRolId, UserByRolUserId, UserByRolTypeCreatorId,
        UserByRolTypeCreationDate, UserByRolTypeStatusId
    )
    VALUES (@RolClienteID, @UsuarioDemoID, @UsuarioSistemaID, GETDATE(), 1);
END;

IF NOT EXISTS
(
    SELECT 1
    FROM SQM_GENERAL.Tbl_UserAddress
    WHERE userAddressUserId = @UsuarioDemoID
      AND userAddressDescription = 'Direccion de prueba Foro 3, Managua'
      AND userAddressStatusId = 1
)
BEGIN
    INSERT INTO SQM_GENERAL.Tbl_UserAddress
    (
        userAddressUserId, userAddressCountryId, userAddressZIPCode,
        userAddressDescription, userAddressIsPrincipal, userAddressCreatorId,
        userAddressCreationDate, userAddressStatusId
    )
    VALUES
    (
        @UsuarioDemoID, 1, 10001,
        'Direccion de prueba Foro 3, Managua', 1, @UsuarioDemoID,
        GETDATE(), 1
    );
END;

IF NOT EXISTS
(
    SELECT 1
    FROM SQM_CATALOGS.Tbl_PaymentMethodTypes
    WHERE UPPER(paymentMethodTypeName) = 'TARJETA VISA DEMO'
      AND paymentMethodTypeStatusId = 1
)
BEGIN
    INSERT INTO SQM_CATALOGS.Tbl_PaymentMethodTypes
    (
        paymentMethodTypeName, paymentMethodTypeDescription,
        paymentMethodTypeCreatorId, paymentMethodTypeCreationDate,
        paymentMethodTypeStatusId
    )
    VALUES
    (
        'TARJETA VISA DEMO', 'Tarjeta de demostracion para Foro 3',
        @UsuarioSistemaID, GETDATE(), 1
    );
END;

DECLARE @TipoPagoID INT =
(
    SELECT TOP (1) paymentMethodTypeId
    FROM SQM_CATALOGS.Tbl_PaymentMethodTypes
    WHERE UPPER(paymentMethodTypeName) = 'TARJETA VISA DEMO'
      AND paymentMethodTypeStatusId = 1
    ORDER BY paymentMethodTypeId
);

IF NOT EXISTS
(
    SELECT 1
    FROM SQM_GENERAL.Tbl_UserPaymentMethods
    WHERE userPaymentMethodUserId = @UsuarioDemoID
      AND userPaymentMethodPaymentMethodTypeId = @TipoPagoID
      AND userPaymentMethodCardHolderName = 'USUARIO FORO 3 DEMO'
      AND userPaymentMethodStatusId = 1
)
BEGIN
    DECLARE @VencimientoDemo VARCHAR(7) = CONVERT(VARCHAR(7), DATEADD(YEAR, 3, GETDATE()), 120);

    OPEN SYMMETRIC KEY KEY_HASH
        DECRYPTION BY CERTIFICATE CERT_ECOMMERCE;

    INSERT INTO SQM_GENERAL.Tbl_UserPaymentMethods
    (
        userPaymentMethodUserId, userPaymentMethodPaymentMethodTypeId,
        userPaymentMethodCardNumber, userPaymentMethodExpirationDate,
        userPaymentMethodCVV, userPaymentMethodCardHolderName,
        userPaymentMethodCreatorId, userPaymentMethodCreationDate,
        userPaymentMethodStatusId
    )
    VALUES
    (
        @UsuarioDemoID, @TipoPagoID,
        SQM_SECURITY.Fn_EncryptByKey('4111111111111111'),
        SQM_SECURITY.Fn_EncryptByKey(@VencimientoDemo),
        SQM_SECURITY.Fn_EncryptByKey('123'),
        'USUARIO FORO 3 DEMO', @UsuarioDemoID, GETDATE(), 1
    );

    CLOSE SYMMETRIC KEY KEY_HASH;
END;

IF NOT EXISTS
(
    SELECT 1 FROM SQM_CATALOGS.Tbl_Currencies
    WHERE currencyISO = 'USD' AND currencyStatusId = 1
)
BEGIN
    INSERT INTO SQM_CATALOGS.Tbl_Currencies
    (
        currencyName, currencyISO, currencyCode, currencyDescription,
        currencyCreatorId, currencyCreationDate, currencyStatusId
    )
    VALUES
    ('DOLAR DEMO', 'USD', 840, 'Moneda de demostracion', @UsuarioSistemaID, GETDATE(), 1);
END;

IF NOT EXISTS
(
    SELECT 1 FROM SQM_CATALOGS.Tbl_Categories
    WHERE categoryName = 'CALZADO FORO 3' AND categoryStatusId = 1
)
BEGIN
    INSERT INTO SQM_CATALOGS.Tbl_Categories
    (
        categoryName, categoryDescription, categoryCreatorId,
        categoryCreationDate, categoryStatusId
    )
    VALUES
    ('CALZADO FORO 3', 'Categoria de demostracion', @UsuarioSistemaID, GETDATE(), 1);
END;

IF NOT EXISTS
(
    SELECT 1 FROM SQM_CATALOGS.Tbl_SubCategories
    WHERE subCategoryName = 'TENIS FORO 3' AND subCategoryStatusId = 1
)
BEGIN
    INSERT INTO SQM_CATALOGS.Tbl_SubCategories
    (
        subCategoryName, subCategoryDescription, subCategoryCreatorId,
        subCategoryCreationDate, subCategoryStatusId
    )
    VALUES
    ('TENIS FORO 3', 'Subcategoria de demostracion', @UsuarioSistemaID, GETDATE(), 1);
END;

IF NOT EXISTS
(
    SELECT 1 FROM SQM_CATALOGS.Tbl_Segments
    WHERE segmentName = 'DEPORTIVO FORO 3' AND segmentStatusId = 1
)
BEGIN
    INSERT INTO SQM_CATALOGS.Tbl_Segments
    (
        segmentName, segmentDescription, segmentCreatorId,
        segmentCreationDate, segmentStatusId
    )
    VALUES
    ('DEPORTIVO FORO 3', 'Segmento de demostracion', @UsuarioSistemaID, GETDATE(), 1);
END;

DECLARE @CategoriaID INT =
(
    SELECT TOP (1) categoryId FROM SQM_CATALOGS.Tbl_Categories
    WHERE categoryName = 'CALZADO FORO 3' AND categoryStatusId = 1
);
DECLARE @SubCategoriaID INT =
(
    SELECT TOP (1) subCategoryId FROM SQM_CATALOGS.Tbl_SubCategories
    WHERE subCategoryName = 'TENIS FORO 3' AND subCategoryStatusId = 1
);
DECLARE @SegmentoID INT =
(
    SELECT TOP (1) segmentId FROM SQM_CATALOGS.Tbl_Segments
    WHERE segmentName = 'DEPORTIVO FORO 3' AND segmentStatusId = 1
);

IF NOT EXISTS
(
    SELECT 1 FROM SQM_CATALOGS.Tbl_ProductIdentificators
    WHERE productIdentificatorCategoryId = @CategoriaID
      AND productIdentificatorSubCategoryId = @SubCategoriaID
      AND productIdentificatorSegmentId = @SegmentoID
      AND productIdentificatorStatusId = 1
)
BEGIN
    INSERT INTO SQM_CATALOGS.Tbl_ProductIdentificators
    (
        productIdentificatorCategoryId, productIdentificatorSubCategoryId,
        productIdentificatorSegmentId, productIdentificatorCreatorId,
        productIdentificatorCreationDate, productIdentificatorStatusId
    )
    VALUES
    (@CategoriaID, @SubCategoriaID, @SegmentoID, @UsuarioSistemaID, GETDATE(), 1);
END;

IF NOT EXISTS
(
    SELECT 1 FROM SQM_CATALOGS.Tbl_Marks
    WHERE markName = 'MARCA FORO 3' AND markStatusId = 1
)
BEGIN
    INSERT INTO SQM_CATALOGS.Tbl_Marks
    (
        markName, markDescription, markCreatorId, markCreationDate, markStatusId
    )
    VALUES
    ('MARCA FORO 3', 'Marca de demostracion', @UsuarioSistemaID, GETDATE(), 1);
END;

IF NOT EXISTS
(
    SELECT 1 FROM SQM_CATALOGS.Tbl_Providers
    WHERE providerName = 'PROVEEDOR FORO 3' AND providerStatusId = 1
)
BEGIN
    INSERT INTO SQM_CATALOGS.Tbl_Providers
    (
        providerName, providerDescription, providerCreatorId,
        providerCreationDate, providerStatusId
    )
    VALUES
    ('PROVEEDOR FORO 3', 'Proveedor de demostracion', @UsuarioSistemaID, GETDATE(), 1);
END;

DECLARE @MarcaID INT =
(
    SELECT TOP (1) markId FROM SQM_CATALOGS.Tbl_Marks
    WHERE markName = 'MARCA FORO 3' AND markStatusId = 1
);
DECLARE @ProveedorID INT =
(
    SELECT TOP (1) providerId FROM SQM_CATALOGS.Tbl_Providers
    WHERE providerName = 'PROVEEDOR FORO 3' AND providerStatusId = 1
);

IF NOT EXISTS
(
    SELECT 1 FROM SQM_CATALOGS.Tbl_MarkByProviders
    WHERE markByProviderMarkId = @MarcaID
      AND markByProviderProviderId = @ProveedorID
      AND markByProviderStatusId = 1
)
BEGIN
    INSERT INTO SQM_CATALOGS.Tbl_MarkByProviders
    (
        markByProviderMarkId, markByProviderProviderId,
        markByProviderCreatorId, markByProviderCreationDate,
        markByProviderStatusId
    )
    VALUES
    (@MarcaID, @ProveedorID, @UsuarioSistemaID, GETDATE(), 1);
END;

DECLARE @IdentificadorID INT =
(
    SELECT TOP (1) productIdentificatorId
    FROM SQM_CATALOGS.Tbl_ProductIdentificators
    WHERE productIdentificatorCategoryId = @CategoriaID
      AND productIdentificatorSubCategoryId = @SubCategoriaID
      AND productIdentificatorSegmentId = @SegmentoID
      AND productIdentificatorStatusId = 1
);
DECLARE @MarcaProveedorID INT =
(
    SELECT TOP (1) markByProviderId
    FROM SQM_CATALOGS.Tbl_MarkByProviders
    WHERE markByProviderMarkId = @MarcaID
      AND markByProviderProviderId = @ProveedorID
      AND markByProviderStatusId = 1
);

IF NOT EXISTS
(
    SELECT 1 FROM SQM_GENERAL.Tbl_Products
    WHERE productName = 'TENIS DEPORTIVOS FORO 3' AND productStatusId = 1
)
BEGIN
    INSERT INTO SQM_GENERAL.Tbl_Products
    (
        productName, productDescription, productProductIdentificatorId,
        productMarkByProviderId, productCreatorId, productCreationDate,
        productStatusId
    )
    VALUES
    (
        'TENIS DEPORTIVOS FORO 3', 'Calzado de demostracion para carrito y pago',
        @IdentificadorID, @MarcaProveedorID, @UsuarioSistemaID, GETDATE(), 1
    );
END;

DECLARE @ProductoID INT =
(
    SELECT TOP (1) productId FROM SQM_GENERAL.Tbl_Products
    WHERE productName = 'TENIS DEPORTIVOS FORO 3' AND productStatusId = 1
);
DECLARE @MonedaID INT =
(
    SELECT TOP (1) currencyId FROM SQM_CATALOGS.Tbl_Currencies
    WHERE currencyISO = 'USD' AND currencyStatusId = 1
    ORDER BY currencyId
);

IF NOT EXISTS
(
    SELECT 1 FROM SQM_GENERAL.Tbl_ProductVariables
    WHERE productVariableProductId = @ProductoID
      AND productVariableValue = 'TALLA 42 NEGRO'
      AND productVariableStatusId = 1
)
BEGIN
    INSERT INTO SQM_GENERAL.Tbl_ProductVariables
    (
        productVariableProductId, productVariableValue, productVariablePrice,
        productVariableCurrencyId, productVariableCreatorId,
        productVariableCreationDate, productVariableStatusId
    )
    VALUES
    (@ProductoID, 'TALLA 42 NEGRO', 59.99, @MonedaID, @UsuarioSistemaID, GETDATE(), 1);
END;

DECLARE @ProductoVariableID INT =
(
    SELECT TOP (1) productVariableId
    FROM SQM_GENERAL.Tbl_ProductVariables
    WHERE productVariableProductId = @ProductoID
      AND productVariableValue = 'TALLA 42 NEGRO'
      AND productVariableStatusId = 1
);

IF NOT EXISTS
(
    SELECT 1 FROM SQM_GENERAL.Tbl_Stocks
    WHERE stockProductVariableId = @ProductoVariableID AND stockStatusId = 1
)
BEGIN
    INSERT INTO SQM_GENERAL.Tbl_Stocks
    (
        stockProductVariableId, stockQuantity, stockFactoryDate,
        stockExpirationDate, stockCreatorId, stockCreationDate, stockStatusId
    )
    VALUES
    (
        @ProductoVariableID, 20, CAST(GETDATE() AS DATE),
        DATEADD(YEAR, 10, CAST(GETDATE() AS DATE)),
        @UsuarioSistemaID, GETDATE(), 1
    );
END
ELSE
BEGIN
    UPDATE SQM_GENERAL.Tbl_Stocks
    SET stockQuantity = CASE WHEN stockQuantity < 20 THEN 20 ELSE stockQuantity END,
        stockModificationDate = GETDATE(),
        stockModificatorId = @UsuarioSistemaID
    WHERE stockProductVariableId = @ProductoVariableID AND stockStatusId = 1;
END;

SELECT
    @UsuarioDemoID AS userId,
    'FORO3_DEMO' AS username,
    'ClaveDemo123!' AS [password],
    (SELECT TOP (1) userAddressId
     FROM SQM_GENERAL.Tbl_UserAddress
     WHERE userAddressUserId = @UsuarioDemoID AND userAddressStatusId = 1
     ORDER BY userAddressIsPrincipal DESC, userAddressId) AS addressId,
    (SELECT TOP (1) userPaymentMethodId
     FROM SQM_GENERAL.Tbl_UserPaymentMethods
     WHERE userPaymentMethodUserId = @UsuarioDemoID AND userPaymentMethodStatusId = 1
     ORDER BY userPaymentMethodId) AS paymentMethodId,
    @ProductoVariableID AS productVariableId;
GO
