from .sql_server import get_connection


class SqlServerChatHistoryGateway:
    def log_interaction(
        self,
        user_id: str,
        conversation_id: int | None,
        user_message: str,
        bot_reply: str,
        activated_rule_id: int | None,
    ) -> int:
        sql = """
        SET NOCOUNT ON;

        DECLARE @ConversationID BIGINT = ?;
        DECLARE @FechaActual DATETIME = GETDATE();

        IF @ConversationID IS NULL OR @ConversationID = 0
        BEGIN
            INSERT INTO dbo.HistorialConversaciones (UsuarioID, FechaInicio, FechaFin, Activo)
            VALUES (?, @FechaActual, NULL, 1);

            SET @ConversationID = SCOPE_IDENTITY();
        END;

        INSERT INTO dbo.HistorialMensajes (ConversacionID, ChatBot, Texto, FechaHora, ReglaActivadaID)
        VALUES (@ConversationID, 0, ?, @FechaActual, NULL);

        INSERT INTO dbo.HistorialMensajes (ConversacionID, ChatBot, Texto, FechaHora, ReglaActivadaID)
        VALUES (@ConversationID, 1, ?, @FechaActual, ?);

        SELECT @ConversationID AS ConversationID;
        """
        with get_connection("DB_EcommerceAgent") as connection:
            cursor = connection.cursor()
            row = cursor.execute(
                sql,
                conversation_id,
                user_id,
                user_message,
                bot_reply,
                activated_rule_id,
            ).fetchone()
            return int(row.ConversationID)
