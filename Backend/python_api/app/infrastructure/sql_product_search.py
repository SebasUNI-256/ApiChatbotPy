from decimal import Decimal
from typing import Any

from .sql_server import get_connection


class SqlServerProductSearchGateway:
    def search_products(
        self,
        filter_text: str,
        user_id: str,
        conversation_id: int | None,
        page_number: int,
    ) -> tuple[list[dict[str, Any]], int, str, int, int, int, int]:
        sql = """
        SET NOCOUNT ON;
        DECLARE @o_ConversacionID BIGINT;
        DECLARE @o_ResultCode INT;
        DECLARE @o_ResultMessage VARCHAR(500);
        DECLARE @o_pageNumber INT;
        DECLARE @o_pageSize INT;
        DECLARE @o_totalRows INT;

        EXEC dbo.sp_BuscarProductosAgente
            @i_FilterText = ?,
            @i_UsuarioID = ?,
            @i_ConversacionID = ?,
            @i_pageNumber = ?,
            @o_ConversacionID = @o_ConversacionID OUTPUT,
            @o_ResultCode = @o_ResultCode OUTPUT,
            @o_ResultMessage = @o_ResultMessage OUTPUT,
            @o_pageNumber = @o_pageNumber OUTPUT,
            @o_pageSize = @o_pageSize OUTPUT,
            @o_totalRows = @o_totalRows OUTPUT;

        SELECT
            @o_ConversacionID AS ConversationID,
            @o_ResultCode AS ResultCode,
            @o_ResultMessage AS ResultMessage,
            @o_pageNumber AS PageNumber,
            @o_pageSize AS PageSize,
            @o_totalRows AS TotalRows;
        """

        products: list[dict[str, Any]] = []
        result_code = 500
        result_message = "No fue posible obtener el resultado del procedimiento."
        resolved_conversation_id = 0
        resolved_page_number = page_number
        page_size = 10
        total_rows = 0

        with get_connection("DB_EcommerceAgent") as connection:
            cursor = connection.cursor()
            cursor.execute(sql, filter_text, user_id, conversation_id, page_number)

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
                    resolved_page_number = int(output_row.PageNumber)
                    page_size = int(output_row.PageSize)
                    total_rows = int(output_row.TotalRows)
                    break

        return (
            products,
            result_code,
            result_message,
            resolved_conversation_id,
            resolved_page_number,
            page_size,
            total_rows,
        )

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
