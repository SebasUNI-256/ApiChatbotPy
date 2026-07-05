from dataclasses import dataclass, field
from typing import Any


@dataclass
class AgentRule:
    rule_id: int
    name: str
    action_python: str | None
    keywords: list[str] = field(default_factory=list)
    templates: list[str] = field(default_factory=list)


@dataclass
class ChatResponse:
    result_code: int
    result_message: str
    rule: str | None
    reply: str
    conversation_id: int | None = None
    products: list[dict[str, Any]] = field(default_factory=list)
