import os


def get_sql_server() -> str:
    return os.getenv("SQL_SERVER", r".\SQLEXPRESS")


def get_sql_driver() -> str:
    return os.getenv("SQL_DRIVER", "ODBC Driver 17 for SQL Server")
