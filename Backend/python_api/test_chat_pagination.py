import unittest

from app.application.chat_use_case import ResolveChatMessageUseCase
from app.domain.entities import AgentRule, ChatResponse
from app.presentation.serializers import response_to_dict


class FakeProductSearchGateway:
    def __init__(self):
        self.calls = []

    def search_products(self, filter_text, user_id, conversation_id, page_number):
        self.calls.append((filter_text, user_id, conversation_id, page_number))
        return (
            [{"ProductID": 1, "ProductVariableID": 7}],
            200,
            "Busqueda realizada satisfactoriamente.",
            15,
            page_number,
            10,
            22,
        )

    def has_products(self, _filter_text):
        return True


class FakeCartGateway:
    pass


class FakeHistoryGateway:
    pass


class FakeSearchRuleCache:
    def get_rules(self):
        return [
            AgentRule(
                rule_id=1,
                name="Buscar Producto",
                action_python="buscar_producto_en_db",
                keywords=["tenis"],
                templates=["Resultados encontrados."],
            )
        ]


class ProductPaginationTest(unittest.TestCase):
    def setUp(self):
        self.search = FakeProductSearchGateway()
        self.use_case = ResolveChatMessageUseCase(
            search_gateway=self.search,
            cart_gateway=FakeCartGateway(),
            history_gateway=FakeHistoryGateway(),
            rule_cache=FakeSearchRuleCache(),
        )

    def test_search_uses_first_page_by_default(self):
        response = self.use_case.execute("quiero tenis", user_id="8")

        self.assertEqual(("tenis", "8", None, 1), self.search.calls[0])
        self.assertEqual(1, response.page_number)
        self.assertEqual(10, response.page_size)
        self.assertEqual(22, response.total_rows)
        self.assertEqual(7, response.products[0]["ProductVariableID"])

    def test_search_forwards_requested_page(self):
        response = self.use_case.execute(
            "quiero tenis",
            user_id="8",
            conversation_id=15,
            page_number="2",
        )

        self.assertEqual(("tenis", "8", 15, 2), self.search.calls[0])
        self.assertEqual(2, response.page_number)

    def test_invalid_page_returns_400_without_querying_database(self):
        for value in (0, -1, "texto", True):
            with self.subTest(value=value):
                self.search.calls.clear()

                response = self.use_case.execute(
                    "quiero tenis",
                    user_id="8",
                    page_number=value,
                )

                self.assertEqual(400, response.result_code)
                self.assertEqual([], self.search.calls)
                self.assertIsNone(response.page_number)

    def test_serialized_search_response_includes_pagination(self):
        payload = response_to_dict(
            ChatResponse(
                result_code=200,
                result_message="OK",
                rule="Buscar Producto",
                reply="Resultados encontrados.",
                products=[{"ProductVariableID": 7}],
                page_number=2,
                page_size=10,
                total_rows=22,
            )
        )

        self.assertEqual(2, payload["pageNumber"])
        self.assertEqual(10, payload["pageSize"])
        self.assertEqual(22, payload["totalRows"])

    def test_serialized_non_search_response_omits_pagination(self):
        payload = response_to_dict(
            ChatResponse(
                result_code=200,
                result_message="OK",
                rule="Saludo Inicial",
                reply="Hola.",
            )
        )

        self.assertNotIn("pageNumber", payload)
        self.assertNotIn("pageSize", payload)
        self.assertNotIn("totalRows", payload)


if __name__ == "__main__":
    unittest.main()
