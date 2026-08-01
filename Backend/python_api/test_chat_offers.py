import unittest

from app.application.chat_use_case import ResolveChatMessageUseCase
from app.domain.entities import AgentRule


class FakeProductSearchGateway:
    def __init__(self):
        self.pages = []

    def search_offers(self, page_number):
        self.pages.append(page_number)
        return (
            [
                {
                    "ProductVariableID": 4,
                    "OfferName": "Ultraboost 10%",
                    "OriginalPrice": 110.0,
                    "DiscountPercentage": 10.0,
                    "ProductVariablePrice": 99.0,
                }
            ],
            200,
            "Ofertas consultadas satisfactoriamente.",
            page_number,
            10,
            2,
        )


class FakeCartGateway:
    pass


class FakeHistoryGateway:
    def log_interaction(self, **_kwargs):
        return 21


class FakeRuleCache:
    def get_rules(self):
        return [
            AgentRule(
                rule_id=5,
                name="Busqueda por Ofertas Descuentos",
                action_python="buscar_ofertas_db",
                keywords=["ofertas"],
                templates=["Estas son las ofertas activas."],
            )
        ]


class OfferSearchTest(unittest.TestCase):
    def setUp(self):
        self.search = FakeProductSearchGateway()
        self.use_case = ResolveChatMessageUseCase(
            search_gateway=self.search,
            cart_gateway=FakeCartGateway(),
            history_gateway=FakeHistoryGateway(),
            rule_cache=FakeRuleCache(),
        )

    def test_offer_rule_returns_discounted_products(self):
        response = self.use_case.execute("ver ofertas", user_id="8")

        self.assertEqual([1], self.search.pages)
        self.assertEqual(200, response.result_code)
        self.assertEqual(21, response.conversation_id)
        self.assertEqual("Ultraboost 10%", response.products[0]["OfferName"])
        self.assertEqual(110.0, response.products[0]["OriginalPrice"])
        self.assertEqual(99.0, response.products[0]["ProductVariablePrice"])
        self.assertEqual(10.0, response.products[0]["DiscountPercentage"])

    def test_invalid_offer_page_does_not_query_database(self):
        response = self.use_case.execute("ofertas", user_id="8", page_number=0)

        self.assertEqual(400, response.result_code)
        self.assertEqual([], self.search.pages)


if __name__ == "__main__":
    unittest.main()
