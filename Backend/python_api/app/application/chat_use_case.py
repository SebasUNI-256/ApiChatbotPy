import random
from typing import Any

from app.domain.entities import AgentRule, ChatResponse
from app.domain.ports import CartGateway, ChatHistoryGateway, ProductSearchGateway, RuleCache

from .text_utils import normalize_text


class ResolveChatMessageUseCase:
    def __init__(
        self,
        search_gateway: ProductSearchGateway,
        cart_gateway: CartGateway,
        history_gateway: ChatHistoryGateway,
        rule_cache: RuleCache,
    ) -> None:
        self._search_gateway = search_gateway
        self._cart_gateway = cart_gateway
        self._history_gateway = history_gateway
        self._rule_cache = rule_cache

    def execute(
        self,
        message: str,
        user_id: str = "postman-user",
        conversation_id: int | None = None,
        parameters: dict[str, Any] | None = None,
        page_number: Any = 1,
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

        if rule.action_python in {
            "agregar_carrito_db",
            "consultar_carrito_db",
            "eliminar_producto_carrito_db",
            "procesar_pago_carrito_db",
            "consultar_orden_pago_db",
        }:
            return self._execute_cart_action(
                rule,
                clean_message,
                int(user_id),
                conversation_id,
                parameters or {},
            )

        if rule.action_python == "buscar_producto_en_db":
            search_text = self._extract_search_text(clean_message)
            try:
                resolved_input_page = self._parse_positive_int(page_number, "pageNumber")
            except ValueError as error:
                return ChatResponse(
                    result_code=400,
                    result_message=str(error),
                    rule=rule.name,
                    reply=str(error),
                    conversation_id=conversation_id,
                    page_number=None,
                    page_size=None,
                    total_rows=None,
                )

            (
                products,
                result_code,
                result_message,
                resolved_conversation_id,
                resolved_page_number,
                page_size,
                total_rows,
            ) = self._search_gateway.search_products(
                search_text,
                user_id,
                conversation_id,
                resolved_input_page,
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
                page_number=resolved_page_number,
                page_size=page_size,
                total_rows=total_rows,
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
            try:
                resolved_input_page = self._parse_positive_int(page_number, "pageNumber")
            except ValueError as error:
                return ChatResponse(
                    result_code=400,
                    result_message=str(error),
                    rule=rule.name,
                    reply=str(error),
                    conversation_id=conversation_id,
                )

            (
                products,
                result_code,
                result_message,
                resolved_page_number,
                page_size,
                total_rows,
            ) = self._search_gateway.search_offers(resolved_input_page)
            reply = (
                self._choose_reply(rule, "Estas son las ofertas activas disponibles en este momento.")
                if result_code == 200
                else result_message
            )
            resolved_conversation_id = self._history_gateway.log_interaction(
                user_id=user_id,
                conversation_id=conversation_id,
                user_message=clean_message,
                bot_reply=reply,
                activated_rule_id=rule.rule_id,
            )
            return ChatResponse(
                result_code=result_code,
                result_message=result_message,
                rule=rule.name,
                reply=reply,
                conversation_id=resolved_conversation_id,
                products=products,
                page_number=resolved_page_number,
                page_size=page_size,
                total_rows=total_rows,
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

    def _execute_cart_action(
        self,
        rule: AgentRule,
        message: str,
        user_id: int,
        conversation_id: int | None,
        parameters: dict[str, Any],
    ) -> ChatResponse:
        try:
            if rule.action_python == "agregar_carrito_db":
                result_code, result_message, data = self._cart_gateway.add_product(
                    user_id,
                    self._positive_int(parameters, "productVariableId"),
                    self._positive_int(parameters, "quantity"),
                )
            elif rule.action_python == "consultar_carrito_db":
                result_code, result_message, data = self._cart_gateway.get_cart(user_id)
            elif rule.action_python == "eliminar_producto_carrito_db":
                result_code, result_message, data = self._cart_gateway.remove_product(
                    user_id,
                    self._positive_int(parameters, "cartDetailId"),
                )
            elif rule.action_python == "procesar_pago_carrito_db":
                result_code, result_message, data = self._cart_gateway.checkout(
                    user_id,
                    self._positive_int(parameters, "addressId"),
                    self._positive_int(parameters, "paymentMethodId"),
                )
            else:
                result_code, result_message, data = self._cart_gateway.get_order(
                    user_id,
                    self._positive_int(parameters, "orderId"),
                )
        except ValueError as error:
            result_code, result_message, data = 400, str(error), None

        reply = (
            self._choose_reply(rule, result_message)
            if result_code < 400
            else result_message
        )
        resolved_conversation_id = self._history_gateway.log_interaction(
            user_id=str(user_id),
            conversation_id=conversation_id,
            user_message=message,
            bot_reply=reply,
            activated_rule_id=rule.rule_id,
        )
        return ChatResponse(
            result_code=result_code,
            result_message=result_message,
            rule=rule.name,
            reply=reply,
            conversation_id=resolved_conversation_id,
            data=data,
        )

    def _positive_int(self, parameters: dict[str, Any], name: str) -> int:
        return self._parse_positive_int(parameters.get(name), name)

    def _parse_positive_int(self, raw_value: Any, name: str) -> int:
        if isinstance(raw_value, bool) or not isinstance(raw_value, (int, str)):
            raise ValueError(f"El parametro {name} es obligatorio.")
        try:
            value = int(raw_value)
        except ValueError as error:
            raise ValueError(f"El parametro {name} debe ser un entero positivo.") from error
        if value <= 0:
            raise ValueError(f"El parametro {name} debe ser un entero positivo.")
        return value

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
