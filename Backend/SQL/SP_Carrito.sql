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
                -- ponytail: el inventario actual usa una fila de stock por variante.
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

        -- ponytail: impuestos y envio siguen en cero hasta que existan reglas de calculo.
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
