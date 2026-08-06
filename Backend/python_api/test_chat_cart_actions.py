import unittest

from app.application.chat_use_case import ResolveChatMessageUseCase
from app.domain.entities import AgentRule


class FakeCartGateway:
    def __init__(self):
        self.added = None

    def add_product(self, user_id, product_variable_id, quantity):
        self.added = (user_id, product_variable_id, quantity)
        return 200, "Producto agregado correctamente.", [{"quantity": quantity}]


class FakeHistoryGateway:
    def log_interaction(self, **_kwargs):
        return 9


class FakeRuleCache:
    def get_rules(self):
        return [
            AgentRule(
                rule_id=6,
                name="Agregar Producto al Carrito",
                action_python="agregar_carrito_db",
                keywords=["agregar al carrito"],
                templates=["Producto agregado."],
            )
        ]


class CartActionTest(unittest.TestCase):
    def test_add_product_uses_session_user_and_structured_parameters(self):
        cart = FakeCartGateway()
        use_case = ResolveChatMessageUseCase(
            search_gateway=object(),
            cart_gateway=cart,
            history_gateway=FakeHistoryGateway(),
            rule_cache=FakeRuleCache(),
        )

        response = use_case.execute(
            "agregar al carrito",
            user_id="7",
            parameters={"productVariableId": 3, "quantity": 2},
        )

        self.assertEqual((7, 3, 2), cart.added)
        self.assertEqual(200, response.result_code)
        self.assertEqual([{"quantity": 2}], response.data)
        self.assertEqual(9, response.conversation_id)


if __name__ == "__main__":
    unittest.main()
