from collections.abc import Sequence
from typing import Protocol

from .entities import AgentRule


class RuleRepository(Protocol):
    def load_rules(self) -> list[AgentRule]: ...


class ProductSearchGateway(Protocol):
    def search_products(
        self,
        filter_text: str,
        user_id: str,
        conversation_id: int | None,
    ) -> tuple[list[dict], int, str, int]: ...
    def has_products(self, filter_text: str) -> bool: ...


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
