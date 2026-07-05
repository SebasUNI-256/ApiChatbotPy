from collections.abc import Sequence

from app.domain.entities import AgentRule


class InMemoryRuleCache:
    def __init__(self) -> None:
        self._rules: list[AgentRule] = []

    def set_rules(self, rules: Sequence[AgentRule]) -> None:
        self._rules = list(rules)

    def get_rules(self) -> list[AgentRule]:
        return list(self._rules)
