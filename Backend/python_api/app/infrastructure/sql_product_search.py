from decimal import Decimal
from typing import Any

from .sql_server import get_connection


class SqlServerProductSearchGateway:
    def search_products(
        self,
        filter_text: str,
        user_id: str,
        conversation_id: int | None,
    ) -> tuple[list[dict[str, Any]], int, str, int]:
        sql = """
        SET NOCOUNT ON;
        DECLARE @o_ConversacionID BIGINT;
        DECLARE @o_ResultCode INT;
        DECLARE @o_ResultMessage VARCHAR(500);

        EXEC dbo.sp_BuscarProductosAgente
            @i_FilterText = ?,
            @i_UsuarioID = ?,
            @i_ConversacionID = ?,
            @o_ConversacionID = @o_ConversacionID OUTPUT,
            @o_ResultCode = @o_ResultCode OUTPUT,
            @o_ResultMessage = @o_ResultMessage OUTPUT;

        SELECT
            @o_ConversacionID AS ConversationID,
            @o_ResultCode AS ResultCode,
            @o_ResultMessage AS ResultMessage;
        """

        products: list[dict[str, Any]] = []
        result_code = 500
        result_message = "No fue posible obtener el resultado del procedimiento."
        resolved_conversation_id = 0

        with get_connection("DB_EcommerceAgent") as connection:
            cursor = connection.cursor()
            cursor.execute(sql, filter_text, user_id, conversation_id)

            if cursor.description:
                columns = [column[0] for column in cursor.description]
                for row in cursor.fetchall():
                    products.append(
                        {
                            column: self._serialize_value(getattr(row, column))
                            for column in columns
                        }
                    )

            while cursor.nextset():
                if not cursor.description:
                    continue
                output_row = cursor.fetchone()
                if output_row:
                    resolved_conversation_id = int(output_row.ConversationID)
                    result_code = int(output_row.ResultCode)
                    result_message = str(output_row.ResultMessage)
                    break

        return products, result_code, result_message, resolved_conversation_id

    def has_products(self, filter_text: str) -> bool:
        clean_text = filter_text.strip()
        if not clean_text:
            return False

        sql = """
        DECLARE @Buscar VARCHAR(102) = '%' + LTRIM(RTRIM(?)) + '%';

        SELECT TOP 1 1
        FROM [DB_ECOMMERCE].[SQM_GENERAL].[VW_GENERAL_PRODUCTS] WITH (NOLOCK)
        WHERE ProductName LIKE @Buscar
            OR ProductVariableName LIKE @Buscar
            OR CategoryName LIKE @Buscar
            OR SubcategoryName LIKE @Buscar
            OR SegmentName LIKE @Buscar
            OR MarkName LIKE @Buscar
            OR ProviderName LIKE @Buscar;
        """
        with get_connection("DB_EcommerceAgent") as connection:
            cursor = connection.cursor()
            row = cursor.execute(sql, clean_text).fetchone()
            return row is not None

    def _serialize_value(self, value: Any) -> Any:
        if isinstance(value, Decimal):
            return float(value)
        return value
