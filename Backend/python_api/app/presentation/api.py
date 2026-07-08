from contextlib import asynccontextmanager
from typing import Any

from fastapi import FastAPI, WebSocket, WebSocketDisconnect

from app.application.chat_use_case import ResolveChatMessageUseCase
from app.domain.entities import ChatResponse
from app.infrastructure.memory_rule_cache import InMemoryRuleCache
from app.infrastructure.sql_chat_history import SqlServerChatHistoryGateway
from app.infrastructure.sql_product_search import SqlServerProductSearchGateway
from app.infrastructure.sql_rule_repository import SqlServerRuleRepository

rule_repository = SqlServerRuleRepository()
rule_cache = InMemoryRuleCache()
search_gateway = SqlServerProductSearchGateway()
history_gateway = SqlServerChatHistoryGateway()
chat_use_case = ResolveChatMessageUseCase(
    search_gateway=search_gateway,
    history_gateway=history_gateway,
    rule_cache=rule_cache,
)


def response_to_dict(response: ChatResponse) -> dict[str, Any]:
    payload = {
        "resultCode": response.result_code,
        "resultMessage": response.result_message,
        "rule": response.rule,
        "reply": response.reply,
        "products": response.products,
    }
    if response.conversation_id is not None:
        payload["conversationId"] = response.conversation_id
    return payload


@asynccontextmanager
async def lifespan(app: FastAPI):
    rule_cache.set_rules(rule_repository.load_rules())
    yield


app = FastAPI(title="Ecommerce Agent API", lifespan=lifespan)


@app.get("/")
def healthcheck() -> dict[str, Any]:
    rules = rule_cache.get_rules()
    return {
        "status": "ok",
        "rulesLoaded": len(rules),
        "rules": [rule.name for rule in rules],
    }


@app.get("/conversations/{conversation_id}/messages")
def get_conversation_messages(conversation_id: int) -> dict[str, Any]:
    return {
        "conversationId": conversation_id,
        "messages": history_gateway.get_conversation_messages(conversation_id),
    }


@app.get("/users/{user_id}/conversations")
def get_user_conversations(user_id: str) -> dict[str, Any]:
    return {
        "userId": user_id,
        "conversations": history_gateway.get_user_conversations(user_id),
    }


@app.post("/conversations/{conversation_id}/close")
def close_conversation(conversation_id: int) -> dict[str, Any]:
    history_gateway.close_conversation(conversation_id)
    return {
        "resultCode": 200,
        "resultMessage": "Conversacion cerrada correctamente.",
        "conversationId": conversation_id,
    }


@app.delete("/conversations/{conversation_id}")
def delete_conversation(conversation_id: int) -> dict[str, Any]:
    history_gateway.delete_conversation(conversation_id)
    return {
        "resultCode": 200,
        "resultMessage": "Conversacion eliminada correctamente.",
        "conversationId": conversation_id,
    }


@app.websocket("/ws/chat")
async def websocket_chat(websocket: WebSocket):
    await websocket.accept()

    try:
        while True:
            payload = await websocket.receive_json()
            message = str(payload.get("message", ""))
            user_id = str(payload.get("userId", "postman-user"))
            raw_conversation_id = payload.get("conversationId")
            conversation_id = None if raw_conversation_id in (None, "", 0, "0") else int(raw_conversation_id)
            response = chat_use_case.execute(message, user_id=user_id, conversation_id=conversation_id)
            await websocket.send_json(response_to_dict(response))
    except WebSocketDisconnect:
        return
