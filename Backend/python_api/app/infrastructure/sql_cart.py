from datetime import date, datetime
from decimal import Decimal
from typing import Any

from .sql_server import get_connection


class SqlServerCartGateway:
    def add_product(
        self,
        user_id: int,
        product_variable_id: int,
        quantity: int,
    ) -> tuple[int, str, Any]:
        with get_connection("DB_ECOMMERCE") as connection:
            cursor = connection.cursor()
            cursor.execute(
                "EXEC dbo.SP_AgregarProductoCarrito @UsuarioId = ?, @ProductoVariableId = ?, @Cantidad = ?",
                user_id,
                product_variable_id,
                quantity,
            )
            result_code, result_message, _ = self._read_status(cursor)
            connection.commit()

        if result_code >= 400:
            return result_code, result_message, None
        _, _, cart = self.get_cart(user_id)
        return result_code, result_message, cart

    def get_cart(self, user_id: int) -> tuple[int, str, Any]:
        with get_connection("DB_ECOMMERCE") as connection:
            cursor = connection.cursor()
            cursor.execute("EXEC dbo.SP_ConsultarCarrito @UsuarioId = ?", user_id)
            result_code, result_message, _ = self._read_status(cursor)
            return result_code, result_message, self._read_next_rows(cursor)

    def remove_product(self, user_id: int, cart_detail_id: int) -> tuple[int, str, Any]:
        with get_connection("DB_ECOMMERCE") as connection:
            cursor = connection.cursor()
            cursor.execute(
                "EXEC dbo.SP_EliminarProductoCarrito @UsuarioId = ?, @CartDetailId = ?",
                user_id,
                cart_detail_id,
            )
            result_code, result_message, _ = self._read_status(cursor)
            connection.commit()

        if result_code >= 400:
            return result_code, result_message, None
        _, _, cart = self.get_cart(user_id)
        return result_code, result_message, cart

    def checkout(
        self,
        user_id: int,
        address_id: int,
        payment_method_id: int,
    ) -> tuple[int, str, Any]:
        with get_connection("DB_ECOMMERCE") as connection:
            cursor = connection.cursor()
            cursor.execute(
                "EXEC dbo.SP_ProcesarPagoCarrito @UsuarioId = ?, @DireccionId = ?, @MetodoPagoId = ?",
                user_id,
                address_id,
                payment_method_id,
            )
            result_code, result_message, status = self._read_status(cursor)
            connection.commit()

        if result_code >= 400:
            return result_code, result_message, None
        order_code, order_message, order = self.get_order(user_id, int(status.OrderId))
        return (
            (result_code, result_message, order)
            if order_code < 400
            else (order_code, order_message, None)
        )

    def get_order(self, user_id: int, order_id: int) -> tuple[int, str, Any]:
        with get_connection("DB_ECOMMERCE") as connection:
            cursor = connection.cursor()
            cursor.execute(
                "EXEC dbo.SP_ConsultarOrdenPago @UsuarioId = ?, @OrderId = ?",
                user_id,
                order_id,
            )
            result_code, result_message, _ = self._read_status(cursor)
            if result_code >= 400:
                return result_code, result_message, None

            orders = self._read_next_rows(cursor)
            details = self._read_next_rows(cursor)
            return result_code, result_message, {
                "order": orders[0] if orders else None,
                "details": details,
            }

    def _read_status(self, cursor) -> tuple[int, str, Any]:
        row = cursor.fetchone()
        return int(row.ResultCode), str(row.ResultMessage), row

    def _read_next_rows(self, cursor) -> list[dict[str, Any]]:
        while cursor.nextset():
            if not cursor.description:
                continue
            columns = [column[0] for column in cursor.description]
            return [
                {column: self._serialize(getattr(row, column)) for column in columns}
                for row in cursor.fetchall()
            ]
        return []

    def _serialize(self, value: Any) -> Any:
        if isinstance(value, Decimal):
            return float(value)
        if isinstance(value, (date, datetime)):
            return value.isoformat()
        return value
