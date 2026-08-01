from collections.abc import Sequence
from typing import Any, Protocol

from .entities import AgentRule


class RuleRepository(Protocol):
    def load_rules(self) -> list[AgentRule]: ...


class ProductSearchGateway(Protocol):
    def search_products(
        self,
        filter_text: str,
        user_id: str,
        conversation_id: int | None,
        page_number: int,
    ) -> tuple[list[dict], int, str, int, int, int, int]: ...
    def search_offers(
        self,
        page_number: int,
    ) -> tuple[list[dict], int, str, int, int, int]: ...
    def has_products(self, filter_text: str) -> bool: ...


class CartGateway(Protocol):
    def add_product(
        self,
        user_id: int,
        product_variable_id: int,
        quantity: int,
    ) -> tuple[int, str, Any]: ...
    def get_cart(self, user_id: int) -> tuple[int, str, Any]: ...
    def remove_product(self, user_id: int, cart_detail_id: int) -> tuple[int, str, Any]: ...
    def checkout(
        self,
        user_id: int,
        address_id: int,
        payment_method_id: int,
    ) -> tuple[int, str, Any]: ...
    def get_order(self, user_id: int, order_id: int) -> tuple[int, str, Any]: ...


class ChatHistoryGateway(Protocol):
    def log_interaction(
        self,
        user_id: str,
        conversation_id: int | None,
        user_message: str,
        bot_reply: str,
        activated_rule_id: int | None,
    ) -> int: ...


class RuleCache(Protocol):
    def set_rules(self, rules: Sequence[AgentRule]) -> None: ...
    def get_rules(self) -> list[AgentRule]: ...
