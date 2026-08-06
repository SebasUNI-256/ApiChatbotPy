from typing import Any

from .sql_server import get_connection


class SqlServerCheckoutGateway:
    def list_options(self, user_id: int) -> dict[str, list[dict[str, Any]]]:
        with get_connection("DB_ECOMMERCE") as connection:
            cursor = connection.cursor()
            address_rows = cursor.execute(
                """
                SELECT
                    userAddressId AS addressId,
                    userAddressZIPCode AS zipCode,
                    userAddressDescription AS description,
                    userAddressIsPrincipal AS isPrincipal
                FROM SQM_GENERAL.Tbl_UserAddress
                WHERE userAddressUserId = ?
                  AND userAddressStatusId = 1
                ORDER BY userAddressIsPrincipal DESC, userAddressId
                """,
                user_id,
            ).fetchall()

            cursor.execute(
                "OPEN SYMMETRIC KEY KEY_HASH DECRYPTION BY CERTIFICATE CERT_ECOMMERCE"
            )
            payment_rows = cursor.execute(
                """
                SELECT
                    P.userPaymentMethodId AS paymentMethodId,
                    T.paymentMethodTypeId AS paymentMethodTypeId,
                    T.paymentMethodTypeName AS typeName,
                    RIGHT(SQM_SECURITY.Fn_DecryptByKey(P.userPaymentMethodCardNumber), 4) AS lastFour,
                    SQM_SECURITY.Fn_DecryptByKey(P.userPaymentMethodExpirationDate) AS expirationDate,
                    P.userPaymentMethodCardHolderName AS cardHolderName
                FROM SQM_GENERAL.Tbl_UserPaymentMethods P
                INNER JOIN SQM_CATALOGS.Tbl_PaymentMethodTypes T
                    ON T.paymentMethodTypeId = P.userPaymentMethodPaymentMethodTypeId
                WHERE P.userPaymentMethodUserId = ?
                  AND P.userPaymentMethodStatusId = 1
                  AND T.paymentMethodTypeStatusId = 1
                ORDER BY P.userPaymentMethodId
                """,
                user_id,
            ).fetchall()
            cursor.execute("CLOSE SYMMETRIC KEY KEY_HASH")

            type_rows = cursor.execute(
                """
                SELECT
                    paymentMethodTypeId,
                    paymentMethodTypeName AS name,
                    paymentMethodTypeDescription AS description
                FROM SQM_CATALOGS.Tbl_PaymentMethodTypes
                WHERE paymentMethodTypeStatusId = 1
                  AND paymentMethodTypeName LIKE 'TARJETA%'
                ORDER BY paymentMethodTypeId
                """
            ).fetchall()

            order_rows = cursor.execute(
                """
                SELECT
                    O.orderId,
                    O.orderCreationDate,
                    S.statusName AS status,
                    O.orderTotal AS total,
                    O.orderCurrencyId AS currencyId
                FROM SQM_GENERAL.Tbl_PaymentOrders O
                INNER JOIN SQM_CATALOGS.Tbl_Status S
                    ON S.statusId = O.orderStatusId
                WHERE O.orderUserId = ?
                ORDER BY O.orderCreationDate DESC, O.orderId DESC
                """,
                user_id,
            ).fetchall()

        return {
            "addresses": [
                {
                    "addressId": int(row.addressId),
                    "zipCode": int(row.zipCode),
                    "description": str(row.description),
                    "isPrincipal": bool(row.isPrincipal),
                }
                for row in address_rows
            ],
            "paymentMethods": [
                {
                    "paymentMethodId": int(row.paymentMethodId),
                    "paymentMethodTypeId": int(row.paymentMethodTypeId),
                    "typeName": str(row.typeName),
                    "lastFour": str(row.lastFour),
                    "expirationDate": str(row.expirationDate),
                    "cardHolderName": str(row.cardHolderName),
                }
                for row in payment_rows
            ],
            "paymentMethodTypes": [
                {
                    "paymentMethodTypeId": int(row.paymentMethodTypeId),
                    "name": str(row.name),
                    "description": str(row.description),
                }
                for row in type_rows
            ],
            "orders": [
                {
                    "orderId": int(row.orderId),
                    "orderCreationDate": row.orderCreationDate.isoformat(),
                    "status": str(row.status),
                    "total": float(row.total),
                    "currencyId": int(row.currencyId),
                }
                for row in order_rows
            ],
        }

    def add_address(
        self,
        user_id: int,
        zip_code: int,
        description: str,
        is_principal: bool,
    ) -> dict[str, Any]:
        with get_connection("DB_ECOMMERCE") as connection:
            cursor = connection.cursor()
            user_row = cursor.execute(
                "SELECT userCountryId FROM SQM_SECURITY.Tbl_Users WHERE userId = ? AND userStatusId = 1",
                user_id,
            ).fetchone()
            if user_row is None:
                raise ValueError("El usuario autenticado no existe.")

            has_active_address = cursor.execute(
                """
                SELECT CASE WHEN EXISTS
                (
                    SELECT 1
                    FROM SQM_GENERAL.Tbl_UserAddress
                    WHERE userAddressUserId = ? AND userAddressStatusId = 1
                ) THEN 1 ELSE 0 END
                """,
                user_id,
            ).fetchone()[0]
            resolved_principal = bool(is_principal or not has_active_address)

            if resolved_principal:
                cursor.execute(
                    """
                    UPDATE SQM_GENERAL.Tbl_UserAddress
                    SET userAddressIsPrincipal = 0,
                        userAddressModificatorId = ?,
                        userAddressModificationDate = GETDATE()
                    WHERE userAddressUserId = ? AND userAddressStatusId = 1
                    """,
                    user_id,
                    user_id,
                )

            row = cursor.execute(
                """
                INSERT INTO SQM_GENERAL.Tbl_UserAddress
                (
                    userAddressUserId, userAddressCountryId, userAddressZIPCode,
                    userAddressDescription, userAddressIsPrincipal,
                    userAddressCreatorId, userAddressCreationDate, userAddressStatusId
                )
                OUTPUT INSERTED.userAddressId
                VALUES (?, ?, ?, ?, ?, ?, GETDATE(), 1)
                """,
                user_id,
                int(user_row.userCountryId),
                zip_code,
                description,
                resolved_principal,
                user_id,
            ).fetchone()
            connection.commit()

        return {
            "addressId": int(row[0]),
            "zipCode": zip_code,
            "description": description,
            "isPrincipal": resolved_principal,
        }

    def add_payment_method(
        self,
        user_id: int,
        payment_method_type_id: int,
        card_number: str,
        expiration_date: str,
        cvv: str,
        card_holder_name: str,
    ) -> dict[str, Any]:
        with get_connection("DB_ECOMMERCE") as connection:
            cursor = connection.cursor()
            type_row = cursor.execute(
                """
                SELECT paymentMethodTypeName
                FROM SQM_CATALOGS.Tbl_PaymentMethodTypes
                WHERE paymentMethodTypeId = ? AND paymentMethodTypeStatusId = 1
                """,
                payment_method_type_id,
            ).fetchone()
            if type_row is None:
                raise ValueError("El tipo de metodo de pago no existe.")

            cursor.execute(
                "OPEN SYMMETRIC KEY KEY_HASH DECRYPTION BY CERTIFICATE CERT_ECOMMERCE"
            )
            row = cursor.execute(
                """
                INSERT INTO SQM_GENERAL.Tbl_UserPaymentMethods
                (
                    userPaymentMethodUserId,
                    userPaymentMethodPaymentMethodTypeId,
                    userPaymentMethodCardNumber,
                    userPaymentMethodExpirationDate,
                    userPaymentMethodCVV,
                    userPaymentMethodCardHolderName,
                    userPaymentMethodCreatorId,
                    userPaymentMethodCreationDate,
                    userPaymentMethodStatusId
                )
                OUTPUT INSERTED.userPaymentMethodId
                VALUES
                (
                    ?, ?,
                    SQM_SECURITY.Fn_EncryptByKey(?),
                    SQM_SECURITY.Fn_EncryptByKey(?),
                    SQM_SECURITY.Fn_EncryptByKey(?),
                    ?, ?, GETDATE(), 1
                )
                """,
                user_id,
                payment_method_type_id,
                card_number,
                expiration_date,
                cvv,
                card_holder_name,
                user_id,
            ).fetchone()
            cursor.execute("CLOSE SYMMETRIC KEY KEY_HASH")
            connection.commit()

        return {
            "paymentMethodId": int(row[0]),
            "paymentMethodTypeId": payment_method_type_id,
            "typeName": str(type_row.paymentMethodTypeName),
            "lastFour": card_number[-4:],
            "expirationDate": expiration_date,
            "cardHolderName": card_holder_name,
        }
