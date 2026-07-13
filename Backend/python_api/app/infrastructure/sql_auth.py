import pyodbc

from .sql_server import get_connection


class DuplicateUsernameError(Exception):
    pass


class DuplicateEmailError(Exception):
    pass


class AuthConfigurationError(Exception):
    pass


class SqlServerAuthGateway:
    def register(self, data: dict) -> dict:
        try:
            with get_connection("DB_ECOMMERCE") as connection:
                cursor = connection.cursor()
                cursor.execute(
                    """
                    EXEC SQM_SECURITY.sp_RegistrarCliente
                        @NombreCompleto = ?, @NombreUsuario = ?, @Correo = ?,
                        @Contrasena = ?, @Telefono = ?, @PaisID = ?,
                        @GeneroID = ?, @FechaNacimiento = ?
                    """,
                    data["full_name"],
                    data["username"],
                    data["email"],
                    data["password"],
                    data["phone_number"],
                    data["country_id"],
                    data["gender_id"],
                    data["birth_date"],
                )
                row = cursor.fetchone()
                connection.commit()
                return self._user_to_dict(row)
        except pyodbc.Error as error:
            message = str(error)
            if "DUPLICATE_USERNAME" in message or "UX_Tbl_Users_UserName" in message:
                raise DuplicateUsernameError from error
            if "DUPLICATE_EMAIL" in message or "UX_Tbl_Users_UserEmail" in message:
                raise DuplicateEmailError from error
            if "[MISSING_" in message:
                raise AuthConfigurationError(message) from error
            raise

    def login(self, identifier: str, password: str) -> dict | None:
        with get_connection("DB_ECOMMERCE") as connection:
            row = connection.cursor().execute(
                "EXEC SQM_SECURITY.sp_IniciarSesion @Identificador = ?, @Contrasena = ?",
                identifier,
                password,
            ).fetchone()
            return None if row is None else self._user_to_dict(row)

    def get_user(self, user_id: int) -> dict | None:
        with get_connection("DB_ECOMMERCE") as connection:
            row = connection.cursor().execute(
                "EXEC SQM_SECURITY.sp_ObtenerUsuarioSesion @UsuarioID = ?",
                user_id,
            ).fetchone()
            return None if row is None else self._user_to_dict(row)

    def _user_to_dict(self, row) -> dict:
        return {
            "id": int(row.id),
            "username": row.username,
            "fullName": row.fullName,
            "email": row.email,
            "role": row.role,
        }
