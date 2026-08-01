import os


def get_sql_server() -> str:
    return os.getenv("SQL_SERVER", r".\SQLEXPRESS")


def get_sql_driver() -> str:
    return os.getenv("SQL_DRIVER", "ODBC Driver 17 for SQL Server")


def get_session_secret() -> str:
    return os.getenv("SESSION_SECRET", "dev-only-change-this-session-secret")


def get_session_secure() -> bool:
    return os.getenv("SESSION_SECURE", "false").lower() in {"1", "true", "yes"}


def get_cors_origins() -> list[str]:
    raw_origins = os.getenv("CORS_ORIGINS", "http://localhost:5173")
    return [origin.strip() for origin in raw_origins.split(",") if origin.strip()]
