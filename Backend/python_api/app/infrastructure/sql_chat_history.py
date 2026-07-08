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
        with get_connection("DB_EcommerceAgent") as connection:
            cursor = connection.cursor()
            resolved_conversation_id = self._ensure_conversation(cursor, user_id, conversation_id)
            self._save_message(cursor, resolved_conversation_id, False, user_message, None)
            self._save_message(cursor, resolved_conversation_id, True, bot_reply, activated_rule_id)
            connection.commit()
            return resolved_conversation_id

    def get_conversation_messages(self, conversation_id: int) -> list[dict]:
        with get_connection("DB_EcommerceAgent") as connection:
            cursor = connection.cursor()
            cursor.execute(
                "EXEC dbo.sp_ObtenerHistorialConversacion @ConversacionID = ?",
                conversation_id,
            )
            columns = [column[0] for column in cursor.description]
            rows = cursor.fetchall()
            return [self._row_to_dict(row, columns) for row in rows]

    def get_user_conversations(self, user_id: str) -> list[dict]:
        with get_connection("DB_EcommerceAgent") as connection:
            cursor = connection.cursor()
            cursor.execute(
                "EXEC dbo.sp_ObtenerConversacionesUsuario @UsuarioID = ?",
                user_id,
            )
            columns = [column[0] for column in cursor.description]
            rows = cursor.fetchall()
            return [self._row_to_dict(row, columns) for row in rows]

    def close_conversation(self, conversation_id: int) -> None:
        with get_connection("DB_EcommerceAgent") as connection:
            cursor = connection.cursor()
            cursor.execute(
                "EXEC dbo.sp_CerrarConversacion @ConversacionID = ?",
                conversation_id,
            )
            connection.commit()

    def delete_conversation(self, conversation_id: int) -> None:
        with get_connection("DB_EcommerceAgent") as connection:
            cursor = connection.cursor()
            cursor.execute(
                "EXEC dbo.sp_EliminarConversacion @ConversacionID = ?",
                conversation_id,
            )
            connection.commit()

    def _ensure_conversation(self, cursor, user_id: str, conversation_id: int | None) -> int:
        if conversation_id not in (None, 0):
            return int(conversation_id)

        row = cursor.execute(
            "EXEC dbo.sp_CrearConversacion @UsuarioID = ?",
            user_id,
        ).fetchone()
        return int(row.ConversacionID)

    def _save_message(
        self,
        cursor,
        conversation_id: int,
        chat_bot: bool,
        text: str,
        activated_rule_id: int | None,
        metadata: str | None = None,
    ) -> None:
        cursor.execute(
            """
            EXEC dbo.sp_GuardarMensaje
                @ConversacionID = ?,
                @ChatBot = ?,
                @Texto = ?,
                @ReglaActivadaID = ?,
                @MetaData = ?
            """,
            conversation_id,
            1 if chat_bot else 0,
            text,
            activated_rule_id,
            metadata,
        )

    def _row_to_dict(self, row, columns: list[str]) -> dict:
        return {
            column: getattr(row, column)
            for column in columns
        }
