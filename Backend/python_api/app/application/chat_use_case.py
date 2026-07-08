import random

from app.domain.entities import AgentRule, ChatResponse
from app.domain.ports import ChatHistoryGateway, ProductSearchGateway, RuleCache

from .text_utils import normalize_text


class ResolveChatMessageUseCase:
    def __init__(
        self,
        search_gateway: ProductSearchGateway,
        history_gateway: ChatHistoryGateway,
        rule_cache: RuleCache,
    ) -> None:
        self._search_gateway = search_gateway
        self._history_gateway = history_gateway
        self._rule_cache = rule_cache

    def execute(
        self,
        message: str,
        user_id: str = "postman-user",
        conversation_id: int | None = None,
    ) -> ChatResponse:
        clean_message = message.strip()
        if not clean_message:
            return ChatResponse(
                result_code=400,
                result_message="El campo message es obligatorio.",
                rule=None,
                reply="Debes enviar un mensaje para procesar la peticion.",
                conversation_id=conversation_id,
            )

        rules = self._rule_cache.get_rules()
        rule = self._resolve_rule(clean_message, rules)

        if rule.action_python == "buscar_producto_en_db":
            search_text = self._extract_search_text(clean_message)
            products, result_code, result_message, resolved_conversation_id = self._search_gateway.search_products(
                search_text,
                user_id,
                conversation_id,
            )
            if not products and result_code == 200:
                result_message = "No se encontraron productos disponibles para ese filtro."
            reply = (
                self._choose_reply(rule, "He encontrado estas opciones para que puedas revisarlas.")
                if result_code == 200 and products
                else result_message
            )
            return ChatResponse(
                result_code=result_code,
                result_message=result_message,
                rule=rule.name,
                reply=reply,
                conversation_id=resolved_conversation_id,
                products=products,
            )

        if rule.action_python in {"cargar_saludos_db", "verificar_vip_saludo"}:
            reply = self._choose_reply(rule, "Hola, bienvenido a nuestra tienda.")
            resolved_conversation_id = self._history_gateway.log_interaction(
                user_id=user_id,
                conversation_id=conversation_id,
                user_message=clean_message,
                bot_reply=reply,
                activated_rule_id=rule.rule_id,
            )
            return ChatResponse(
                result_code=200,
                result_message="OK",
                rule=rule.name,
                reply=reply,
                conversation_id=resolved_conversation_id,
            )

        if rule.action_python == "buscar_ofertas_db":
            reply = self._choose_reply(
                rule,
                "Puedo ayudarte a revisar productos disponibles en el catalogo.",
            )
            resolved_conversation_id = self._history_gateway.log_interaction(
                user_id=user_id,
                conversation_id=conversation_id,
                user_message=clean_message,
                bot_reply=reply,
                activated_rule_id=rule.rule_id,
            )
            return ChatResponse(
                result_code=200,
                result_message="OK",
                rule=rule.name,
                reply=reply,
                conversation_id=resolved_conversation_id,
            )

        reply = self._choose_reply(
            rule,
            "No entendi tu peticion. Puedes escribir el producto que deseas buscar.",
        )
        resolved_conversation_id = self._history_gateway.log_interaction(
            user_id=user_id,
            conversation_id=conversation_id,
            user_message=clean_message,
            bot_reply=reply,
            activated_rule_id=rule.rule_id,
        )
        return ChatResponse(
            result_code=200,
            result_message="OK",
            rule=rule.name,
            reply=reply,
            conversation_id=resolved_conversation_id,
        )

    def _resolve_rule(self, message: str, rules: list[AgentRule]) -> AgentRule:
        normalized_message = normalize_text(message)
        selected_rule: AgentRule | None = None
        selected_keyword_length = -1

        for rule in rules:
            for keyword in rule.keywords:
                normalized_keyword = normalize_text(keyword)
                if normalized_keyword in normalized_message and len(normalized_keyword) > selected_keyword_length:
                    selected_rule = rule
                    selected_keyword_length = len(normalized_keyword)

        if selected_rule is not None:
            return selected_rule

        search_rule = self._find_rule_by_action(rules, "buscar_producto_en_db")
        if search_rule is not None:
            if self._search_gateway.has_products(self._extract_search_text(message)):
                return search_rule

        for rule in rules:
            if normalize_text(rule.name) == "no entendimos la peticion":
                return rule

        raise ValueError("No existe una regla de fallback configurada.")

    def _choose_reply(self, rule: AgentRule, default_message: str) -> str:
        if not rule.templates:
            return default_message
        return random.choice(rule.templates)

    def _find_rule_by_action(self, rules: list[AgentRule], action_python: str) -> AgentRule | None:
        for rule in rules:
            if rule.action_python == action_python:
                return rule
        return None

    def _extract_search_text(self, message: str) -> str:
        stopwords = {
            "quiero",
            "necesito",
            "busco",
            "buscar",
            "producto",
            "productos",
            "precio",
            "stock",
            "tienen",
            "tienes",
            "de",
            "del",
            "la",
            "el",
            "un",
            "una",
            "por",
            "favor",
        }
        words = [word for word in normalize_text(message).split() if word not in stopwords]
        return " ".join(words) if words else message.strip()
