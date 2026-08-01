import unittest
from datetime import date
from unittest.mock import patch

from pydantic import ValidationError

from app.presentation import api as api_module


class RequestWithSession:
    def __init__(self, user_id: int):
        self.session = {"userId": user_id}


class CheckoutEndpointsTests(unittest.TestCase):
    def setUp(self):
        self.user = {
            "id": 8,
            "username": "FORO3_DEMO",
            "fullName": "Usuario Demo",
            "email": "foro3.demo@example.com",
            "role": "CLIENTE",
        }
        self.request = RequestWithSession(8)
        self.auth_patcher = patch.object(
            api_module.auth_gateway,
            "get_user",
            return_value=self.user,
        )
        self.auth_patcher.start()
        self.addCleanup(self.auth_patcher.stop)

    def test_list_checkout_options_uses_authenticated_user(self):
        expected = {
            "addresses": [],
            "paymentMethods": [],
            "paymentMethodTypes": [],
            "orders": [],
        }
        with patch.object(
            api_module.checkout_gateway,
            "list_options",
            return_value=expected,
        ) as list_options:
            result = api_module.get_checkout_options(self.request)

        self.assertEqual(expected, result)
        list_options.assert_called_once_with(8)

    def test_create_address_returns_the_owned_address(self):
        address = {
            "addressId": 12,
            "zipCode": 10001,
            "description": "Residencial de prueba, casa 12",
            "isPrincipal": True,
        }
        payload = api_module.CheckoutAddressRequest(
            zipCode=10001,
            description="  Residencial   de prueba, casa 12  ",
            isPrincipal=True,
        )
        with patch.object(
            api_module.checkout_gateway,
            "add_address",
            return_value=address,
        ) as add_address:
            result = api_module.add_checkout_address(payload, self.request)

        self.assertEqual(address, result["address"])
        add_address.assert_called_once_with(
            8,
            10001,
            "Residencial de prueba, casa 12",
            True,
        )

    def test_rejects_expired_payment_method_before_using_sql(self):
        expired = f"{date.today().year - 1}-12"
        with self.assertRaises(ValidationError):
            api_module.CheckoutPaymentMethodRequest(
                paymentMethodTypeId=1,
                cardNumber="4111111111111111",
                expirationDate=expired,
                cvv="123",
                cardHolderName="USUARIO FORO DEMO",
            )


if __name__ == "__main__":
    unittest.main()
