import pyodbc

from .config import get_sql_driver, get_sql_server


def build_connection_string(database: str) -> str:
    return (
        f"Driver={{{get_sql_driver()}}};"
        f"Server={get_sql_server()};"
        f"Database={database};"
        "Trusted_Connection=yes;"
        "TrustServerCertificate=yes;"
    )


def get_connection(database: str) -> pyodbc.Connection:
    return pyodbc.connect(build_connection_string(database))
