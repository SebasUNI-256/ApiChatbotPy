from app.domain.entities import AgentRule

from .sql_server import get_connection


class SqlServerRuleRepository:
    def load_rules(self) -> list[AgentRule]:
        query = """
        SELECT
            r.ReglaID,
            r.NombreRegla,
            r.AccionPython,
            k.PalabraClave,
            p.TextoRespuesta
        FROM ReglasChatbot r
        LEFT JOIN PalabrasClaveRegla k
            ON k.ReglaID = r.ReglaID
            AND k.Activo = 1
        LEFT JOIN PlantillasRespuesta p
            ON p.ReglaID = r.ReglaID
            AND p.Activo = 1
        WHERE r.Activo = 1
        ORDER BY r.ReglaID;
        """

        indexed_rules: dict[int, AgentRule] = {}
        with get_connection("DB_EcommerceAgent") as connection:
            cursor = connection.cursor()
            for row in cursor.execute(query):
                rule = indexed_rules.setdefault(
                    row.ReglaID,
                    AgentRule(
                        rule_id=row.ReglaID,
                        name=row.NombreRegla,
                        action_python=row.AccionPython,
                    ),
                )

                if row.PalabraClave and row.PalabraClave not in rule.keywords:
                    rule.keywords.append(row.PalabraClave)

                if row.TextoRespuesta and row.TextoRespuesta not in rule.templates:
                    rule.templates.append(row.TextoRespuesta)

        return list(indexed_rules.values())
